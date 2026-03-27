/// Action gateway — mutate app state via MCP commands.
///
/// Provides 4 commands that change app state:
/// - `navigate` — push a route via GoRouter
/// - `switch_tab` — change the active workspace tab
/// - `invalidate` — invalidate one or all Riverpod providers
/// - `logout` — clear auth credentials and return to login
///
/// All mutations dispatch on the main isolate via
/// [WidgetsBinding.instance.addPostFrameCallback] or a [Completer] to ensure
/// safe access to Flutter framework state. MCP requests arrive on the HTTP
/// server's async I/O, not the UI thread.
///
/// All handlers return `jsonEncode({...})` and never throw. Errors are
/// returned as `{'error': 'message'}` in the JSON body.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qdexcode_desktop/core/auth/auth_provider.dart';
import 'package:qdexcode_desktop/core/state/window_state_provider.dart';
import 'package:qdexcode_desktop/features/shell/center_panel.dart';
import 'package:qdexcode_desktop/services/mcp/provider_map.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Handles the `action` gateway tool call.
///
/// Dispatches to the appropriate command handler based on `args['command']`.
/// All callbacks are invoked fresh on every call to ensure current state.
Future<String> handleAction({
  required Map<String, dynamic> args,
  required ProviderContainer Function() containerCallback,
  required GoRouter Function() routerCallback,
}) async {
  final command = args['command'] as String?;
  final commandArgs = args['args'] as Map<String, dynamic>? ?? const {};

  return switch (command) {
    'navigate' => _handleNavigate(commandArgs, routerCallback),
    'switch_tab' => _handleSwitchTab(commandArgs, containerCallback),
    'invalidate' => _handleInvalidate(commandArgs, containerCallback),
    'logout' => _handleLogout(containerCallback),
    _ => jsonEncode({
        'error': 'unknown_command',
        'command': command,
        'available': ['navigate', 'switch_tab', 'invalidate', 'logout'],
      }),
  };
}

// ---------------------------------------------------------------------------
// navigate
// ---------------------------------------------------------------------------

/// Navigate to a route via GoRouter.
///
/// Args:
/// - `route` (required): The path to navigate to (e.g., '/', '/login').
///
/// Dispatches on the main isolate via a Completer + postFrameCallback.
Future<String> _handleNavigate(
  Map<String, dynamic> args,
  GoRouter Function() routerCallback,
) async {
  final route = args['route'] as String?;
  if (route == null || route.isEmpty) {
    return jsonEncode({
      'error': 'missing_argument',
      'message': 'Provide "route" (e.g., "/", "/login", "/onboarding").',
    });
  }

  try {
    final router = routerCallback();

    // Capture previous route before navigating.
    final previousRoute =
        router.routerDelegate.currentConfiguration.uri.toString();

    final completer = Completer<String>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        router.go(route);
        completer.complete(jsonEncode({
          'success': true,
          'navigatedTo': route,
          'previousRoute': previousRoute,
        }));
      } on Exception catch (e) {
        completer.complete(jsonEncode({
          'error': 'navigate_failed',
          'route': route,
          'message': e.toString(),
        }));
      }
    });

    return completer.future;
  } on Exception catch (e) {
    return jsonEncode({
      'error': 'navigate_failed',
      'route': route,
      'message': e.toString(),
    });
  }
}

// ---------------------------------------------------------------------------
// switch_tab
// ---------------------------------------------------------------------------

/// Valid workspace tab IDs (must match [kDefaultWorkspaceTabs] in center_panel).
const _validTabIds = {'dashboard', 'terminal', 'editor', 'settings'};

/// Switch the active workspace tab.
///
/// Args:
/// - `tab` (required): Tab ID or label (e.g., 'Terminal', 'dashboard').
///
/// Updates [activeTabStateProvider] on the main isolate.
Future<String> _handleSwitchTab(
  Map<String, dynamic> args,
  ProviderContainer Function() containerCallback,
) async {
  final tabArg = args['tab'] as String?;
  if (tabArg == null || tabArg.isEmpty) {
    return jsonEncode({
      'error': 'missing_argument',
      'message': 'Provide "tab" (e.g., "Terminal", "dashboard").',
      'available': _validTabIds.toList(),
    });
  }

  // Accept both ID ('terminal') and label ('Terminal') — normalize to ID.
  final tabId = tabArg.toLowerCase();

  if (!_validTabIds.contains(tabId)) {
    return jsonEncode({
      'error': 'invalid_tab',
      'tab': tabArg,
      'available': _validTabIds.toList(),
    });
  }

  try {
    final container = containerCallback();
    final previousTab = container.read(activeTabStateProvider);

    final completer = Completer<String>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        container.read(activeTabStateProvider.notifier).setTab(tabId);
        completer.complete(jsonEncode({
          'success': true,
          'activeTab': tabId,
          'previousTab': previousTab,
        }));
      } on Exception catch (e) {
        completer.complete(jsonEncode({
          'error': 'switch_tab_failed',
          'tab': tabId,
          'message': e.toString(),
        }));
      }
    });

    return completer.future;
  } on Exception catch (e) {
    return jsonEncode({
      'error': 'switch_tab_failed',
      'tab': tabId,
      'message': e.toString(),
    });
  }
}

// ---------------------------------------------------------------------------
// invalidate
// ---------------------------------------------------------------------------

/// Invalidate one or all Riverpod providers.
///
/// Args:
/// - `provider` (required): Provider name or 'all' to invalidate everything.
///
/// Uses [invalidatableProviders] from provider_map.dart. Not all providers
/// support invalidation (keepAlive singletons like auth are excluded).
Future<String> _handleInvalidate(
  Map<String, dynamic> args,
  ProviderContainer Function() containerCallback,
) async {
  final providerName = args['provider'] as String?;
  if (providerName == null || providerName.isEmpty) {
    return jsonEncode({
      'error': 'missing_argument',
      'message': 'Provide "provider" name or "all".',
      'available': [...invalidatableProviders.keys, 'all'],
    });
  }

  try {
    final container = containerCallback();

    if (providerName == 'all') {
      // Invalidate all invalidatable providers.
      final invalidated = <String>[];
      for (final entry in invalidatableProviders.entries) {
        entry.value(container);
        invalidated.add(entry.key);
      }
      return jsonEncode({
        'success': true,
        'invalidated': invalidated,
        'count': invalidated.length,
      });
    }

    // Single provider invalidation.
    final invalidator = invalidatableProviders[providerName];
    if (invalidator == null) {
      // Check if it exists in the read registry but is not invalidatable.
      if (providerRegistry.containsKey(providerName)) {
        return jsonEncode({
          'error': 'not_invalidatable',
          'provider': providerName,
          'message':
              'This provider is read-only or keepAlive and cannot be invalidated.',
          'invalidatable': invalidatableProviders.keys.toList(),
        });
      }
      return jsonEncode({
        'error': 'unknown_provider',
        'provider': providerName,
        'available': [...invalidatableProviders.keys, 'all'],
      });
    }

    // Read previous state before invalidation.
    final reader = providerRegistry[providerName];
    final previousState = reader != null ? reader(container) : null;

    invalidator(container);

    // Read new state after invalidation.
    // Note: for async providers, the new state will be 'loading' immediately
    // after invalidation since the provider re-builds.
    final newState = reader != null ? reader(container) : null;

    return jsonEncode({
      'success': true,
      'invalidated': providerName,
      'previousState': previousState,
      'newState': newState,
    });
  } on Exception catch (e) {
    return jsonEncode({
      'error': 'invalidate_failed',
      'provider': providerName,
      'message': e.toString(),
    });
  }
}

// ---------------------------------------------------------------------------
// logout
// ---------------------------------------------------------------------------

/// Clear auth credentials and return to unauthenticated state.
///
/// Dispatches on the main isolate since it modifies provider state that
/// triggers router redirects.
Future<String> _handleLogout(
  ProviderContainer Function() containerCallback,
) async {
  try {
    final container = containerCallback();

    final completer = Completer<String>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await container.read(authProvider.notifier).logout();
        completer.complete(jsonEncode({
          'success': true,
          'message': 'Logged out. Auth state is now unauthenticated.',
        }));
      } on Exception catch (e) {
        completer.complete(jsonEncode({
          'error': 'logout_failed',
          'message': e.toString(),
        }));
      }
    });

    return completer.future;
  } on Exception catch (e) {
    return jsonEncode({
      'error': 'logout_failed',
      'message': e.toString(),
    });
  }
}
