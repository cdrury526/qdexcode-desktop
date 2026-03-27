import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';

import 'package:qdexcode_desktop/core/state/window_state_service.dart';

part 'window_state_provider.g.dart';

/// Provides the [WindowStateService] singleton.
@Riverpod(keepAlive: true)
WindowStateService windowStateService(Ref ref) {
  return const WindowStateService();
}

/// Manages window geometry (position + size) with debounced persistence.
///
/// Loads the saved geometry on build, and exposes [update] for the
/// window listener to call on move/resize. Saves are debounced to avoid
/// writing on every pixel of a drag.
@Riverpod(keepAlive: true)
class WindowGeometryState extends _$WindowGeometryState {
  Timer? _debounce;

  @override
  WindowGeometry build() {
    _loadSaved();
    ref.onDispose(() => _debounce?.cancel());
    return WindowGeometry.defaultValue;
  }

  Future<void> _loadSaved() async {
    final service = ref.read(windowStateServiceProvider);
    final saved = await service.loadGeometry();
    if (saved != state) {
      state = saved;
    }
  }

  /// Updates geometry from window events, debounced to 500ms.
  void update(WindowGeometry geometry) {
    state = geometry;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(windowStateServiceProvider).saveGeometry(geometry);
    });
  }
}

/// Manages panel width flex proportions with debounced persistence.
@Riverpod(keepAlive: true)
class PanelWidthsState extends _$PanelWidthsState {
  Timer? _debounce;

  @override
  PanelWidths build() {
    _loadSaved();
    ref.onDispose(() => _debounce?.cancel());
    return PanelWidths.defaultValue;
  }

  Future<void> _loadSaved() async {
    final service = ref.read(windowStateServiceProvider);
    final saved = await service.loadPanelWidths();
    if (saved != state) {
      state = saved;
    }
  }

  /// Updates panel widths, debounced to 300ms.
  void update(PanelWidths widths) {
    state = widths;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(windowStateServiceProvider).savePanelWidths(widths);
    });
  }
}

/// Manages the active center workspace tab with immediate persistence.
@Riverpod(keepAlive: true)
class ActiveTabState extends _$ActiveTabState {
  @override
  String build() {
    _loadSaved();
    return 'dashboard';
  }

  Future<void> _loadSaved() async {
    final service = ref.read(windowStateServiceProvider);
    final saved = await service.loadActiveTab();
    if (saved != null && saved != state) {
      state = saved;
    }
  }

  /// Sets the active tab and persists immediately.
  Future<void> setTab(String tabId) async {
    state = tabId;
    await ref.read(windowStateServiceProvider).saveActiveTab(tabId);
  }
}

/// Manages the selected project ID with immediate persistence.
@Riverpod(keepAlive: true)
class SelectedProjectState extends _$SelectedProjectState {
  @override
  String? build() {
    _loadSaved();
    return null;
  }

  Future<void> _loadSaved() async {
    final service = ref.read(windowStateServiceProvider);
    final saved = await service.loadSelectedProjectId();
    if (saved != state) {
      state = saved;
    }
  }

  /// Sets the selected project and persists.
  Future<void> setProject(String? projectId) async {
    state = projectId;
    await ref.read(windowStateServiceProvider).saveSelectedProjectId(projectId);
  }
}

/// Mixin for the app's root widget to listen to window events and
/// persist geometry changes.
///
/// Usage: mix into the State of the root widget and call
/// [initWindowListener] in initState, [disposeWindowListener] in dispose.
mixin WindowStateListener implements WindowListener {
  WidgetRef get windowRef;

  bool _isListening = false;

  void initWindowListener() {
    windowManager.addListener(this);
    _isListening = true;
  }

  void disposeWindowListener() {
    if (_isListening) {
      windowManager.removeListener(this);
      _isListening = false;
    }
  }

  Future<void> _persistCurrentGeometry() async {
    final position = await windowManager.getPosition();
    final size = await windowManager.getSize();
    final geometry = WindowGeometry(
      x: position.dx,
      y: position.dy,
      width: size.width,
      height: size.height,
    );
    windowRef.read(windowGeometryStateProvider.notifier).update(geometry);
  }

  @override
  void onWindowMoved() => _persistCurrentGeometry();

  @override
  void onWindowResized() => _persistCurrentGeometry();

  // Required by WindowListener but not needed for persistence.
  @override
  void onWindowBlur() {}
  @override
  void onWindowClose() {}
  @override
  void onWindowDocked() {}
  @override
  void onWindowEnterFullScreen() {}
  @override
  void onWindowEvent(String eventName) {}
  @override
  void onWindowFocus() {}
  @override
  void onWindowLeaveFullScreen() {}
  @override
  void onWindowMaximize() {}
  @override
  void onWindowMinimize() {}
  @override
  void onWindowMove() {}
  @override
  void onWindowResize() {}
  @override
  void onWindowRestore() {}
  @override
  void onWindowUndocked() {}
  @override
  void onWindowUnmaximize() {}
}
