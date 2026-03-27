/// Device flow authentication service (RFC 8628).
///
/// Handles the OAuth device flow against v2.chrisdrury.com/api/auth/device/*
/// and persists the resulting bearer token via flutter_secure_storage.
///
/// Mirrors the Go client in apps/desktop/auth/device_flow.go.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Process;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _kBaseUrl = 'https://v2.chrisdrury.com';
const _kTokenStorageKey = 'qdexcode_auth_token';
const _kMinPollInterval = Duration(seconds: 5);

// ---------------------------------------------------------------------------
// Response models
// ---------------------------------------------------------------------------

/// Response from POST /api/auth/device/code.
class DeviceCodeResponse {
  const DeviceCodeResponse({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUrl,
    required this.expiresIn,
    required this.interval,
  });

  factory DeviceCodeResponse.fromJson(Map<String, dynamic> json) {
    return DeviceCodeResponse(
      deviceCode: json['device_code'] as String,
      userCode: json['user_code'] as String,
      verificationUrl: json['verification_url'] as String,
      expiresIn: json['expires_in'] as int,
      interval: json['interval'] as int,
    );
  }

  final String deviceCode;
  final String userCode;
  final String verificationUrl;

  /// Seconds until the device code expires.
  final int expiresIn;

  /// Server-suggested poll interval in seconds.
  final int interval;
}

/// Successful token response from POST /api/auth/device/token.
class DeviceTokenResponse {
  const DeviceTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.user,
  });

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) {
    return DeviceTokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      user: json['user'] != null
          ? DeviceTokenUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final DeviceTokenUser? user;
}

/// Minimal user info returned alongside the device token.
class DeviceTokenUser {
  const DeviceTokenUser({
    required this.id,
    required this.email,
    required this.name,
  });

  factory DeviceTokenUser.fromJson(Map<String, dynamic> json) {
    return DeviceTokenUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }

  final String id;
  final String email;
  final String name;
}

// ---------------------------------------------------------------------------
// Polling status (for UI updates)
// ---------------------------------------------------------------------------

/// Status emitted by the device flow polling stream.
enum DeviceFlowStatus {
  /// Waiting for user to approve in the browser.
  pending,

  /// User approved; token received.
  approved,

  /// User denied the request.
  denied,

  /// The device code expired before approval.
  expired,

  /// An unexpected error occurred during polling.
  error,
}

/// A polling status update with optional data.
class DeviceFlowUpdate {
  const DeviceFlowUpdate({
    required this.status,
    this.tokenResponse,
    this.errorMessage,
  });

  final DeviceFlowStatus status;
  final DeviceTokenResponse? tokenResponse;
  final String? errorMessage;
}

// ---------------------------------------------------------------------------
// Auth service
// ---------------------------------------------------------------------------

/// Service that executes the OAuth device flow and manages token storage.
class AuthService {
  AuthService({
    Dio? dio,
    FlutterSecureStorage? secureStorage,
    String? baseUrl,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl ?? _kBaseUrl)),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  // -- Token storage -------------------------------------------------------

  /// Read the stored bearer token, or null if none exists.
  Future<String?> loadToken() async {
    return _secureStorage.read(key: _kTokenStorageKey);
  }

  /// Persist a bearer token to secure storage.
  Future<void> storeToken(String token) async {
    await _secureStorage.write(key: _kTokenStorageKey, value: token);
  }

  /// Delete the stored bearer token.
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _kTokenStorageKey);
  }

  // -- Device flow ---------------------------------------------------------

  /// Step 1: Request a device code from the server.
  ///
  /// POST /api/auth/device/code (no auth required).
  Future<DeviceCodeResponse> requestDeviceCode() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/device/code',
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
    return DeviceCodeResponse.fromJson(response.data!);
  }

  /// Step 2: Open the verification URL in the system browser (macOS only).
  Future<void> openVerificationUrl(String url) async {
    await Process.run('open', [url]);
  }

  /// Step 3: Poll for token approval.
  ///
  /// Returns a stream of [DeviceFlowUpdate] that emits [pending] on each
  /// poll cycle and terminates with [approved], [denied], [expired], or
  /// [error].
  ///
  /// Cancel the returned [StreamSubscription] to abort polling.
  Stream<DeviceFlowUpdate> pollForToken(DeviceCodeResponse codeResponse) {
    late final StreamController<DeviceFlowUpdate> controller;
    Timer? pollTimer;
    var cancelled = false;

    final interval = Duration(seconds: codeResponse.interval);
    final effectiveInterval =
        interval < _kMinPollInterval ? _kMinPollInterval : interval;
    final deadline = DateTime.now().add(
      Duration(seconds: codeResponse.expiresIn),
    );

    Future<void> poll() async {
      if (cancelled) return;

      // Check expiry.
      if (DateTime.now().isAfter(deadline)) {
        controller.add(const DeviceFlowUpdate(
          status: DeviceFlowStatus.expired,
          errorMessage: 'Device code expired',
        ));
        await controller.close();
        return;
      }

      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '/api/auth/device/token',
          data: jsonEncode({'device_code': codeResponse.deviceCode}),
          options: Options(
            contentType: Headers.jsonContentType,
            // Don't throw on 400 — the server returns 400 for pending/errors.
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        final data = response.data!;

        if (response.statusCode == 200) {
          // Token issued.
          final tokenResponse = DeviceTokenResponse.fromJson(data);

          // Persist immediately.
          await storeToken(tokenResponse.accessToken);

          controller.add(DeviceFlowUpdate(
            status: DeviceFlowStatus.approved,
            tokenResponse: tokenResponse,
          ));
          await controller.close();
          return;
        }

        // Error response — check the error field.
        final errorCode = data['error'] as String? ?? '';
        switch (errorCode) {
          case 'authorization_pending':
          case 'slow_down':
            controller.add(
              const DeviceFlowUpdate(status: DeviceFlowStatus.pending),
            );
            // Schedule next poll.
            if (!cancelled) {
              pollTimer = Timer(effectiveInterval, poll);
            }
          case 'access_denied':
            controller.add(const DeviceFlowUpdate(
              status: DeviceFlowStatus.denied,
              errorMessage: 'Access denied by user',
            ));
            await controller.close();
          case 'expired_token':
            controller.add(const DeviceFlowUpdate(
              status: DeviceFlowStatus.expired,
              errorMessage: 'Device code expired',
            ));
            await controller.close();
          default:
            final desc = data['error_description'] as String? ?? errorCode;
            controller.add(DeviceFlowUpdate(
              status: DeviceFlowStatus.error,
              errorMessage: desc,
            ));
            await controller.close();
        }
      } on DioException catch (e) {
        controller.add(DeviceFlowUpdate(
          status: DeviceFlowStatus.error,
          errorMessage: e.message ?? 'Network error',
        ));
        // Network error — retry on next cycle rather than giving up.
        if (!cancelled) {
          pollTimer = Timer(effectiveInterval, poll);
        }
      }
    }

    controller = StreamController<DeviceFlowUpdate>(
      onListen: () {
        // Emit an initial pending status, then start polling.
        controller.add(
          const DeviceFlowUpdate(status: DeviceFlowStatus.pending),
        );
        pollTimer = Timer(effectiveInterval, poll);
      },
      onCancel: () {
        cancelled = true;
        pollTimer?.cancel();
      },
    );

    return controller.stream;
  }

  // -- Session validation --------------------------------------------------

  /// Validate a token by calling GET /api/auth/session with a Bearer header.
  ///
  /// Returns the session response map on success, or throws on failure.
  Future<Map<String, dynamic>> validateSession(String token) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/auth/session',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return response.data!;
  }
}
