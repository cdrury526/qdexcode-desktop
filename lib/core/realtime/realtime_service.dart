/// WebSocket service for pg-bridge realtime connections.
///
/// Handles the full lifecycle: JWT token fetch, WebSocket connection,
/// keepalive pings, exponential-backoff reconnection, and token refresh.
///
/// Reference: apps/web/src/hooks/use-websocket.ts
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:qdexcode_desktop/core/realtime/realtime_events.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Base URL for the pg-bridge WebSocket server.
const _kWsBaseUrl = 'wss://pg-bridge.chrisdrury.com/ws';

/// API endpoint for fetching a short-lived WebSocket JWT.
const _kTokenPath = '/api/ws/token';

/// Initial reconnect delay (doubles each retry, capped at [_kMaxReconnectDelay]).
const _kBaseReconnectDelay = Duration(seconds: 1);

/// Maximum reconnect delay.
const _kMaxReconnectDelay = Duration(seconds: 30);

/// Max reconnection attempts before giving up.
const _kMaxRetries = 10;

/// Ping interval to keep the connection alive (under most proxy timeouts).
const _kPingInterval = Duration(seconds: 25);

/// How long to wait for a pong before considering the connection dead.
const _kPongTimeout = Duration(seconds: 5);

/// How often to refresh the WS JWT (tokens expire in 5 minutes).
const _kTokenRefreshInterval = Duration(minutes: 4);

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Manages a single pg-bridge WebSocket connection with auto-reconnect.
///
/// Consumers listen to [messages] for incoming [RealtimeMessage]s and
/// [statusStream] for [ConnectionStatus] changes.
///
/// Usage:
/// ```dart
/// final service = RealtimeService(dio: dio);
/// service.connect();
/// service.messages.listen((msg) => print(msg));
/// service.statusStream.listen((status) => print(status));
/// ```
class RealtimeService {
  RealtimeService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  // -- Connection state -------------------------------------------------------

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  bool _intentionalClose = false;
  bool _connecting = false;
  int _retryCount = 0;

  // -- Timers -----------------------------------------------------------------

  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _pongTimer;
  Timer? _tokenRefreshTimer;

  // -- Streams ----------------------------------------------------------------

  final _messageController = StreamController<RealtimeMessage>.broadcast();
  final _statusController =
      StreamController<ConnectionStatus>.broadcast();

  ConnectionStatus _status = ConnectionStatus.disconnected;

  /// Stream of parsed incoming messages.
  Stream<RealtimeMessage> get messages => _messageController.stream;

  /// Stream of connection status changes.
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  /// The current connection status (synchronous read).
  ConnectionStatus get status => _status;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Open the WebSocket connection.
  ///
  /// Fetches a JWT from `/api/ws/token`, then connects to pg-bridge.
  /// No-op if already connected or connecting.
  Future<void> connect() async {
    if (_channel != null || _connecting) return;

    _intentionalClose = false;
    _connecting = true;
    _updateStatus(
      _retryCount > 0
          ? ConnectionStatus.reconnecting
          : ConnectionStatus.connecting,
    );

    // 1. Fetch a fresh JWT.
    final String token;
    try {
      token = await _fetchWsToken();
    } on Object catch (e) {
      _connecting = false;
      _scheduleReconnect(
        reason: 'Token fetch failed: $e',
      );
      return;
    }

    // 2. Build WebSocket URL with token query param.
    final wsUrl = Uri.parse('$_kWsBaseUrl?token=${Uri.encodeComponent(token)}');

    // 3. Connect.
    try {
      final channel = WebSocketChannel.connect(wsUrl);
      // Wait for the connection to actually establish.
      await channel.ready;

      _channel = channel;
      _connecting = false;
      _retryCount = 0;
      _updateStatus(ConnectionStatus.connected);

      // 4. Listen for incoming messages.
      _channelSubscription = channel.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
      );

      // 5. Start keepalive pings.
      _startPingTimer();

      // 6. Schedule JWT refresh (tokens expire in 5 min, refresh at 4 min).
      _startTokenRefreshTimer();
    } on Object catch (e) {
      _connecting = false;
      _channel = null;
      _scheduleReconnect(
        reason: 'WebSocket connect failed: $e',
      );
    }
  }

  /// Intentionally close the connection. Does not auto-reconnect.
  void disconnect() {
    _intentionalClose = true;
    _connecting = false;
    _cancelAllTimers();
    _retryCount = 0;

    _channelSubscription?.cancel();
    _channelSubscription = null;

    _channel?.sink.close(1000, 'Client disconnect');
    _channel = null;

    _updateStatus(ConnectionStatus.disconnected);
  }

  /// Close and immediately reconnect (resets retry counter).
  void reconnect() {
    _retryCount = 0;
    disconnect();
    // Small delay for clean close before reconnecting.
    _reconnectTimer = Timer(
      const Duration(milliseconds: 100),
      () => connect(),
    );
  }

  /// Release all resources. Call when the service is no longer needed.
  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }

  // ---------------------------------------------------------------------------
  // Token management
  // ---------------------------------------------------------------------------

  /// Fetch a short-lived JWT for WebSocket authentication.
  ///
  /// The token endpoint uses the same Bearer auth as all other API calls
  /// (handled by the Dio interceptor).
  Future<String> _fetchWsToken() async {
    final response = await _dio.get<Map<String, dynamic>>(_kTokenPath);
    final data = response.data;
    if (data == null) {
      throw Exception('Empty response from $_kTokenPath');
    }
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Missing token in $_kTokenPath response');
    }
    return token;
  }

  /// Refresh the WebSocket connection with a new JWT before it expires.
  ///
  /// Closes the existing connection and opens a new one with a fresh token.
  Future<void> _refreshConnection() async {
    if (_status != ConnectionStatus.connected) return;

    // Close existing without triggering reconnect.
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _cancelPingTimers();

    _channel?.sink.close(1000, 'Token refresh');
    _channel = null;
    _connecting = false;

    // Reconnect with a fresh token.
    await connect();
  }

  // ---------------------------------------------------------------------------
  // WebSocket event handlers
  // ---------------------------------------------------------------------------

  void _onData(dynamic raw) {
    if (raw is! String) return;

    final message = RealtimeMessage.tryParse(raw);
    if (message == null) return;

    // Handle pong: clear the pong timeout.
    if (message.type == RealtimeMessageType.pong) {
      _pongTimer?.cancel();
      _pongTimer = null;
      return;
    }

    _messageController.add(message);
  }

  void _onError(Object error, StackTrace stackTrace) {
    // The onDone callback fires after an error, which handles reconnection.
  }

  void _onDone() {
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel = null;
    _cancelPingTimers();

    if (_intentionalClose) {
      _updateStatus(ConnectionStatus.disconnected);
      return;
    }

    _scheduleReconnect(reason: 'Connection closed');
  }

  // ---------------------------------------------------------------------------
  // Reconnection with exponential backoff
  // ---------------------------------------------------------------------------

  void _scheduleReconnect({required String reason}) {
    if (_intentionalClose) return;

    if (_retryCount >= _kMaxRetries) {
      _updateStatus(ConnectionStatus.error);
      return;
    }

    final delay = Duration(
      milliseconds: math.min(
        _kBaseReconnectDelay.inMilliseconds *
            math.pow(2, _retryCount).toInt(),
        _kMaxReconnectDelay.inMilliseconds,
      ),
    );
    _retryCount++;
    _updateStatus(ConnectionStatus.reconnecting);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () => connect());
  }

  // ---------------------------------------------------------------------------
  // Keepalive pings
  // ---------------------------------------------------------------------------

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_kPingInterval, (_) {
      if (_channel == null) return;

      _channel!.sink.add(
        jsonEncode({
          'type': 'ping',
          'data': <String, dynamic>{},
          'ts': DateTime.now().toUtc().toIso8601String(),
        }),
      );

      // Set a timeout for pong response.
      _pongTimer?.cancel();
      _pongTimer = Timer(_kPongTimeout, () {
        // No pong received -- connection is likely dead.
        _channel?.sink.close(4000, 'Pong timeout');
      });
    });
  }

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(
      _kTokenRefreshInterval,
      (_) => _refreshConnection(),
    );
  }

  // ---------------------------------------------------------------------------
  // Status management
  // ---------------------------------------------------------------------------

  void _updateStatus(ConnectionStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    _statusController.add(newStatus);
  }

  // ---------------------------------------------------------------------------
  // Timer cleanup
  // ---------------------------------------------------------------------------

  void _cancelPingTimers() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _pongTimer?.cancel();
    _pongTimer = null;
  }

  void _cancelAllTimers() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    _cancelPingTimers();
  }
}
