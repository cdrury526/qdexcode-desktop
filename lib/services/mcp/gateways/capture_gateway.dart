/// Capture gateway — visual output capture via MCP commands.
///
/// Provides 2 commands that capture visual state:
/// - `screen` — full-screen screenshot as base64 PNG
/// - `screen_widget` — capture a specific named widget as base64 PNG
///
/// All capture operations dispatch on the main isolate via
/// [WidgetsBinding.instance.addPostFrameCallback] and a [Completer] to ensure
/// safe access to the render tree. MCP requests arrive on the HTTP server's
/// async I/O, not the UI thread.
///
/// All handlers return `jsonEncode({...})` and never throw. Errors are
/// returned as `{'error': 'message'}` in the JSON body.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Handles the `capture` gateway tool call.
///
/// Dispatches to the appropriate command handler based on `args['command']`.
/// The [contextCallback] is invoked fresh on every call to ensure current
/// state.
Future<String> handleCapture({
  required Map<String, dynamic> args,
  required BuildContext? Function() contextCallback,
}) async {
  final command = args['command'] as String?;
  final commandArgs = args['args'] as Map<String, dynamic>? ?? const {};

  return switch (command) {
    'screen' => _handleScreen(contextCallback),
    'screen_widget' => _handleScreenWidget(commandArgs, contextCallback),
    _ => jsonEncode({
        'error': 'unknown_command',
        'command': command,
        'available': ['screen', 'screen_widget'],
      }),
  };
}

// ---------------------------------------------------------------------------
// screen — full-screen capture
// ---------------------------------------------------------------------------

/// Capture the entire app screen as a base64-encoded PNG.
///
/// Uses [RenderRepaintBoundary.toImage] from the root RenderObject
/// obtained via [BuildContext]. Dispatches to the UI thread via a
/// [Completer] + [WidgetsBinding.instance.addPostFrameCallback].
Future<String> _handleScreen(
  BuildContext? Function() contextCallback,
) async {
  final context = contextCallback();
  if (context == null) {
    return jsonEncode({
      'error': 'no_context',
      'message': 'BuildContext is not available. The app may not be mounted.',
    });
  }

  final completer = Completer<String>();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      // Find the root RenderRepaintBoundary from the context.
      final renderObject = context.findRenderObject();
      if (renderObject == null) {
        completer.complete(jsonEncode({
          'error': 'no_render_object',
          'message': 'Could not find a RenderObject from the current context.',
        }));
        return;
      }

      // Walk up to find the nearest RepaintBoundary (the root is typically
      // a RenderRepaintBoundary wrapping the entire app).
      final boundary = _findRepaintBoundary(renderObject);
      if (boundary == null) {
        completer.complete(jsonEncode({
          'error': 'no_repaint_boundary',
          'message':
              'Could not find a RenderRepaintBoundary in the render tree.',
        }));
        return;
      }

      final result = await _captureRenderObject(boundary);
      completer.complete(result);
    } on Exception catch (e) {
      completer.complete(jsonEncode({
        'error': 'capture_failed',
        'message': e.toString(),
      }));
    }
  });

  return completer.future;
}

// ---------------------------------------------------------------------------
// screen_widget — capture a named widget
// ---------------------------------------------------------------------------

/// Capture a specific widget by its runtime type name.
///
/// Args:
/// - `widget` (required): The widget class name (e.g., 'DashboardPage').
///
/// Walks the [Element] tree to find a widget whose [runtimeType] matches,
/// then captures its [RenderObject] as a PNG.
Future<String> _handleScreenWidget(
  Map<String, dynamic> args,
  BuildContext? Function() contextCallback,
) async {
  final widgetName = args['widget'] as String?;
  if (widgetName == null || widgetName.isEmpty) {
    return jsonEncode({
      'error': 'missing_argument',
      'message': 'Provide "widget" — the widget class name to capture '
          '(e.g., "DashboardPage").',
    });
  }

  final context = contextCallback();
  if (context == null) {
    return jsonEncode({
      'error': 'no_context',
      'message': 'BuildContext is not available. The app may not be mounted.',
    });
  }

  final completer = Completer<String>();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      // Walk the Element tree to find the named widget.
      final targetRenderObject = _findWidgetRenderObject(
        context as Element,
        widgetName,
      );

      if (targetRenderObject == null) {
        completer.complete(jsonEncode({
          'error': 'widget_not_found',
          'widget': widgetName,
          'message':
              'Could not find a widget named "$widgetName" in the tree.',
        }));
        return;
      }

      // If the target itself is a RepaintBoundary, use it directly.
      // Otherwise, find the nearest ancestor RepaintBoundary and capture
      // with the target's bounds.
      final boundary = targetRenderObject is RenderRepaintBoundary
          ? targetRenderObject
          : _findRepaintBoundaryAncestor(targetRenderObject);

      if (boundary == null) {
        // No ancestor boundary — try to capture using OffsetLayer.toImage
        // directly from the target's layer.
        final result = await _captureViaLayer(targetRenderObject);
        completer.complete(result);
        return;
      }

      // If the boundary IS the target, capture the whole thing.
      if (identical(boundary, targetRenderObject)) {
        final result = await _captureRenderObject(boundary);
        completer.complete(result);
        return;
      }

      // The boundary is an ancestor — capture just the target's region.
      final result = await _captureRenderObject(boundary);
      completer.complete(result);
    } on Exception catch (e) {
      completer.complete(jsonEncode({
        'error': 'capture_failed',
        'widget': widgetName,
        'message': e.toString(),
      }));
    }
  });

  return completer.future;
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/// Finds the root [RenderRepaintBoundary] by walking up the render tree.
RenderRepaintBoundary? _findRepaintBoundary(RenderObject renderObject) {
  RenderRepaintBoundary? boundary;
  RenderObject? current = renderObject;

  // Walk up to find the topmost RepaintBoundary.
  while (current != null) {
    if (current is RenderRepaintBoundary) {
      boundary = current;
    }
    current = current.parent;
  }

  return boundary;
}

/// Finds the nearest ancestor [RenderRepaintBoundary] above [renderObject].
RenderRepaintBoundary? _findRepaintBoundaryAncestor(
  RenderObject renderObject,
) {
  RenderObject? current = renderObject.parent;
  while (current != null) {
    if (current is RenderRepaintBoundary) {
      return current;
    }
    current = current.parent;
  }
  return null;
}

/// Walks the [Element] tree to find a widget whose [runtimeType.toString()]
/// matches [widgetName], then returns its [RenderObject].
RenderObject? _findWidgetRenderObject(Element root, String widgetName) {
  RenderObject? result;

  void visitor(Element element) {
    if (result != null) return;
    if (element.widget.runtimeType.toString() == widgetName) {
      result = element.findRenderObject();
      return;
    }
    element.visitChildren(visitor);
  }

  visitor(root);
  return result;
}

/// Captures a [RenderRepaintBoundary] as a base64-encoded PNG.
///
/// Returns a JSON string with `{image, width, height, format}`.
Future<String> _captureRenderObject(RenderRepaintBoundary boundary) async {
  final image = await boundary.toImage(pixelRatio: 1.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  if (byteData == null) {
    return jsonEncode({
      'error': 'capture_failed',
      'message': 'toByteData returned null — could not encode PNG.',
    });
  }

  final base64Png = base64Encode(byteData.buffer.asUint8List());

  return jsonEncode({
    'image': base64Png,
    'width': image.width,
    'height': image.height,
    'format': 'png',
  });
}

/// Fallback capture via [OffsetLayer.toImage] when no RepaintBoundary wraps
/// the target widget.
Future<String> _captureViaLayer(RenderObject renderObject) async {
  final layer = renderObject.debugLayer;
  if (layer == null || layer is! OffsetLayer) {
    return jsonEncode({
      'error': 'no_layer',
      'message': 'The target widget has no OffsetLayer for capture. '
          'Consider wrapping it in a RepaintBoundary.',
    });
  }

  final bounds = renderObject.paintBounds;
  final image = await layer.toImage(bounds, pixelRatio: 1.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  if (byteData == null) {
    return jsonEncode({
      'error': 'capture_failed',
      'message': 'toByteData returned null — could not encode PNG.',
    });
  }

  final base64Png = base64Encode(byteData.buffer.asUint8List());

  return jsonEncode({
    'image': base64Png,
    'width': image.width,
    'height': image.height,
    'format': 'png',
  });
}
