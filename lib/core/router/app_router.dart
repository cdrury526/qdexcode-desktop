import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:qdexcode_desktop/core/auth/auth_provider.dart';
import 'package:qdexcode_desktop/core/auth/login_page.dart';
import 'package:qdexcode_desktop/features/onboarding/onboarding_page.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';
import 'package:qdexcode_desktop/features/shell/shell_page.dart';

part 'app_router.g.dart';

/// Provides the [GoRouter] instance for the application.
///
/// The router handles three states:
/// - Unauthenticated -> `/login`
/// - Authenticated with no projects -> `/onboarding`
/// - Authenticated with projects -> `/`
///
/// Routes:
/// - `/login` -- auth gate (Phase 1)
/// - `/onboarding` -- first-launch guided flow (Phase 2)
/// - `/` -- main 3-panel layout (Phase 2)
/// - `/projects/:id` -- project detail (Phase 3)
@riverpod
GoRouter router(Ref ref) {
  // Listen to auth state changes to trigger route re-evaluation.
  final authState = ref.watch(authProvider);

  // Watch the project list to detect empty state for onboarding.
  // This is an AsyncValue — loading/error states are handled gracefully.
  final projectListAsync = ref.watch(projectListProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState is AuthAuthenticated;
      final isOnLogin = state.matchedLocation == '/login';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      // --- Auth guard ---

      // Not authenticated and not on login -> send to login.
      if (!isAuthenticated && !isOnLogin) {
        // Allow the loading state to pass through without redirect
        // so the splash screen can finish.
        if (authState is AuthLoading) return null;
        return '/login';
      }

      // Authenticated but on login -> send to home (or onboarding).
      if (isAuthenticated && isOnLogin) return '/';

      // --- Onboarding guard (only for authenticated users) ---

      if (isAuthenticated) {
        final projects = projectListAsync.valueOrNull;

        // While loading projects, don't redirect — let the current
        // page render (it will show loading state).
        if (projects == null) return null;

        final hasProjects = projects.isNotEmpty;

        // Authenticated, no projects, not on onboarding -> onboarding.
        if (!hasProjects && !isOnOnboarding && !isOnLogin) {
          return '/onboarding';
        }

        // Authenticated, has projects, stuck on onboarding -> home.
        if (hasProjects && isOnOnboarding) {
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const OnboardingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ShellPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
    ],
  );
}
