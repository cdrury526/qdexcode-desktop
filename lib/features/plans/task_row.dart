/// Task row for the plan tree.
///
/// Displays task status icon, name, assigned agent, execution group badge,
/// and an expandable subtask toggle.
library;

import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/core/models/plan.dart';
import 'package:qdexcode_desktop/core/theme/app_theme.dart';

/// A task row in the plan tree, shown under a phase.
class TaskRow extends StatefulWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onTap,
  });

  final Task task;
  final bool isSelected;

  /// Called when the task name is tapped (opens task detail).
  final VoidCallback onTap;

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> {
  bool _hovered = false;
  bool _subtasksExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final subtasks = widget.task.subtasks ?? [];
    final hasSubtasks = subtasks.isNotEmpty;
    final doneSubtasks =
        subtasks.where((s) => s.status == SubtaskStatus.done).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task header row
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 26,
              padding: const EdgeInsets.only(left: 40, right: 8),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? cs.secondary
                    : _hovered
                        ? cs.surfaceContainer
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  // Status icon
                  _TaskStatusIcon(status: widget.task.status),
                  const SizedBox(width: 6),
                  // Task name
                  Expanded(
                    child: Text(
                      widget.task.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: widget.task.status == TaskStatus.done
                            ? cs.onTertiary
                            : cs.onSurface,
                        fontSize: 11,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        decoration: widget.task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: cs.onTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  // Agent badge
                  if (widget.task.assignedAgent != null) ...[
                    const SizedBox(width: 4),
                    _AgentBadge(agent: widget.task.assignedAgent!),
                  ],
                  // Execution group badge
                  if (widget.task.executionGroup != null) ...[
                    const SizedBox(width: 4),
                    _ExecutionGroupBadge(
                        group: widget.task.executionGroup!),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Subtask toggle + inline subtask list
        if (hasSubtasks) ...[
          _SubtaskToggle(
            total: subtasks.length,
            done: doneSubtasks,
            isExpanded: _subtasksExpanded,
            onToggle: () =>
                setState(() => _subtasksExpanded = !_subtasksExpanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _SubtaskList(subtasks: subtasks),
            crossFadeState: _subtasksExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ],
    );
  }
}

/// Status icon for a task.
class _TaskStatusIcon extends StatelessWidget {
  const _TaskStatusIcon({required this.status});
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (status) {
      TaskStatus.pending => (
          Icons.circle_outlined,
          Theme.of(context).colorScheme.onTertiary,
        ),
      TaskStatus.ready => (Icons.radio_button_unchecked, AppTheme.info),
      TaskStatus.inProgress => (Icons.play_circle_outline, AppTheme.info),
      TaskStatus.done => (Icons.check_circle_outline, AppTheme.success),
      TaskStatus.blocked => (Icons.block_outlined, AppTheme.danger),
      TaskStatus.canceled => (
          Icons.cancel_outlined,
          Theme.of(context).colorScheme.onTertiary,
        ),
    };

    return Icon(icon, size: 12, color: color);
  }
}

/// Compact agent badge.
class _AgentBadge extends StatelessWidget {
  const _AgentBadge({required this.agent});
  final String agent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Shorten common agent names.
    final shortName = _shortenAgent(agent);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: cs.tertiary,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        shortName,
        style: TextStyle(
          color: cs.onTertiary,
          fontSize: 8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static String _shortenAgent(String agent) {
    // Shorten well-known agent names for space.
    return switch (agent) {
      'flutter-ui-developer' => 'flutter',
      'nextjs-developer' => 'nextjs',
      'backend-developer' => 'backend',
      'infrastructure' => 'infra',
      _ => agent.length > 10 ? '${agent.substring(0, 8)}..' : agent,
    };
  }
}

/// Execution group badge.
class _ExecutionGroupBadge extends StatelessWidget {
  const _ExecutionGroupBadge({required this.group});
  final int group;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: AppTheme.info.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        'G$group',
        style: const TextStyle(
          color: AppTheme.info,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Subtask count toggle.
class _SubtaskToggle extends StatefulWidget {
  const _SubtaskToggle({
    required this.total,
    required this.done,
    required this.isExpanded,
    required this.onToggle,
  });

  final int total;
  final int done;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  State<_SubtaskToggle> createState() => _SubtaskToggleState();
}

class _SubtaskToggleState extends State<_SubtaskToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: Padding(
          padding: const EdgeInsets.only(left: 52, right: 8, top: 1),
          child: Row(
            children: [
              AnimatedRotation(
                turns: widget.isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.chevron_right,
                  size: 10,
                  color: cs.onTertiary,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '${widget.done}/${widget.total} subtasks',
                style: TextStyle(
                  color: _hovered ? cs.onSurface : cs.onTertiary,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline subtask list shown when the subtask toggle is expanded.
class _SubtaskList extends StatelessWidget {
  const _SubtaskList({required this.subtasks});
  final List<Subtask> subtasks;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 8, top: 2, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final subtask in subtasks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                children: [
                  Icon(
                    subtask.status == SubtaskStatus.done
                        ? Icons.check_circle_outline
                        : subtask.status == SubtaskStatus.inProgress
                            ? Icons.play_circle_outline
                            : Icons.circle_outlined,
                    size: 10,
                    color: subtask.status == SubtaskStatus.done
                        ? AppTheme.success
                        : subtask.status == SubtaskStatus.inProgress
                            ? AppTheme.info
                            : cs.onTertiary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      subtask.details,
                      style: TextStyle(
                        color: subtask.status == SubtaskStatus.done
                            ? cs.onTertiary
                            : cs.onSurface,
                        fontSize: 10,
                        decoration: subtask.status == SubtaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: cs.onTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
