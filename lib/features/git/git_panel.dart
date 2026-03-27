/// Git status panel showing branch, changed files, and recent commits.
///
/// Displayed in the right panel's "Git" section. Shows:
/// - Current branch name with ahead/behind counts
/// - Changed file list with +N/-M line stats (grouped by status)
/// - Recent commits with author and relative time
///
/// When the project has no local path, shows the "Choose local path" prompt.
/// When the path is not a git repo, shows a "Not a git repository" message.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/theme/app_theme.dart';
import 'package:qdexcode_desktop/features/git/git_provider.dart';
import 'package:qdexcode_desktop/features/git/git_service.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

/// The main git panel widget for the right sidebar.
class GitPanel extends ConsumerWidget {
  const GitPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(selectedProjectProvider);

    return projectAsync.when(
      loading: () => const _SkeletonLoading(),
      error: (_, _) => const _MessagePanel(
        icon: Icons.error_outline,
        message: 'Failed to load project',
      ),
      data: (project) {
        if (project == null) {
          return const _MessagePanel(
            icon: Icons.folder_off_outlined,
            message: 'No project selected',
          );
        }

        final localPath = project.localPath;
        if (localPath == null || localPath.isEmpty) {
          return const _NoLocalPathPanel();
        }

        return _GitStatusContent(key: ValueKey(project.id));
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Git status content (has local path)
// ---------------------------------------------------------------------------

class _GitStatusContent extends ConsumerWidget {
  const _GitStatusContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gitAsync = ref.watch(gitStatusProvider);

    return gitAsync.when(
      loading: () => const _SkeletonLoading(),
      error: (error, _) => _MessagePanel(
        icon: Icons.error_outline,
        message: 'Git error: $error',
      ),
      data: (gitState) {
        if (gitState == null) {
          return const _MessagePanel(
            icon: Icons.folder_off_outlined,
            message: 'No local path configured',
          );
        }

        if (gitState.repoCheck == GitRepoCheck.notARepo) {
          return const _MessagePanel(
            icon: Icons.warning_amber_rounded,
            message: 'Not a git repository',
          );
        }

        if (gitState.repoCheck == GitRepoCheck.pathNotFound) {
          return const _MessagePanel(
            icon: Icons.folder_off_outlined,
            message: 'Local path not found',
          );
        }

        return Column(
          children: [
            // Branch header with refresh button.
            _BranchHeader(
              branch: gitState.status.branch,
              ahead: gitState.status.ahead,
              behind: gitState.status.behind,
              changeCount: gitState.status.changeCount,
              onRefresh: () =>
                  ref.read(gitStatusProvider.notifier).refresh(),
            ),

            // Changed files section.
            if (gitState.changedFilesWithStats.isNotEmpty)
              Expanded(
                flex: 3,
                child: _ChangedFileList(
                  files: gitState.changedFilesWithStats,
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: _MessagePanel(
                  icon: Icons.check_circle_outline,
                  message: 'Working tree clean',
                  compact: true,
                ),
              ),

            // Recent commits section.
            if (gitState.commits.isNotEmpty)
              Expanded(
                flex: 2,
                child: _CommitList(commits: gitState.commits),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Branch header
// ---------------------------------------------------------------------------

class _BranchHeader extends StatelessWidget {
  const _BranchHeader({
    required this.branch,
    required this.ahead,
    required this.behind,
    required this.changeCount,
    required this.onRefresh,
  });

  final String branch;
  final int ahead;
  final int behind;
  final int changeCount;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cs.outline, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.fork_right_rounded, size: 14, color: cs.onTertiary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              branch.isNotEmpty ? branch : 'HEAD',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Ahead/behind badges.
          if (ahead > 0)
            _CountBadge(
              icon: Icons.arrow_upward,
              count: ahead,
              color: AppTheme.info,
            ),
          if (behind > 0)
            _CountBadge(
              icon: Icons.arrow_downward,
              count: behind,
              color: AppTheme.warning,
            ),

          // Change count badge.
          if (changeCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$changeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.info,
                  ),
                ),
              ),
            ),

          // Refresh button.
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 13),
              padding: EdgeInsets.zero,
              splashRadius: 12,
              tooltip: 'Refresh git status',
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.icon,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 1),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Changed file list
// ---------------------------------------------------------------------------

class _ChangedFileList extends StatelessWidget {
  const _ChangedFileList({required this.files});

  final List<GitChangedFile> files;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'CHANGES',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onTertiary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Virtualized file list.
        Expanded(
          child: ListView.builder(
            itemCount: files.length,
            itemExtent: 28,
            itemBuilder: (context, index) =>
                _ChangedFileRow(file: files[index]),
          ),
        ),
      ],
    );
  }
}

class _ChangedFileRow extends StatefulWidget {
  const _ChangedFileRow({required this.file});

  final GitChangedFile file;

  @override
  State<_ChangedFileRow> createState() => _ChangedFileRowState();
}

class _ChangedFileRowState extends State<_ChangedFileRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final file = widget.file;

    final statusColor = _statusColor(file.status);
    final fileName = file.path.split('/').last;
    final dirPath = file.path.contains('/')
        ? file.path.substring(0, file.path.lastIndexOf('/'))
        : '';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: _hovered ? cs.secondary : Colors.transparent,
        child: Row(
          children: [
            // Status indicator.
            SizedBox(
              width: 16,
              child: Text(
                file.status.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),

            // File icon.
            Icon(
              _fileIcon(file.status),
              size: 14,
              color: statusColor.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),

            // File name + directory.
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      fileName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (dirPath.isNotEmpty)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          dirPath,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: cs.onTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // +/- stats.
            if (file.additions > 0 || file.deletions > 0) ...[
              const SizedBox(width: 4),
              if (file.additions > 0)
                Text(
                  '+${file.additions}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.success,
                    fontFamily: 'monospace',
                  ),
                ),
              if (file.additions > 0 && file.deletions > 0)
                const SizedBox(width: 2),
              if (file.deletions > 0)
                Text(
                  '-${file.deletions}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.danger,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(GitFileStatus status) => switch (status) {
        GitFileStatus.modified => AppTheme.info,
        GitFileStatus.added => AppTheme.success,
        GitFileStatus.deleted => AppTheme.danger,
        GitFileStatus.renamed => AppTheme.warning,
        GitFileStatus.copied => AppTheme.info,
        GitFileStatus.untracked => AppTheme.success,
        GitFileStatus.unknown => AppTheme.warning,
      };

  IconData _fileIcon(GitFileStatus status) => switch (status) {
        GitFileStatus.modified => Icons.edit_outlined,
        GitFileStatus.added => Icons.add_circle_outline,
        GitFileStatus.deleted => Icons.remove_circle_outline,
        GitFileStatus.renamed => Icons.drive_file_rename_outline,
        GitFileStatus.copied => Icons.copy_outlined,
        GitFileStatus.untracked => Icons.help_outline,
        GitFileStatus.unknown => Icons.help_outline,
      };
}

// ---------------------------------------------------------------------------
// Commit list
// ---------------------------------------------------------------------------

class _CommitList extends StatelessWidget {
  const _CommitList({required this.commits});

  final List<GitCommit> commits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Separator.
        Divider(height: 1, color: cs.outline),

        // Section label.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'RECENT COMMITS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onTertiary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Virtualized commit list.
        Expanded(
          child: ListView.builder(
            itemCount: commits.length,
            itemExtent: 36,
            itemBuilder: (context, index) =>
                _CommitRow(commit: commits[index]),
          ),
        ),
      ],
    );
  }
}

class _CommitRow extends StatefulWidget {
  const _CommitRow({required this.commit});

  final GitCommit commit;

  @override
  State<_CommitRow> createState() => _CommitRowState();
}

class _CommitRowState extends State<_CommitRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final commit = widget.commit;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        color: _hovered ? cs.secondary : Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Subject line.
            Text(
              commit.subject,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            // Author + time.
            Row(
              children: [
                Text(
                  commit.shortHash,
                  style: TextStyle(
                    fontSize: 10,
                    color: cs.onTertiary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${commit.author} \u2022 ${commit.relativeTime}',
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper panels
// ---------------------------------------------------------------------------

class _NoLocalPathPanel extends StatelessWidget {
  const _NoLocalPathPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 24,
              color: cs.onTertiary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'No local path',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onTertiary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Set a local path in project settings\nto enable git status.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onTertiary.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.message,
    this.compact = false,
  });

  final IconData icon;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 8 : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 18 : 24,
              color: cs.onTertiary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onTertiary.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading
// ---------------------------------------------------------------------------

class _SkeletonLoading extends StatelessWidget {
  const _SkeletonLoading();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch skeleton.
          _SkeletonBar(width: 80, height: 14, color: cs.tertiary),
          const SizedBox(height: 12),
          // File skeletons.
          for (var i = 0; i < 4; i++) ...[
            _SkeletonBar(
              width: 120 + (i * 20).toDouble(),
              height: 10,
              color: cs.tertiary,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
