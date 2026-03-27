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

/// Default pixel ratio for captures.
///
/// Lower values produce smaller images (fewer tokens for LLM consumption).
/// 0.5 = half resolution = ~25% of the pixel count = ~25% base64 size.
const _kDefaultPixelRatio = 0.5;

/// Handles the `capture` gateway tool call.
///
/// Dispatches to the appropriate command handler based on `args['command']`.
/// The [contextCallback] is invoked fresh on every call to ensure current
/// state.
///
/// All capture commands accept an optional `scale` arg (0.1–1.0) to control
/// the output resolution. Lower values produce smaller images.
Future<String> handleCapture({
  required Map<String, dynamic> args,
  required BuildContext? Function() contextCallback,
}) async {
  final command = args['command'] as String?;
  final commandArgs = args['args'] as Map<String, dynamic>? ?? const {};
  // Parse optional scale factor from args.
  final scaleArg = commandArgs['scale'];
  final pixelRatio = (scaleArg is num)
      ? scaleArg.toDouble().clamp(0.1, 1.0)
      : _kDefaultPixelRatio;

  return switch (command) {
    'screen' => _handleScreen(contextCallback, pixelRatio),
    'screen_widget' => _handleScreenWidget(commandArgs, contextCallback, pixelRatio),
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
  double pixelRatio,
) async {
  final completer = Completer<String>();

  Future.microtask(() async {
    try {
      // Use RendererBinding to get the root render view — this avoids
      // the RepaintBoundary search issue when context is above MaterialApp.
      final renderViews =
          RendererBinding.instance.renderViews.toList();
      if (renderViews.isEmpty) {
        completer.complete(jsonEncode({
          'error': 'no_render_view',
          'message': 'No render views available.',
        }));
        return;
      }

      final renderView = renderViews.first;
      final layer = renderView.debugLayer;
      if (layer == null || layer is! OffsetLayer) {
        completer.complete(jsonEncode({
          'error': 'no_layer',
          'message': 'Root render view has no OffsetLayer.',
        }));
        return;
      }

      final size = renderView.size;
      final image = await layer.toImage(
        Rect.fromLTWH(0, 0, size.width, size.height),
        pixelRatio: pixelRatio,
      );
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null) {
        completer.complete(jsonEncode({
          'error': 'capture_failed',
          'message': 'toByteData returned null.',
        }));
        return;
      }

      final base64Png = base64Encode(byteData.buffer.asUint8List());
      completer.complete(jsonEncode({
        'image': base64Png,
        'width': size.width.toInt(),
        'height': size.height.toInt(),
        'format': 'png',
      }));
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
  double pixelRatio,
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

  Future.microtask(() async {
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

      // Try capturing via RepaintBoundary first, then fall back to layer.
      if (targetRenderObject is RenderRepaintBoundary) {
        final result = await _captureRenderObject(targetRenderObject, pixelRatio);
        completer.complete(result);
        return;
      }

      // Try the layer approach — works for most widgets.
      final result = await _captureViaLayer(targetRenderObject, pixelRatio);
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
Future<String> _captureRenderObject(RenderRepaintBoundary boundary, [double pixelRatio = _kDefaultPixelRatio]) async {
  final image = await boundary.toImage(pixelRatio: pixelRatio);
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
Future<String> _captureViaLayer(RenderObject renderObject, [double pixelRatio = _kDefaultPixelRatio]) async {
  final layer = renderObject.debugLayer;
  if (layer == null || layer is! OffsetLayer) {
    return jsonEncode({
      'error': 'no_layer',
      'message': 'The target widget has no OffsetLayer for capture. '
          'Consider wrapping it in a RepaintBoundary.',
    });
  }

  final bounds = renderObject.paintBounds;
  final image = await layer.toImage(bounds, pixelRatio: pixelRatio);
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
