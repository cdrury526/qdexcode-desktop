import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'package:qdexcode_desktop/core/api/api_client.dart';
import 'package:qdexcode_desktop/core/auth/auth_provider.dart';
import 'package:qdexcode_desktop/core/router/app_router.dart';
import 'package:qdexcode_desktop/core/state/window_state_provider.dart';
import 'package:qdexcode_desktop/core/state/window_state_service.dart';
import 'package:qdexcode_desktop/core/theme/app_theme.dart';
import 'package:qdexcode_desktop/core/theme/theme_provider.dart';
import 'package:qdexcode_desktop/core/widgets/splash_screen.dart';
import 'package:qdexcode_desktop/services/devtools_server.dart';

/// Root application widget.
///
/// Shows a branded splash screen on launch while Riverpod providers
/// initialize, then crossfades into the routed app content.
/// Listens to window events to persist geometry changes.
class QdexcodeApp extends ConsumerStatefulWidget {
  const QdexcodeApp({super.key});

  @override
  ConsumerState<QdexcodeApp> createState() => _QdexcodeAppState();
}

class _QdexcodeAppState extends ConsumerState<QdexcodeApp>
    with WindowStateListener {
  /// Completer that resolves once the initial auth check finishes.
  final Completer<void> _initCompleter = Completer<void>();

  /// Embedded MCP devtools server — debug mode only.
  DevtoolsServer? _devtoolsServer;

  @override
  WidgetRef get windowRef => ref;

  @override
  void initState() {
    super.initState();
    _runInitialization();
    initWindowListener();
    _startDevtoolsServer();
  }

  @override
  void dispose() {
    _devtoolsServer?.stop();
    disposeWindowListener();
    super.dispose();
  }

  /// Start the embedded MCP devtools server in debug mode only.
  void _startDevtoolsServer() {
    if (!kDebugMode) return;

    _devtoolsServer = DevtoolsServer(
      containerProvider: () =>
          ProviderScope.containerOf(context, listen: false),
      routerProvider: () => ref.read(routerProvider),
      dioProvider: () => ref.read(apiClientProvider),
      contextProvider: () => mounted ? context : null,
    );
    _devtoolsServer!.start();
  }

  Future<void> _runInitialization() async {
    // Restore saved window geometry on launch.
    await _restoreWindowGeometry();

    // Wait until the auth provider resolves from its initial AuthLoading
    // state. The auth notifier's build() kicks off _restoreSession()
    // automatically, so we just need to wait for it to settle.
    //
    // We listen once for a non-loading state, then complete the splash.
    ref.listenManual(authProvider, (previous, next) {
      if (next is! AuthLoading && !_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    });
  }

  Future<void> _restoreWindowGeometry() async {
    final geometry =
        ref.read(windowGeometryStateProvider);
    // Only apply if non-default (i.e., previously persisted values loaded).
    // The provider loads async, so also try the service directly for first launch.
    final service = ref.read(windowStateServiceProvider);
    final saved = await service.loadGeometry();
    if (saved != WindowGeometry.defaultValue) {
      await windowManager.setPosition(saved.position);
      await windowManager.setSize(saved.size);
    } else if (geometry != WindowGeometry.defaultValue) {
      await windowManager.setPosition(geometry.position);
      await windowManager.setSize(geometry.size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themePreferenceProvider);

    final app = MaterialApp.router(
      title: 'qdexcode',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );

    return SplashScreen(
      onInitComplete: _initCompleter.future,
      child: app,
    );
  }
}
