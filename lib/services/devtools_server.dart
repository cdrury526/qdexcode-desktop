/// MCP DevTools server — runs in-process for app state introspection.
///
/// Built with the dart_mcp SDK's [FastMCP] class. Exposes 4 gateway tools
/// (inspect, capture, action, server) that dispatch to sub-commands via
/// a `command` parameter.
///
/// Served over streamable HTTP on localhost:9731. Claude Code connects to
/// `http://localhost:9731/mcp` via POST with JSON-RPC 2.0 messages.
///
/// The server starts automatically on app launch (debug mode only) and
/// stops on dispose. It is non-blocking — the HTTP server runs on async
/// I/O and never blocks the Flutter UI thread.
library;

import 'package:dart_mcp/dart_mcp.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qdexcode_desktop/core/api/api_client.dart';
import 'package:qdexcode_desktop/services/mcp/gateway_registry.dart';
import 'package:qdexcode_desktop/services/mcp/gateways/server_gateway.dart';
import 'package:qdexcode_desktop/services/mcp/http_transport.dart';

/// Callback that returns the [ProviderContainer] for state inspection.
typedef ContainerProvider = ProviderContainer Function();

/// Callback that returns the [GoRouter] for route inspection.
typedef RouterProvider = GoRouter Function();

/// Callback that returns the [Dio] instance for network inspection.
typedef DioProvider = Dio Function();

/// The in-process MCP DevTools server for qdexcode-desktop.
///
/// Manages the lifecycle of the HTTP transport and [FastMCP] server.
/// Provider callbacks are called on each tool invocation so the tools
/// always operate on the current app state.
///
/// Usage:
/// ```dart
/// final server = DevtoolsServer(
///   containerProvider: () => container,
///   routerProvider: () => router,
///   dioProvider: () => dio,
/// );
/// await server.start();
/// // ... app runs ...
/// await server.stop();
/// ```
class DevtoolsServer {
  /// Creates a devtools server.
  ///
  /// [containerProvider] returns the Riverpod container for state queries.
  /// [routerProvider] returns the GoRouter for route queries.
  /// [dioProvider] returns the Dio instance for network queries.
  /// [contextProvider] optionally returns the current root BuildContext.
  /// [port] is the localhost port to listen on (default 9731).
  DevtoolsServer({
    required this.containerProvider,
    required this.routerProvider,
    required this.dioProvider,
    this.contextProvider,
    this.port = 9731,
  });

  /// The localhost port the server listens on.
  final int port;

  /// Returns the Riverpod [ProviderContainer] for state inspection.
  ///
  /// Called by gateway handlers on each tool invocation (Phase 2).
  final ContainerProvider containerProvider;

  /// Returns the [GoRouter] for route inspection.
  ///
  /// Called by gateway handlers on each tool invocation (Phase 2).
  final RouterProvider routerProvider;

  /// Returns the [Dio] instance for network inspection.
  ///
  /// Called by gateway handlers on each tool invocation (Phase 2).
  final DioProvider dioProvider;

  /// Optional callback that returns the current root [BuildContext].
  ///
  /// Used by tools that need widget tree access (e.g., screenshots).
  /// May return `null` if the widget tree is not yet built.
  final BuildContext? Function()? contextProvider;

  HttpTransport? _transport;
  FastMCP? _mcp;

  /// Whether the server is currently running and accepting connections.
  bool get isRunning => _transport?.isRunning ?? false;

  /// The actual port the server is bound to.
  ///
  /// Only valid when [isRunning] is `true`.
  int get boundPort => _transport?.boundPort ?? port;

  /// Start the MCP server.
  ///
  /// Binds the HTTP server to localhost on [port], registers all gateway
  /// tools, and begins accepting MCP requests.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops if the
  /// server is already running.
  Future<void> start() async {
    if (isRunning) return;

    try {
      _transport = HttpTransport(port: port);

      _mcp = FastMCP(
        'qdexcode-devtools',
        transport: _transport,
      );

      final startTime = DateTime.now();

      // Register the 4 gateway tools with live callbacks into app state.
      registerGatewayTools(
        _mcp!,
        callbacks: GatewayCallbacks(
          container: containerProvider,
          router: routerProvider,
          networkLog: () => networkLogBuffer,
          context: contextProvider ?? () => null,
        ),
        serverInfo: ServerInfo(
          port: () => _transport?.boundPort ?? port,
          connectedClients: () => _transport?.connectedClients ?? 0,
          startTime: () => startTime,
        ),
      );

      // Start the HTTP server.
      final boundPort = await _transport!.start();
      debugPrint(
        'DevtoolsServer: MCP server listening on '
        'http://localhost:$boundPort/mcp',
      );
    } on Exception catch (e) {
      debugPrint('DevtoolsServer: failed to start: $e');
      await stop();
      rethrow;
    }
  }

  /// Stop the MCP server and release all resources.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> stop() async {
    final mcp = _mcp;
    final transport = _transport;

    _mcp = null;
    _transport = null;

    if (mcp != null) {
      try {
        await mcp.close();
      } on Exception catch (e) {
        debugPrint('DevtoolsServer: error closing MCP server: $e');
      }
    }

    if (transport != null) {
      try {
        await transport.close();
      } on Exception catch (e) {
        debugPrint('DevtoolsServer: error closing transport: $e');
      }
    }

    debugPrint('DevtoolsServer: stopped');
  }
}
