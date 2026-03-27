/// Local path selector for the Add Project dialog (step 2).
///
/// Two modes: "Clone locally" or "Use existing checkout".
/// Validates the selected path against the expected repo clone URL.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:qdexcode_desktop/core/theme/app_theme.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

/// Validation result for an existing checkout path.
enum PathValidation {
  /// Not yet validated.
  none,

  /// Path matches the expected repo (git remote matches clone URL).
  valid,

  /// Path exists but does not match the expected repo.
  mismatch,

  /// Path does not exist or is not a git repo.
  invalid,

  /// Validation is in progress.
  checking,
}

/// Step 2 of Add Project: choose how to connect a local path.
///
/// Mode A: Clone to a new directory.
/// Mode B: Point to an existing checkout (validated against the repo URL).
class LocalPathSelector extends StatefulWidget {
  const LocalPathSelector({
    required this.repo,
    required this.onPathSelected,
    super.key,
  });

  final GitHubRepo repo;

  /// Called when the user confirms a valid local path.
  /// [path] is the directory, [shouldClone] is true for Mode A.
  final void Function(String path, bool shouldClone) onPathSelected;

  @override
  State<LocalPathSelector> createState() => _LocalPathSelectorState();
}

class _LocalPathSelectorState extends State<LocalPathSelector> {
  _Mode _mode = _Mode.clone;
  String _clonePath = '';
  String _existingPath = '';
  PathValidation _validation = PathValidation.none;
  String _validationMessage = '';

  @override
  void initState() {
    super.initState();
    _clonePath = _defaultClonePath;
  }

  @override
  void didUpdateWidget(LocalPathSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repo.name != widget.repo.name) {
      _clonePath = _defaultClonePath;
      _existingPath = '';
      _validation = PathValidation.none;
    }
  }

  String get _defaultClonePath {
    final home = Platform.environment['HOME'] ?? '/tmp';
    return '$home/Projects/${widget.repo.name}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Repo summary banner.
        _RepoBanner(repo: widget.repo),
        const SizedBox(height: 16),

        // Mode selector tabs.
        _ModeSelector(
          mode: _mode,
          onModeChanged: (mode) => setState(() {
            _mode = mode;
            _validation = PathValidation.none;
          }),
        ),
        const SizedBox(height: 16),

        // Mode-specific content.
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _mode == _Mode.clone
                ? _CloneContent(
                    key: const ValueKey('clone'),
                    path: _clonePath,
                    onPathChanged: (path) =>
                        setState(() => _clonePath = path),
                    onBrowse: _browseCloneDirectory,
                    onConfirm: () =>
                        widget.onPathSelected(_clonePath, true),
                  )
                : _ExistingContent(
                    key: const ValueKey('existing'),
                    path: _existingPath,
                    validation: _validation,
                    validationMessage: _validationMessage,
                    onBrowse: _browseExistingDirectory,
                    onConfirm: _validation == PathValidation.valid
                        ? () =>
                            widget.onPathSelected(_existingPath, false)
                        : null,
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _browseCloneDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose clone location',
      initialDirectory: _clonePath,
    );
    if (result != null && mounted) {
      setState(() {
        _clonePath = '$result/${widget.repo.name}';
      });
    }
  }

  Future<void> _browseExistingDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select existing checkout',
    );
    if (result != null && mounted) {
      setState(() {
        _existingPath = result;
        _validation = PathValidation.checking;
      });
      await _validateExistingPath(result);
    }
  }

  Future<void> _validateExistingPath(String path) async {
    try {
      // Check if .git directory exists.
      final gitDir = Directory('$path/.git');
      if (!await gitDir.exists()) {
        if (mounted) {
          setState(() {
            _validation = PathValidation.invalid;
            _validationMessage = 'Not a git repository (no .git directory)';
          });
        }
        return;
      }

      // Check if remote matches.
      final result = await Process.run(
        'git',
        ['remote', 'get-url', 'origin'],
        workingDirectory: path,
      );

      if (result.exitCode != 0) {
        if (mounted) {
          setState(() {
            _validation = PathValidation.invalid;
            _validationMessage = 'Could not read git remote';
          });
        }
        return;
      }

      final remoteUrl = (result.stdout as String).trim();
      final normalizedRemote = _normalizeGitUrl(remoteUrl);
      final normalizedExpected = _normalizeGitUrl(widget.repo.cloneUrl);

      if (normalizedRemote == normalizedExpected) {
        if (mounted) {
          setState(() {
            _validation = PathValidation.valid;
            _validationMessage = 'Remote matches: $remoteUrl';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _validation = PathValidation.mismatch;
            _validationMessage =
                'Remote mismatch.\nExpected: ${widget.repo.cloneUrl}\nFound: $remoteUrl';
          });
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _validation = PathValidation.invalid;
          _validationMessage = 'Validation error: $e';
        });
      }
    }
  }

  String _normalizeGitUrl(String url) {
    var normalized = url.toLowerCase().trim();
    normalized = normalized.replaceFirst(RegExp(r'^https?://'), '');
    normalized = normalized.replaceFirst(RegExp(r'^git@([^:]+):'), r'$1/');
    normalized = normalized.replaceFirst(RegExp(r'\.git$'), '');
    return normalized;
  }
}

// ---------------------------------------------------------------------------
// Mode enum + selector
// ---------------------------------------------------------------------------

enum _Mode { clone, existing }

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.mode,
    required this.onModeChanged,
  });

  final _Mode mode;
  final ValueChanged<_Mode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ModeTab(
          label: 'Clone locally',
          icon: Icons.download_rounded,
          isActive: mode == _Mode.clone,
          onTap: () => onModeChanged(_Mode.clone),
        ),
        const SizedBox(width: 8),
        _ModeTab(
          label: 'Use existing checkout',
          icon: Icons.folder_open_rounded,
          isActive: mode == _Mode.existing,
          onTap: () => onModeChanged(_Mode.existing),
        ),
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: Material(
        color: isActive
            ? cs.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive ? cs.primary : cs.outline,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? cs.primary : cs.onTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? cs.primary : cs.onTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Repo summary banner
// ---------------------------------------------------------------------------

class _RepoBanner extends StatelessWidget {
  const _RepoBanner({required this.repo});

  final GitHubRepo repo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.code_rounded, size: 18, color: cs.onTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  repo.fullName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Branch: ${repo.defaultBranch}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (repo.language != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: cs.tertiary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                repo.language!,
                style: TextStyle(fontSize: 10, color: cs.onTertiary),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Clone content (Mode A)
// ---------------------------------------------------------------------------

class _CloneContent extends StatelessWidget {
  const _CloneContent({
    required this.path,
    required this.onPathChanged,
    required this.onBrowse,
    required this.onConfirm,
    super.key,
  });

  final String path;
  final ValueChanged<String> onPathChanged;
  final VoidCallback onBrowse;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clone directory',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: TextEditingController(text: path),
                  onChanged: onPathChanged,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: '~/Projects/repo-name',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    prefixIcon: Icon(Icons.folder_rounded, size: 16),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 34,
                      minHeight: 34,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: onBrowse,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Browse...',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'The repo will be cloned to this directory using git clone.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Existing checkout content (Mode B)
// ---------------------------------------------------------------------------

class _ExistingContent extends StatelessWidget {
  const _ExistingContent({
    required this.path,
    required this.validation,
    required this.validationMessage,
    required this.onBrowse,
    this.onConfirm,
    super.key,
  });

  final String path;
  final PathValidation validation;
  final String validationMessage;
  final VoidCallback onBrowse;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select directory',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),

        // Path display + browse button.
        Row(
          children: [
            Expanded(
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: cs.outline),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  path.isEmpty ? 'No directory selected' : path,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: path.isEmpty ? cs.onTertiary : cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: onBrowse,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Browse...',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Validation banner.
        if (validation != PathValidation.none) _ValidationBanner(
          validation: validation,
          message: validationMessage,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Validation banner
// ---------------------------------------------------------------------------

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({
    required this.validation,
    required this.message,
  });

  final PathValidation validation;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, color, bgColor) = switch (validation) {
      PathValidation.valid => (
          Icons.check_circle_rounded,
          AppTheme.success,
          AppTheme.success.withValues(alpha: 0.1),
        ),
      PathValidation.mismatch => (
          Icons.warning_rounded,
          AppTheme.warning,
          AppTheme.warning.withValues(alpha: 0.1),
        ),
      PathValidation.invalid => (
          Icons.error_rounded,
          AppTheme.danger,
          AppTheme.danger.withValues(alpha: 0.1),
        ),
      PathValidation.checking => (
          Icons.hourglass_top_rounded,
          AppTheme.info,
          AppTheme.info.withValues(alpha: 0.1),
        ),
      PathValidation.none => (
          Icons.info_rounded,
          theme.colorScheme.onTertiary,
          Colors.transparent,
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(validation),
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (validation == PathValidation.checking)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                validation == PathValidation.checking
                    ? 'Validating...'
                    : message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
