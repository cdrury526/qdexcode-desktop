import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// Provides the [GoRouter] instance for the application.
///
/// Routes will be expanded as features are built:
/// - `/login` — auth gate (Phase 1)
/// - `/` — main 3-panel layout (Phase 2)
/// - `/projects/:id` — project detail (Phase 3)
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _PlaceholderHome(),
      ),
    ],
  );
}

/// Temporary home screen until the 3-panel layout is implemented.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.code_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'qdexcode',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Desktop app scaffold ready',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
