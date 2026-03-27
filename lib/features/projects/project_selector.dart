/// Project selector widget for the left panel.
///
/// Displays the current project with dual status indicators (index + git),
/// compact stats line, and a dropdown to switch between projects.
/// Includes a '+' button to open the Add Project dialog.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/models/project.dart';
import 'package:qdexcode_desktop/core/theme/app_theme.dart';
import 'package:qdexcode_desktop/features/projects/add_project_dialog.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

/// Compact project selector matching the V1 left-panel pattern.
///
/// Shows: project name, clone URL, dual status dots, stats line.
/// Tap the name area to open a dropdown of all projects.
class ProjectSelector extends ConsumerWidget {
  const ProjectSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAsync = ref.watch(selectedProjectProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: selectedAsync.when(
        loading: () => const _SelectorSkeleton(),
        error: (error, _) => _ErrorCard(error: error.toString()),
        data: (selected) {
          if (selected == null) {
            return _EmptyState(
              onAdd: () => _showAddProjectDialog(context),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Project name row with dropdown + add button.
              _ProjectNameRow(
                project: selected,
                projects: projectsAsync.valueOrNull ?? [],
                onSelect: (project) {
                  ref
                      .read(selectedProjectProvider.notifier)
                      .select(project);
                },
                onAdd: () => _showAddProjectDialog(context),
              ),

              const SizedBox(height: 2),

              // Clone URL.
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  _formatCloneUrl(selected.cloneUrl),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onTertiary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 6),

              // Status indicators + stats.
              _StatusRow(project: selected),
            ],
          );
        },
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const AddProjectDialog(),
    );
  }
}

// ---------------------------------------------------------------------------
// Project name row with dropdown
// ---------------------------------------------------------------------------

class _ProjectNameRow extends StatelessWidget {
  const _ProjectNameRow({
    required this.project,
    required this.projects,
    required this.onSelect,
    required this.onAdd,
  });

  final Project project;
  final List<Project> projects;
  final ValueChanged<Project> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Dropdown trigger.
        Expanded(
          child: _ProjectDropdownButton(
            current: project,
            projects: projects,
            onSelect: onSelect,
          ),
        ),
        const SizedBox(width: 4),
        // Add project button.
        SizedBox(
          width: 28,
          height: 28,
          child: IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.onTertiary,
              padding: EdgeInsets.zero,
            ),
            tooltip: 'Add project',
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dropdown button
// ---------------------------------------------------------------------------

class _ProjectDropdownButton extends StatelessWidget {
  const _ProjectDropdownButton({
    required this.current,
    required this.projects,
    required this.onSelect,
  });

  final Project current;
  final List<Project> projects;
  final ValueChanged<Project> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return PopupMenuButton<Project>(
      onSelected: onSelect,
      offset: const Offset(0, 34),
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cs.outline),
      ),
      color: cs.surfaceContainerHighest,
      itemBuilder: (context) {
        return projects.map((project) {
          final isSelected = project.id == current.id;
          return PopupMenuItem<Project>(
            value: project,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _IndexStatusDot(status: project.indexStatus, size: 8),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: cs.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                current.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.unfold_more_rounded,
              size: 16,
              color: cs.onTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status row — dual indicators + stats
// ---------------------------------------------------------------------------

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        children: [
          // Index status dot.
          Tooltip(
            message: _indexStatusTooltip(project.indexStatus),
            child: project.indexStatus == IndexStatus.indexing
                ? _AnimatedIndexingDot()
                : _IndexStatusDot(status: project.indexStatus, size: 10),
          ),
          const SizedBox(width: 8),

          // Git sync status dot (placeholder — needs git data).
          Tooltip(
            message: 'Git sync: unknown',
            child: _StatusDot(
              color: cs.onTertiary.withValues(alpha: 0.4),
              size: 10,
            ),
          ),
          const SizedBox(width: 10),

          // Stats line.
          Expanded(
            child: _StatsLine(project: project),
          ),
        ],
      ),
    );
  }

  String _indexStatusTooltip(IndexStatus status) => switch (status) {
        IndexStatus.idle => 'Not indexed',
        IndexStatus.indexing => 'Indexing in progress...',
        IndexStatus.indexed => 'Index up to date',
        IndexStatus.indexFailed => 'Index failed',
      };
}

// ---------------------------------------------------------------------------
// Stats line
// ---------------------------------------------------------------------------

class _StatsLine extends StatelessWidget {
  const _StatsLine({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // When indexing, show progress status instead of stats.
    if (project.indexStatus == IndexStatus.indexing) {
      return Text(
        'indexing...',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppTheme.info,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // Show file/symbol counts when available (placeholder until API returns them).
    return Text(
      project.indexStatus == IndexStatus.indexed
          ? 'indexed'
          : _indexStatusLabel(project.indexStatus),
      style: theme.textTheme.bodySmall?.copyWith(
        color: cs.onTertiary,
        fontSize: 11,
      ),
    );
  }

  String _indexStatusLabel(IndexStatus status) => switch (status) {
        IndexStatus.idle => 'pending',
        IndexStatus.indexing => 'indexing...',
        IndexStatus.indexed => 'indexed',
        IndexStatus.indexFailed => 'index failed',
      };
}

// ---------------------------------------------------------------------------
// Status dot widgets
// ---------------------------------------------------------------------------

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, this.size = 10});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _IndexStatusDot extends StatelessWidget {
  const _IndexStatusDot({required this.status, this.size = 10});

  final IndexStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _StatusDot(color: _colorForStatus(status), size: size);
  }

  Color _colorForStatus(IndexStatus status) => switch (status) {
        IndexStatus.idle => const Color(0xFF737373), // gray
        IndexStatus.indexing => AppTheme.info,
        IndexStatus.indexed => AppTheme.success,
        IndexStatus.indexFailed => AppTheme.danger,
      };
}

/// Animated spinner overlay for the indexing state.
class _AnimatedIndexingDot extends StatefulWidget {
  @override
  State<_AnimatedIndexingDot> createState() => _AnimatedIndexingDotState();
}

class _AnimatedIndexingDotState extends State<_AnimatedIndexingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing outer ring.
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.info.withValues(
                      alpha: 0.6 * (1 - _controller.value),
                    ),
                    width: 1.5,
                  ),
                ),
              ),
              // Solid inner dot.
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.info,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading state
// ---------------------------------------------------------------------------

class _SelectorSkeleton extends StatelessWidget {
  const _SelectorSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shimmerColor = cs.onSurface.withValues(alpha: 0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 16,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 180,
          height: 12,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 12,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state (no projects)
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No projects',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onTertiary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 30,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 14),
            label: const Text('Add Project', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error card
// ---------------------------------------------------------------------------

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline_rounded, size: 14, color: AppTheme.danger),
            const SizedBox(width: 6),
            Text(
              'Failed to load projects',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          error,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onTertiary,
            fontSize: 11,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Strip protocol and .git suffix for display.
String _formatCloneUrl(String url) {
  var display = url;
  display = display.replaceFirst(RegExp(r'^https?://'), '');
  display = display.replaceFirst(RegExp(r'\.git$'), '');
  return display;
}
