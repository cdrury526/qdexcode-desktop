/// Server gateway — meta-information, health, and command discovery.
///
/// Provides 3 commands:
/// - `health` — quick health check with auth state and selected project
/// - `list_commands` — discovery of all gateways and their commands
/// - `status` — detailed server status (uptime, clients, network log stats)
///
/// All handlers return `jsonEncode({...})` and never throw. Errors are
/// returned as `{'error': 'message'}` in the JSON body.
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/auth/auth_provider.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';
import 'package:qdexcode_desktop/services/mcp/gateway_registry.dart';
import 'package:qdexcode_desktop/services/mcp/network_log_buffer.dart';
import 'package:qdexcode_desktop/services/mcp/provider_map.dart';

/// Transport-level information that the server gateway needs but that
/// lives outside the standard [GatewayCallbacks].
///
/// Provided by the devtools server at registration time via closures so
/// values are always fresh.
class ServerInfo {
  /// Creates server info callbacks.
  const ServerInfo({
    required this.port,
    required this.connectedClients,
    required this.startTime,
  });

  /// Returns the port the server is listening on.
  final int Function() port;

  /// Returns the number of active SSE client connections.
  final int Function() connectedClients;

  /// Returns when the server was started.
  final DateTime Function() startTime;
}

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Handles the `server` gateway tool call.
///
/// Dispatches to the appropriate command handler based on `args['command']`.
/// Uses [GatewayCallbacks] for auth/project state and [ServerInfo] for
/// transport-level metadata.
String handleServer({
  required Map<String, dynamic> args,
  required ProviderContainer Function() containerCallback,
  required NetworkLogBuffer Function() networkLogCallback,
  ServerInfo? serverInfo,
}) {
  final command = args['command'] as String?;
  final commandArgs = args['args'] as Map<String, dynamic>? ?? const {};

  return switch (command) {
    'health' => _handleHealth(containerCallback),
    'list_commands' => _handleListCommands(commandArgs),
    'status' => _handleStatus(
        containerCallback,
        networkLogCallback,
        serverInfo,
      ),
    _ => jsonEncode({
        'error': 'unknown_command',
        'command': command,
        'available': ['health', 'list_commands', 'status'],
      }),
  };
}

// ---------------------------------------------------------------------------
// health
// ---------------------------------------------------------------------------

/// Quick health check returning app running state, auth status, and
/// selected project.
///
/// Uses [GatewayCallbacks] to read real auth and project state from
/// Riverpod providers on every call.
String _handleHealth(ProviderContainer Function() containerCallback) {
  try {
    final container = containerCallback();

    // Read auth state and derive a simple status string.
    final authState = container.read(authProvider);
    final authStatus = switch (authState) {
      AuthAuthenticated() => 'authenticated',
      AuthLoading() => 'loading',
      AuthDeviceFlowPending() => 'device_flow_pending',
      AuthUnauthenticated() => 'unauthenticated',
    };

    // Read selected project name if available.
    final selectedProject =
        container.read(selectedProjectProvider).valueOrNull;

    return jsonEncode({
      'status': 'ok',
      'appRunning': true,
      'authState': authStatus,
      'selectedProject': selectedProject?.name,
      'serverName': 'qdexcode-devtools',
      'protocolVersion': '2025-06-18',
    });
  } on Exception catch (e) {
    return jsonEncode({
      'status': 'ok',
      'appRunning': true,
      'authState': 'unknown',
      'selectedProject': null,
      'error': 'Failed to read app state: $e',
    });
  }
}

// ---------------------------------------------------------------------------
// list_commands
// ---------------------------------------------------------------------------

/// Full command catalog for all 4 gateways with descriptions and argument
/// schemas.
///
/// If `args['gateway']` is specified, returns only that gateway's commands.
/// This is the primary discovery mechanism — Claude Code calls this first
/// to learn what tools and commands are available.
String _handleListCommands(Map<String, dynamic> args) {
  final gatewayFilter = args['gateway'] as String?;

  final catalog = <String, Map<String, dynamic>>{
    'inspect': {
      'description': 'Read-only inspection of app state — providers, '
          'routes, widget tree, network log, panel layout.',
      'commands': {
        'provider_state': {
          'description': 'Read a Riverpod provider value by name.',
          'args': {
            'provider': {
              'type': 'string',
              'description': 'Provider name (e.g., "authProvider").',
            },
            'list': {
              'type': 'boolean',
              'description': 'Set true to list all available provider names.',
            },
          },
        },
        'network_log': {
          'description':
              'Recent HTTP requests captured by the Dio interceptor.',
          'args': {
            'limit': {
              'type': 'integer',
              'description': 'Max entries to return (default 20).',
            },
            'filter': {
              'type': 'string',
              'description':
                  'URL substring filter, or "error" for errors only.',
            },
          },
        },
        'widget_tree': {
          'description': 'Walk the Flutter Element tree from the root.',
          'args': {
            'depth': {
              'type': 'integer',
              'description': 'Max tree depth to traverse (default 4).',
            },
            'search': {
              'type': 'string',
              'description':
                  'Filter tree nodes by widget type name (case-insensitive).',
            },
          },
        },
        'route_state': {
          'description': 'Current GoRouter route, auth state, and selected '
              'project.',
          'args': <String, dynamic>{},
        },
        'panel_layout': {
          'description': 'Panel widths, active tab, theme, and window '
              'geometry.',
          'args': <String, dynamic>{},
        },
      },
    },
    'capture': {
      'description': 'Visual output capture — screenshots of the running '
          'app as base64 PNG.',
      'commands': {
        'screen': {
          'description': 'Full-screen screenshot as base64 PNG.',
          'args': <String, dynamic>{},
        },
        'screen_widget': {
          'description': 'Capture a specific widget by class name as '
              'base64 PNG.',
          'args': {
            'widget': {
              'type': 'string',
              'description':
                  'Widget class name to capture (e.g., "DashboardPage").',
              'required': true,
            },
          },
        },
      },
    },
    'action': {
      'description': 'Mutate app state — navigation, tab switching, '
          'provider invalidation, logout.',
      'commands': {
        'navigate': {
          'description': 'Push a route via GoRouter.',
          'args': {
            'route': {
              'type': 'string',
              'description':
                  'Route path to navigate to (e.g., "/", "/login").',
              'required': true,
            },
          },
        },
        'switch_tab': {
          'description': 'Change the active workspace tab.',
          'args': {
            'tab': {
              'type': 'string',
              'description': 'Tab ID or label (e.g., "terminal", '
                  '"dashboard").',
              'required': true,
              'enum': ['dashboard', 'terminal', 'editor', 'settings'],
            },
          },
        },
        'invalidate': {
          'description': 'Invalidate one or all Riverpod providers to '
              'force re-fetch.',
          'args': {
            'provider': {
              'type': 'string',
              'description': 'Provider name or "all" to invalidate '
                  'everything.',
              'required': true,
            },
          },
        },
        'logout': {
          'description': 'Clear auth credentials and return to '
              'unauthenticated state.',
          'args': <String, dynamic>{},
        },
      },
    },
    'server': {
      'description': 'Server meta-information — health, status, and '
          'command discovery.',
      'commands': {
        'health': {
          'description': 'Quick health check with auth state and selected '
              'project.',
          'args': <String, dynamic>{},
        },
        'list_commands': {
          'description': 'Discover all gateways, commands, and argument '
              'schemas.',
          'args': {
            'gateway': {
              'type': 'string',
              'description': 'Filter to a specific gateway '
                  '(e.g., "inspect").',
              'enum': ['inspect', 'capture', 'action', 'server'],
            },
          },
        },
        'status': {
          'description': 'Detailed server status — uptime, connected '
              'clients, network log stats.',
          'args': <String, dynamic>{},
        },
      },
    },
  };

  // If a specific gateway is requested, return just that one.
  if (gatewayFilter != null && gatewayFilter.isNotEmpty) {
    final gateway = catalog[gatewayFilter];
    if (gateway == null) {
      return jsonEncode({
        'error': 'unknown_gateway',
        'gateway': gatewayFilter,
        'available': catalog.keys.toList(),
      });
    }
    return jsonEncode({
      'gateway': gatewayFilter,
      ...gateway,
    });
  }

  return jsonEncode({'gateways': catalog});
}

// ---------------------------------------------------------------------------
// status
// ---------------------------------------------------------------------------

/// Detailed server status including uptime, connected clients, network log
/// entry count, and available provider count.
String _handleStatus(
  ProviderContainer Function() containerCallback,
  NetworkLogBuffer Function() networkLogCallback,
  ServerInfo? serverInfo,
) {
  try {
    final networkLog = networkLogCallback();

    // Compute uptime if start time is available.
    String uptimeStr;
    if (serverInfo != null) {
      final elapsed = DateTime.now().difference(serverInfo.startTime());
      uptimeStr = _formatDuration(elapsed);
    } else {
      uptimeStr = 'unknown';
    }

    return jsonEncode({
      'status': 'ok',
      'serverName': 'qdexcode-devtools',
      'port': serverInfo?.port() ?? 9731,
      'protocolVersion': '2025-06-18',
      'uptime': uptimeStr,
      'connectedClients': serverInfo?.connectedClients() ?? 0,
      'networkLogEntries': networkLog.totalCount,
      'networkLogBufferSize': networkLog.length,
      'networkLogCapacity': networkLog.capacity,
      'availableProviders': providerRegistry.length,
      'invalidatableProviders': invalidatableProviders.length,
    });
  } on Exception catch (e) {
    return jsonEncode({
      'error': 'status_failed',
      'message': e.toString(),
    });
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Formats a [Duration] as a human-readable string like "2h 15m 30s".
String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
  if (minutes > 0) return '${minutes}m ${seconds}s';
  return '${seconds}s';
}
