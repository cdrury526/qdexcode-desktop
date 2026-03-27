/// Center panel detail view for a selected task.
///
/// Shows task description, file scopes, acceptance criteria, subtasks,
/// and dependencies. Read-only view.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/models/plan.dart';
import 'package:qdexcode_desktop/core/theme/app_theme.dart';
import 'package:qdexcode_desktop/features/plans/plan_list_provider.dart';

/// Full task detail view shown in the center panel.
class TaskDetailView extends ConsumerWidget {
  const TaskDetailView({
    super.key,
    required this.planId,
    required this.taskId,
  });

  final String planId;
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planDetailProvider(planId));

    return planAsync.when(
      loading: () => const _TaskDetailSkeleton(),
      error: (error, _) => _TaskDetailError(error: error),
      data: (plan) {
        final task = _findTask(plan, taskId);
        if (task == null) {
          return const _TaskDetailError(error: 'Task not found');
        }
        return _TaskDetailContent(plan: plan, task: task);
      },
    );
  }

  Task? _findTask(Plan plan, String taskId) {
    for (final phase in plan.phases ?? <Phase>[]) {
      for (final task in phase.tasks ?? <Task>[]) {
        if (task.id == taskId) return task;
      }
    }
    return null;
  }
}

/// The actual task detail content.
class _TaskDetailContent extends StatelessWidget {
  const _TaskDetailContent({
    required this.plan,
    required this.task,
  });

  final Plan plan;
  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final subtasks = task.subtasks ?? [];
    final criteria = task.acceptanceCriteria ?? [];
    final fileScopes = task.fileScopes ?? [];
    final dependsOn = task.dependsOn ?? [];

    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Breadcrumb
          _TaskBreadcrumb(planName: plan.name, planId: plan.id),
          const SizedBox(height: 16),

          // Task name
          Text(
            task.name,
            style: theme.textTheme.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),

          // Meta row: status, agent, execution group
          const SizedBox(height: 12),
          _TaskMetaRow(task: task),

          // Description
          if (task.description != null &&
              task.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Description'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outline),
              ),
              child: Text(
                task.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ],

          // Completion summary
          if (task.completionSummary != null) ...[
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Completion Summary'),
            const SizedBox(height: 8),
            _CompletionSummaryBox(summary: task.completionSummary!),
          ],

          // Subtasks
          if (subtasks.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionTitle(title: 'Subtasks (${subtasks.length})'),
            const SizedBox(height: 8),
            _SubtaskSection(subtasks: subtasks),
          ],

          // Acceptance criteria
          if (criteria.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionTitle(title: 'Acceptance Criteria (${criteria.length})'),
            const SizedBox(height: 8),
            _CriteriaSection(criteria: criteria),
          ],

          // File scopes
          if (fileScopes.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionTitle(title: 'File Scopes (${fileScopes.length})'),
            const SizedBox(height: 8),
            _FileScopeSection(fileScopes: fileScopes),
          ],

          // Dependencies
          if (dependsOn.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionTitle(title: 'Dependencies (${dependsOn.length})'),
            const SizedBox(height: 8),
            _DependencySection(dependsOn: dependsOn, plan: plan),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Breadcrumb
// ---------------------------------------------------------------------------

class _TaskBreadcrumb extends ConsumerWidget {
  const _TaskBreadcrumb({required this.planName, required this.planId});
  final String planName;
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _BreadcrumbLink(
          label: 'Dashboard',
          onTap: () => ref.read(planNavigationProvider.notifier).clear(),
        ),
        _BreadcrumbSeparator(),
        _BreadcrumbLink(
          label: planName,
          onTap: () =>
              ref.read(planNavigationProvider.notifier).selectPlan(planId),
        ),
        _BreadcrumbSeparator(),
        Text(
          'Task',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BreadcrumbLink extends StatefulWidget {
  const _BreadcrumbLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_BreadcrumbLink> createState() => _BreadcrumbLinkState();
}

class _BreadcrumbLinkState extends State<_BreadcrumbLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            color: _hovered ? cs.onSurface : cs.onTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _BreadcrumbSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.chevron_right,
        size: 14,
        color: Theme.of(context).colorScheme.onTertiary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task meta row
// ---------------------------------------------------------------------------

class _TaskMetaRow extends StatelessWidget {
  const _TaskMetaRow({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (Color statusColor, String statusLabel) = switch (task.status) {
      TaskStatus.pending => (cs.onTertiary, 'Pending'),
      TaskStatus.ready => (AppTheme.info, 'Ready'),
      TaskStatus.inProgress => (AppTheme.info, 'In Progress'),
      TaskStatus.done => (AppTheme.success, 'Done'),
      TaskStatus.blocked => (AppTheme.danger, 'Blocked'),
      TaskStatus.canceled => (cs.onTertiary, 'Canceled'),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _ChipBadge(label: 'Status', value: statusLabel, color: statusColor),
        if (task.assignedAgent != null)
          _ChipBadge(
            label: 'Agent',
            value: task.assignedAgent!,
            icon: Icons.smart_toy_outlined,
          ),
        if (task.executionGroup != null)
          _ChipBadge(
            label: 'Group',
            value: 'G${task.executionGroup}',
            color: AppTheme.info,
          ),
        if (task.blockerReason != null)
          _ChipBadge(
            label: 'Blocked',
            value: task.blockerReason!,
            color: AppTheme.danger,
          ),
      ],
    );
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  final String label;
  final String value;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final chipColor = color ?? cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: chipColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: chipColor),
            const SizedBox(width: 4),
          ],
          Text(
            '$label: ',
            style: TextStyle(
              color: cs.onTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: chipColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subtasks section
// ---------------------------------------------------------------------------

class _SubtaskSection extends StatelessWidget {
  const _SubtaskSection({required this.subtasks});
  final List<Subtask> subtasks;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sorted = List<Subtask>.from(subtasks)
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (int i = 0; i < sorted.length; i++) ...[
            _SubtaskRow(subtask: sorted[i]),
            if (i < sorted.length - 1)
              Divider(
                height: 1,
                color: cs.outline.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({required this.subtask});
  final Subtask subtask;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDone = subtask.status == SubtaskStatus.done;
    final isInProgress = subtask.status == SubtaskStatus.inProgress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Icon(
            isDone
                ? Icons.check_circle
                : isInProgress
                    ? Icons.play_circle
                    : Icons.circle_outlined,
            size: 14,
            color: isDone
                ? AppTheme.success
                : isInProgress
                    ? AppTheme.info
                    : cs.onTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subtask.details,
              style: TextStyle(
                color: isDone ? cs.onTertiary : cs.onSurface,
                fontSize: 12,
                decoration:
                    isDone ? TextDecoration.lineThrough : null,
                decorationColor: cs.onTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Acceptance criteria section
// ---------------------------------------------------------------------------

class _CriteriaSection extends StatelessWidget {
  const _CriteriaSection({required this.criteria});
  final List<AcceptanceCriteria> criteria;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (int i = 0; i < criteria.length; i++) ...[
            _CriteriaRow(criterion: criteria[i]),
            if (i < criteria.length - 1)
              Divider(
                height: 1,
                color: cs.outline.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  const _CriteriaRow({required this.criterion});
  final AcceptanceCriteria criterion;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CriteriaTypeBadge(type: criterion.criteriaType),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  criterion.description,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 12,
                  ),
                ),
                if (criterion.command != null &&
                    criterion.command!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      criterion.command!,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        color: cs.onTertiary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CriteriaTypeBadge extends StatelessWidget {
  const _CriteriaTypeBadge({required this.type});
  final CriteriaType type;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (type) {
      CriteriaType.manual => (AppTheme.info, 'manual'),
      CriteriaType.build => (AppTheme.warning, 'build'),
      CriteriaType.test => (AppTheme.success, 'test'),
      CriteriaType.lint => (const Color(0xFF8B5CF6), 'lint'),
      CriteriaType.command => (AppTheme.info, 'cmd'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// File scopes section
// ---------------------------------------------------------------------------

class _FileScopeSection extends StatelessWidget {
  const _FileScopeSection({required this.fileScopes});
  final List<FileScope> fileScopes;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Group by scope type.
    final reads =
        fileScopes.where((f) => f.scopeType == FileScopeType.read).toList();
    final writes =
        fileScopes.where((f) => f.scopeType == FileScopeType.write).toList();
    final creates =
        fileScopes.where((f) => f.scopeType == FileScopeType.create).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (creates.isNotEmpty) ...[
            _FileScopeGroup(
              label: 'Creates',
              files: creates,
              color: AppTheme.success,
            ),
            if (writes.isNotEmpty || reads.isNotEmpty)
              const SizedBox(height: 8),
          ],
          if (writes.isNotEmpty) ...[
            _FileScopeGroup(
              label: 'Writes',
              files: writes,
              color: AppTheme.warning,
            ),
            if (reads.isNotEmpty) const SizedBox(height: 8),
          ],
          if (reads.isNotEmpty)
            _FileScopeGroup(
              label: 'Reads',
              files: reads,
              color: cs.onTertiary,
            ),
        ],
      ),
    );
  }
}

class _FileScopeGroup extends StatelessWidget {
  const _FileScopeGroup({
    required this.label,
    required this.files,
    required this.color,
  });

  final String label;
  final List<FileScope> files;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        for (final file in files)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 1, bottom: 1),
            child: Text(
              file.filePath,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                color: cs.onSurface,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dependencies section
// ---------------------------------------------------------------------------

class _DependencySection extends StatelessWidget {
  const _DependencySection({
    required this.dependsOn,
    required this.plan,
  });

  final List<String> dependsOn;
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Find task names for dependency IDs.
    final allTasks = <Task>[];
    for (final phase in plan.phases ?? <Phase>[]) {
      allTasks.addAll(phase.tasks ?? []);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (int i = 0; i < dependsOn.length; i++) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.link, size: 12, color: cs.onTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _taskName(allTasks, dependsOn[i]),
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  _DepStatusIcon(
                    task: allTasks
                        .where((t) => t.id == dependsOn[i])
                        .firstOrNull,
                  ),
                ],
              ),
            ),
            if (i < dependsOn.length - 1)
              Divider(
                height: 1,
                color: cs.outline.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }

  String _taskName(List<Task> tasks, String id) {
    final task = tasks.where((t) => t.id == id).firstOrNull;
    return task?.name ?? id.substring(0, 8);
  }
}

class _DepStatusIcon extends StatelessWidget {
  const _DepStatusIcon({required this.task});
  final Task? task;

  @override
  Widget build(BuildContext context) {
    if (task == null) return const SizedBox.shrink();

    final (IconData icon, Color color) = switch (task!.status) {
      TaskStatus.done => (Icons.check_circle, AppTheme.success),
      TaskStatus.inProgress => (Icons.play_circle, AppTheme.info),
      TaskStatus.blocked => (Icons.block, AppTheme.danger),
      _ => (
          Icons.circle_outlined,
          Theme.of(context).colorScheme.onTertiary,
        ),
    };

    return Icon(icon, size: 12, color: color);
  }
}

// ---------------------------------------------------------------------------
// Completion summary box
// ---------------------------------------------------------------------------

class _CompletionSummaryBox extends StatelessWidget {
  const _CompletionSummaryBox({required this.summary});
  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final summaryText = summary['summary'] as String? ?? '';
    final filesChanged =
        (summary['files_changed'] as List<dynamic>?)?.cast<String>() ?? [];
    final filesCreated =
        (summary['files_created'] as List<dynamic>?)?.cast<String>() ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summaryText.isNotEmpty)
            Text(
              summaryText,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          if (filesCreated.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Files Created:',
              style: TextStyle(
                color: AppTheme.success,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            for (final f in filesCreated)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text(
                  f,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: cs.onSurface,
                  ),
                ),
              ),
          ],
          if (filesChanged.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Files Changed:',
              style: TextStyle(
                color: AppTheme.warning,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            for (final f in filesChanged)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text(
                  f,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: cs.onSurface,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section title
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading & error states
// ---------------------------------------------------------------------------

class _TaskDetailSkeleton extends StatelessWidget {
  const _TaskDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 250,
            height: 14,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 350,
            height: 24,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskDetailError extends StatelessWidget {
  const _TaskDetailError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 32, color: cs.onTertiary),
          const SizedBox(height: 8),
          Text(
            'Failed to load task details',
            style: TextStyle(
              color: cs.onTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
