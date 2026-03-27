/// Welcome step — first screen in the onboarding flow.
///
/// Shows the qdexcode branding, a brief tagline, and a 'Get Started'
/// button that advances to the next step.
library;

import 'package:flutter/material.dart';

/// Callback type for advancing to the next onboarding step.
typedef OnContinue = void Function();

/// Full-screen centered welcome card with branding and CTA.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onContinue});

  final OnContinue onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo / icon.
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.data_object_rounded,
                size: 32,
                color: cs.onPrimary,
              ),
            ),

            const SizedBox(height: 28),

            // Title.
            Text(
              'Welcome to qdexcode',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 12),

            // Tagline.
            Text(
              'Code intelligence for your entire codebase.\n'
              'Index, search, and navigate with AI-powered tools.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onTertiary, // muted foreground
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // CTA button.
            SizedBox(
              width: 200,
              height: 44,
              child: ElevatedButton(
                onPressed: onContinue,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Get Started', style: TextStyle(fontSize: 15)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
