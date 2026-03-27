/// Gateway tool registry — registers the 4 MCP gateway tools with FastMCP.
///
/// Each gateway tool is a single MCP tool that dispatches to many commands
/// via a `command` parameter. This pattern keeps the tool list small while
/// supporting a rich set of operations.
///
/// The four gateways are:
/// - `inspect` — read-only state inspection (providers, routes, network log)
/// - `capture` — screenshots, widget tree snapshots
/// - `action` — mutate state (navigate, invalidate providers, hot reload)
/// - `server` — meta/health (server info, tool list, uptime)
///
/// All handlers return `jsonEncode({...})` strings. Errors are returned as
/// `{error: 'message'}` in the JSON body, never as exceptions.
library;

import 'dart:convert';

import 'package:dart_mcp/dart_mcp.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qdexcode_desktop/services/mcp/gateways/action_gateway.dart';
import 'package:qdexcode_desktop/services/mcp/gateways/capture_gateway.dart';
import 'package:qdexcode_desktop/services/mcp/gateways/inspect_gateway.dart';
import 'package:qdexcode_desktop/services/mcp/gateways/server_gateway.dart';
import 'package:qdexcode_desktop/services/mcp/network_log_buffer.dart';

/// Callbacks that gateway handlers use to access current app state.
///
/// These are invoked on every tool call — never cached — so handlers
/// always see the latest state even when tabs/routes change.
class GatewayCallbacks {
  /// Creates gateway callbacks.
  const GatewayCallbacks({
    required this.container,
    required this.router,
    required this.networkLog,
    required this.context,
  });

  /// Returns the current [ProviderContainer].
  final ProviderContainer Function() container;

  /// Returns the current [GoRouter].
  final GoRouter Function() router;

  /// Returns the [NetworkLogBuffer] for HTTP traffic capture.
  final NetworkLogBuffer Function() networkLog;

  /// Returns the current [BuildContext], or `null` if the app is not mounted.
  final BuildContext? Function() context;
}

/// Registers the 4 gateway tools on [mcp].
///
/// [callbacks] provides fresh access to app state on every tool invocation.
/// [serverInfo] provides transport-level metadata for the server gateway.
void registerGatewayTools(
  FastMCP mcp, {
  GatewayCallbacks? callbacks,
  ServerInfo? serverInfo,
}) {
  // ---------------------------------------------------------------------------
  //  inspect — read-only state inspection
  // ---------------------------------------------------------------------------
  mcp.registerTool(
    name: 'inspect',
    description:
        'Read-only inspection of app state. Dispatches to sub-commands '
        'via the "command" argument. Available commands: provider_state, '
        'network_log, widget_tree, route_state, panel_layout.',
    inputSchema: _gatewaySchema(
      description: 'The inspect sub-command to execute.',
      commands: [
        'provider_state',
        'network_log',
        'widget_tree',
        'route_state',
        'panel_layout',
      ],
    ),
    handler: (args) => callbacks != null
        ? handleInspect(
            args: args,
            containerCallback: callbacks.container,
            routerCallback: callbacks.router,
            networkLogCallback: callbacks.networkLog,
            contextCallback: callbacks.context,
          )
        : _stubHandler('inspect', args),
  );

  // ---------------------------------------------------------------------------
  //  capture — screenshots, widget tree snapshots
  // ---------------------------------------------------------------------------
  mcp.registerTool(
    name: 'capture',
    description:
        'Capture visual state from the running app. Dispatches to '
        'sub-commands via the "command" argument. Available commands: '
        'screen, screen_widget.',
    inputSchema: _gatewaySchema(
      description: 'The capture sub-command to execute.',
      commands: ['screen', 'screen_widget'],
    ),
    handler: (args) => callbacks != null
        ? handleCapture(
            args: args,
            contextCallback: callbacks.context,
          )
        : _stubHandler('capture', args),
  );

  // ---------------------------------------------------------------------------
  //  action — mutate state
  // ---------------------------------------------------------------------------
  mcp.registerTool(
    name: 'action',
    description:
        'Mutate app state. Dispatches to sub-commands via the "command" '
        'argument. Available commands: navigate, switch_tab, invalidate, '
        'logout. All mutations dispatch on the main isolate.',
    inputSchema: _gatewaySchema(
      description: 'The action sub-command to execute.',
      commands: ['navigate', 'switch_tab', 'invalidate', 'logout'],
    ),
    handler: (args) => callbacks != null
        ? handleAction(
            args: args,
            containerCallback: callbacks.container,
            routerCallback: callbacks.router,
          )
        : _stubHandler('action', args),
  );

  // ---------------------------------------------------------------------------
  //  server — meta/health
  // ---------------------------------------------------------------------------
  mcp.registerTool(
    name: 'server',
    description:
        'Server meta-information and health. Dispatches to sub-commands '
        'via the "command" argument. Available commands: health, '
        'list_commands, status.',
    inputSchema: _gatewaySchema(
      description: 'The server sub-command to execute.',
      commands: ['health', 'list_commands', 'status'],
    ),
    handler: (args) => callbacks != null
        ? handleServer(
            args: args,
            containerCallback: callbacks.container,
            networkLogCallback: callbacks.networkLog,
            serverInfo: serverInfo,
          )
        : _stubHandler('server', args),
  );
}

/// Builds the JSON Schema for a gateway tool's input.
///
/// Every gateway tool accepts `command` (required string enum) and
/// `args` (optional object for command-specific parameters).
Map<String, dynamic> _gatewaySchema({
  required String description,
  required List<String> commands,
}) =>
    {
      'type': 'object',
      'properties': {
        'command': {
          'type': 'string',
          'description': description,
          'enum': commands,
        },
        'args': {
          'type': 'object',
          'description': 'Command-specific arguments.',
          'additionalProperties': true,
        },
      },
      'required': ['command'],
    };

/// Stub handler that returns `{error: 'not_implemented'}` for all commands.
///
/// Replaced with real dispatchers in Phase 2.
String _stubHandler(String gateway, Map<String, dynamic> args) {
  final command = args['command'] as String?;
  return jsonEncode({
    'error': 'not_implemented',
    'gateway': gateway,
    'command': command,
    'message': 'This command will be implemented in Phase 2.',
  });
}

