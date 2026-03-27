/// Onboarding page — guided first-launch experience.
///
/// Shows a 3-step flow:
/// 1. Welcome screen with branding and 'Get Started'
/// 2. GitHub identity confirmation
/// 3. Add first project
///
/// After the user adds their first project, transitions to the main app.
/// Detection: shown when GET /api/projects returns an empty list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/features/onboarding/add_project_step.dart';
import 'package:qdexcode_desktop/features/onboarding/github_step.dart';
import 'package:qdexcode_desktop/features/onboarding/welcome_step.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

/// Full-screen onboarding flow for first-time users.
///
/// Uses a [PageView] with custom page transitions (fade + slide) for
/// smooth step-to-step navigation. Each step is a centered card.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  int _currentStep = 0;
  static const _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _totalSteps) return;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  void _onProjectAdded() {
    // Refresh the project list — the router will detect the non-empty
    // list and redirect away from onboarding automatically.
    ref.invalidate(projectListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background subtle gradient.
          _BackgroundDecoration(colorScheme: cs),

          // Page content.
          SafeArea(
            child: Column(
              children: [
                // Top spacing.
                const SizedBox(height: 24),

                // Step indicator dots.
                _StepIndicator(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                  colorScheme: cs,
                ),

                // Pages.
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentStep = index);
                    },
                    children: [
                      WelcomeStep(
                        onContinue: () => _goToStep(1),
                      ),
                      GitHubStep(
                        onContinue: () => _goToStep(2),
                      ),
                      AddProjectStep(
                        onProjectAdded: _onProjectAdded,
                      ),
                    ],
                  ),
                ),

                // Bottom navigation hints.
                _BottomHints(
                  currentStep: _currentStep,
                  onBack: _currentStep > 0
                      ? () => _goToStep(_currentStep - 1)
                      : null,
                  colorScheme: cs,
                  theme: theme,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step indicator dots
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.colorScheme,
  });

  final int currentStep;
  final int totalSteps;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary
                    : isCompleted
                        ? colorScheme.primary.withValues(alpha: 0.4)
                        : colorScheme.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Background decoration
// ---------------------------------------------------------------------------

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              colorScheme.primary.withValues(alpha: 0.03),
              colorScheme.surface,
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation hints
// ---------------------------------------------------------------------------

class _BottomHints extends StatelessWidget {
  const _BottomHints({
    required this.currentStep,
    required this.onBack,
    required this.colorScheme,
    required this.theme,
  });

  final int currentStep;
  final VoidCallback? onBack;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: currentStep > 0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onBack != null)
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onTertiary,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
