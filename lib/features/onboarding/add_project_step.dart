/// Add project step — final screen in the onboarding flow.
///
/// Wraps the existing [AddProjectDialog] content in an onboarding-friendly
/// layout. When the user successfully adds their first project, calls
/// [onProjectAdded] to complete onboarding.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/features/projects/add_project_dialog.dart';

/// Embeds the Add Project flow within the onboarding page.
///
/// Rather than showing a dialog, this renders the full Add Project content
/// inline as a card. Listens for project creation success to complete
/// the onboarding flow.
class AddProjectStep extends ConsumerStatefulWidget {
  const AddProjectStep({super.key, required this.onProjectAdded});

  final VoidCallback onProjectAdded;

  @override
  ConsumerState<AddProjectStep> createState() => _AddProjectStepState();
}

class _AddProjectStepState extends ConsumerState<AddProjectStep> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section header.
            Icon(
              Icons.rocket_launch_outlined,
              size: 40,
              color: cs.primary,
            ),

            const SizedBox(height: 20),

            Text(
              'Add Your First Project',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Select a GitHub repository to index. You can add more later.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onTertiary,
              ),
            ),

            const SizedBox(height: 28),

            // Embedded add-project card — opens the dialog.
            _AddProjectCard(onProjectAdded: widget.onProjectAdded),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add project card — click to open the dialog
// ---------------------------------------------------------------------------

class _AddProjectCard extends StatelessWidget {
  const _AddProjectCard({required this.onProjectAdded});

  final VoidCallback onProjectAdded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openAddProjectDialog(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 24,
                  color: cs.primary,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Choose a Repository',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Browse your GitHub repos and select one to index',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAddProjectDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const AddProjectDialog(),
    );

    // After the dialog closes, check if a project was actually added.
    // The caller (OnboardingPage) watches the project list provider and
    // will auto-detect the new project. We trigger the callback regardless
    // — the onboarding page checks for a non-empty project list.
    if (context.mounted) {
      onProjectAdded();
    }
  }
}
