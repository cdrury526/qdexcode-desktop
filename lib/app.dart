import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/router/app_router.dart';
import 'package:qdexcode_desktop/core/theme/app_theme.dart';

/// Root application widget.
///
/// Wraps the MaterialApp.router with Riverpod providers,
/// go_router navigation, and light/dark theme support.
class QdexcodeApp extends ConsumerWidget {
  const QdexcodeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'qdexcode',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
