/// Add Project dialog — 2-step flow matching V1 Wails app.
///
/// Step 1: GitHub repo picker (select a repo to index).
/// Step 2: Local path selector (clone or use existing checkout).
/// On submit: POST /api/projects, optionally git clone, refresh project list.
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/theme/app_theme.dart';
import 'package:qdexcode_desktop/features/projects/github_repo_picker.dart';
import 'package:qdexcode_desktop/features/projects/local_path_selector.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

/// Two-step dialog for adding a new project.
///
/// Matches the V1 design: first pick a GitHub repo, then choose a local path.
class AddProjectDialog extends ConsumerStatefulWidget {
  const AddProjectDialog({super.key});

  @override
  ConsumerState<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends ConsumerState<AddProjectDialog> {
  int _step = 0;
  GitHubRepo? _selectedRepo;
  String? _localPath;
  bool _shouldClone = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dialog(
      backgroundColor: cs.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outline),
      ),
      child: SizedBox(
        width: 520,
        height: 480,
        child: Column(
          children: [
            // Header.
            _DialogHeader(
              step: _step,
              onBack: _step > 0 ? _goBack : null,
            ),

            const Divider(height: 1),

            // Content.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _step == 0
                      ? GitHubRepoPicker(
                          key: const ValueKey('step0'),
                          selectedRepo: _selectedRepo,
                          onSelect: (repo) {
                            setState(() {
                              _selectedRepo = repo;
                            });
                          },
                        )
                      : LocalPathSelector(
                          key: const ValueKey('step1'),
                          repo: _selectedRepo!,
                          onPathSelected: (path, shouldClone) {
                            setState(() {
                              _localPath = path;
                              _shouldClone = shouldClone;
                            });
                          },
                        ),
                ),
              ),
            ),

            // Error message.
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ErrorBanner(
                  message: _errorMessage!,
                  onDismiss: () => setState(() => _errorMessage = null),
                ),
              ),

            const Divider(height: 1),

            // Footer with actions.
            _DialogFooter(
              step: _step,
              canAdvance: _canAdvance,
              isSubmitting: _isSubmitting,
              onCancel: () => Navigator.of(context).pop(),
              onNext: _step == 0 ? _goToStep2 : null,
              onSubmit: _step == 1 ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }

  bool get _canAdvance {
    if (_step == 0) return _selectedRepo != null;
    if (_step == 1) return _localPath != null && _localPath!.isNotEmpty;
    return false;
  }

  void _goToStep2() {
    if (_selectedRepo == null) return;
    setState(() {
      _step = 1;
      _errorMessage = null;
    });
  }

  void _goBack() {
    setState(() {
      _step = 0;
      _localPath = null;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (_selectedRepo == null || _localPath == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Step A: Clone if needed.
      if (_shouldClone) {
        final cloneResult = await Process.run(
          'git',
          ['clone', _selectedRepo!.cloneUrl, _localPath!],
        );

        if (cloneResult.exitCode != 0) {
          final stderr = (cloneResult.stderr as String).trim();
          setState(() {
            _isSubmitting = false;
            _errorMessage = 'Clone failed: $stderr';
          });
          return;
        }
      }

      // Step B: Create project via API.
      await ref.read(projectActionsProvider.notifier).create(
            name: _selectedRepo!.name,
            cloneUrl: _selectedRepo!.cloneUrl,
            defaultBranch: _selectedRepo!.defaultBranch,
            localPath: _localPath,
          );

      // Success — close dialog.
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = switch (statusCode) {
        409 => 'This project already exists.',
        429 => 'Project limit reached. Please delete a project first.',
        _ => e.response?.data?['error']?.toString() ??
            e.message ??
            'Network error',
      };

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = message;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Dialog header
// ---------------------------------------------------------------------------

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.step, this.onBack});

  final int step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          if (onBack != null) ...[
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                padding: EdgeInsets.zero,
                tooltip: 'Back to repo selection',
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              step == 0 ? 'Add Project' : 'Choose Local Path',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          // Step indicator.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: cs.tertiary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Step ${step + 1} of 2',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: cs.onTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog footer
// ---------------------------------------------------------------------------

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({
    required this.step,
    required this.canAdvance,
    required this.isSubmitting,
    required this.onCancel,
    this.onNext,
    this.onSubmit,
  });

  final int step;
  final bool canAdvance;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: isSubmitting ? null : onCancel,
            child: const Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
          if (step == 0)
            ElevatedButton(
              onPressed: canAdvance ? onNext : null,
              child: const Text('Next', style: TextStyle(fontSize: 13)),
            )
          else
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: canAdvance && !isSubmitting ? onSubmit : null,
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Add Project',
                        style: TextStyle(fontSize: 13),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error banner
// ---------------------------------------------------------------------------

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: AppTheme.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.danger,
                fontSize: 12,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              onPressed: onDismiss,
              icon: const Icon(
                Icons.close_rounded,
                size: 14,
                color: AppTheme.danger,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
