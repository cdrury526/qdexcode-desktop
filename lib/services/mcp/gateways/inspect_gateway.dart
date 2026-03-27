/// Inspect gateway — read-only state inspection commands.
///
/// Provides 5 commands that query app state without mutation:
/// - `provider_state` — read Riverpod provider values
/// - `network_log` — recent HTTP requests from NetworkLogBuffer
/// - `widget_tree` — walk the Element tree from BuildContext
/// - `route_state` — GoRouter current route + auth + project state
/// - `panel_layout` — panel widths, active tab, theme, window size
///
/// All handlers return `jsonEncode({...})` and never throw. Errors are
/// returned as `{'error': 'message'}` in the JSON body.
library;

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:qdexcode_desktop/core/auth/auth_provider.dart';
import 'package:qdexcode_desktop/core/state/window_state_provider.dart';
import 'package:qdexcode_desktop/core/theme/theme_provider.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';
import 'package:qdexcode_desktop/services/mcp/network_log_buffer.dart';
import 'package:qdexcode_desktop/services/mcp/provider_map.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Handles the `inspect` gateway tool call.
///
/// Dispatches to the appropriate command handler based on `args['command']`.
/// The [containerCallback], [routerCallback], and [contextCallback] are
/// invoked fresh on every call to ensure current state.
String handleInspect({
  required Map<String, dynamic> args,
  required ProviderContainer Function() containerCallback,
  required GoRouter Function() routerCallback,
  required NetworkLogBuffer Function() networkLogCallback,
  required BuildContext? Function() contextCallback,
}) {
  final command = args['command'] as String?;
  final commandArgs = args['args'] as Map<String, dynamic>? ?? const {};

  return switch (command) {
    'provider_state' => _handleProviderState(commandArgs, containerCallback),
    'network_log' => _handleNetworkLog(commandArgs, networkLogCallback),
    'widget_tree' => _handleWidgetTree(commandArgs, contextCallback),
    'route_state' => _handleRouteState(containerCallback, routerCallback),
    'panel_layout' => _handlePanelLayout(containerCallback),
    _ => jsonEncode({
        'error': 'unknown_command',
        'command': command,
        'available': [
          'provider_state',
          'network_log',
          'widget_tree',
          'route_state',
          'panel_layout',
        ],
      }),
  };
}

// ---------------------------------------------------------------------------
// provider_state
// ---------------------------------------------------------------------------

String _handleProviderState(
  Map<String, dynamic> args,
  ProviderContainer Function() containerCallback,
) {
  // List mode — return all registered provider names.
  if (args['list'] == true) {
    return jsonEncode({
      'providers': providerRegistry.keys.toList()..sort(),
    });
  }

  final name = args['provider'] as String?;
  if (name == null || name.isEmpty) {
    return jsonEncode({
      'error': 'missing_argument',
      'message': 'Provide "provider" name or set "list": true.',
      'available': providerRegistry.keys.toList()..sort(),
    });
  }

  final reader = providerRegistry[name];
  if (reader == null) {
    return jsonEncode({
      'error': 'unknown_provider',
      'provider': name,
      'available': providerRegistry.keys.toList()..sort(),
    });
  }

  try {
    final container = containerCallback();
    final value = reader(container);
    return jsonEncode({'provider': name, 'value': value});
  } on Exception catch (e) {
    return jsonEncode({
      'error': 'read_failed',
      'provider': name,
      'message': e.toString(),
    });
  }
}

// ---------------------------------------------------------------------------
// network_log
// ---------------------------------------------------------------------------

String _handleNetworkLog(
  Map<String, dynamic> args,
  NetworkLogBuffer Function() networkLogCallback,
) {
  try {
    final buffer = networkLogCallback();
    final limit = args['limit'] as int? ?? 20;
    final filter = args['filter'] as String?;

    List<NetworkLogEntry> entries;
    if (filter == 'error') {
      entries = buffer.errorsOnly;
    } else if (filter != null && filter.isNotEmpty) {
      entries = buffer.filterByUrl(filter);
    } else {
      entries = buffer.entries;
    }

    // Take the most recent entries up to the limit (newest last).
    if (entries.length > limit) {
      entries = entries.sublist(entries.length - limit);
    }

    return jsonEncode({
      'entries': entries.map((e) => e.toJson()).toList(),
      'count': entries.length,
      'totalCaptured': buffer.totalCount,
      'bufferCapacity': buffer.capacity,
    });
  } on Exception catch (e) {
    return jsonEncode({
      'error': 'network_log_failed',
      'message': e.toString(),
    });
  }
}

// ---------------------------------------------------------------------------
// widget_tree
// ---------------------------------------------------------------------------

String _handleWidgetTree(
  Map<String, dynamic> args,
  BuildContext? Function() contextCallback,
) {
  final context = contextCallback();
  if (context == null) {
    return jsonEncode({
      'error': 'no_context',
      'message': 'BuildContext is not available. The app may not be mounted.',
    });
  }

  final maxDepth = args['depth'] as int? ?? 4;
  final search = args['search'] as String?;

  try {
    final tree = _walkElementTree(context as Element, maxDepth, 0);

    if (search != null && search.isNotEmpty) {
      final matches = _searchTree(tree, search.toLowerCase());
      return jsonEncode({
        'search': search,
        'matches': matches,
        'matchCount': matches.length,
      });
    }

    return jsonEncode(tree);
  } on Exception catch (e) {
    return jsonEncode({
      'error': 'widget_tree_failed',
      'message': e.toString(),
    });
  }
}

/// Recursively walks the Element tree, filtering out framework internals.
Map<String, dynamic> _walkElementTree(
  Element element,
  int maxDepth,
  int currentDepth,
) {
  final widget = element.widget;
  final typeName = widget.runtimeType.toString();

  final node = <String, dynamic>{
    'type': typeName,
    if (widget.key != null) 'key': widget.key.toString(),
    ..._extractWidgetProperties(widget),
  };

  if (currentDepth < maxDepth) {
    final children = <Map<String, dynamic>>[];
    element.visitChildren((child) {
      // Filter out framework internals that clutter the output.
      if (!_isFrameworkInternal(child.widget)) {
        children.add(_walkElementTree(child, maxDepth, currentDepth + 1));
      }
    });
    if (children.isNotEmpty) {
      node['children'] = children;
    }
  }

  return node;
}

/// Returns true for widgets that are framework plumbing, not app content.
bool _isFrameworkInternal(Widget widget) {
  final name = widget.runtimeType.toString();
  return name.startsWith('_') ||
      name.contains('Semantics') ||
      name.contains('RenderObjectToWidgetAdapter') ||
      name.contains('InheritedNotifier') ||
      name.contains('InheritedProvider') ||
      name.contains('UncontrolledProviderScope') ||
      name == 'Focus' ||
      name == 'Actions' ||
      name == 'Shortcuts' ||
      name == 'PrimaryScrollController';
}

/// Extracts meaningful properties from common widget types.
Map<String, dynamic> _extractWidgetProperties(Widget widget) {
  final props = <String, dynamic>{};

  if (widget case Text(:final data, :final style)) {
    if (data != null) props['text'] = data;
    if (style?.fontSize != null) props['fontSize'] = style!.fontSize;
  } else if (widget case Icon(:final icon)) {
    if (icon != null) {
      props['icon'] = '${icon.fontFamily}/${icon.codePoint}';
    }
  } else if (widget case SizedBox(:final width, :final height)) {
    if (width != null) props['width'] = width;
    if (height != null) props['height'] = height;
  } else if (widget case Padding(:final padding)) {
    props['padding'] = padding.toString();
  } else if (widget case Container(:final constraints)) {
    if (constraints != null) props['constraints'] = constraints.toString();
  }

  return props;
}

/// Searches the tree for nodes whose type matches [query] (case-insensitive).
List<Map<String, dynamic>> _searchTree(
  Map<String, dynamic> node,
  String query,
) {
  final matches = <Map<String, dynamic>>[];
  final typeName = (node['type'] as String?)?.toLowerCase() ?? '';

  if (typeName.contains(query)) {
    // Return a copy without children to keep search results compact.
    matches.add({
      ...node,
    }..remove('children'));
  }

  if (node['children'] case final List<dynamic> children) {
    for (final child in children) {
      if (child is Map<String, dynamic>) {
        matches.addAll(_searchTree(child, query));
      }
    }
  }

  return matches;
}

// ---------------------------------------------------------------------------
// route_state
// ---------------------------------------------------------------------------

String _handleRouteState(
  ProviderContainer Function() containerCallback,
  GoRouter Function() routerCallback,
) {
  try {
    final container = containerCallback();
    final router = routerCallback();
    final authState = serializeAuthState(container.read(authProvider));
    final selectedProject =
        container.read(selectedProjectProvider).valueOrNull;

    // Extract current route from the router's configuration.
    final routerDelegate = router.routerDelegate;
    final currentConfig = routerDelegate.currentConfiguration;

    return jsonEncode({
      'currentRoute': currentConfig.uri.toString(),
      'fullPath': currentConfig.fullPath,
      'authState': authState,
      'selectedProjectId': selectedProject?.id,
      'selectedProjectName': selectedProject?.name,
    });
  } on Exception catch (e) {
    return jsonEncode({
      'error': 'route_state_failed',
      'message': e.toString(),
    });
  }
}

// ---------------------------------------------------------------------------
// panel_layout
// ---------------------------------------------------------------------------

String _handlePanelLayout(
  ProviderContainer Function() containerCallback,
) {
  try {
    final container = containerCallback();
    final panelWidths = container.read(panelWidthsStateProvider);
    final activeTab = container.read(activeTabStateProvider);
    final themeMode = container.read(themePreferenceProvider);
    final windowGeometry = container.read(windowGeometryStateProvider);

    return jsonEncode({
      'panels': panelWidths.toJson(),
      'activeTab': activeTab,
      'theme': themeMode.name,
      'windowSize': {
        'width': windowGeometry.width,
        'height': windowGeometry.height,
      },
      'windowPosition': {
        'x': windowGeometry.x,
        'y': windowGeometry.y,
      },
    });
  } on Exception catch (e) {
    return jsonEncode({
      'error': 'panel_layout_failed',
      'message': e.toString(),
    });
  }
}
