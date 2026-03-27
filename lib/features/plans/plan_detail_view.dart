/// Center panel detail view for a selected plan.
///
/// Shows the full plan information: goal, description, flow diagram,
/// phases with their tasks, and acceptance criteria. Read-only view
/// matching the V1 design reference.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/models/plan.dart';
import 'package:qdexcode_desktop/core/theme/app_theme.dart';
import 'package:qdexcode_desktop/features/plans/plan_list_provider.dart';

/// Full plan detail view shown in the center panel.
class PlanDetailView extends ConsumerWidget {
  const PlanDetailView({super.key, required this.planId});
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planDetailProvider(planId));

    return planAsync.when(
      loading: () => const _PlanDetailSkeleton(),
      error: (error, _) => _PlanDetailError(error: error),
      data: (plan) => _PlanDetailContent(plan: plan),
    );
  }
}

/// The actual plan detail content.
class _PlanDetailContent extends StatelessWidget {
  const _PlanDetailContent({required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final phases = _sortedPhases(plan.phases ?? []);

    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Breadcrumb
          _Breadcrumb(planName: plan.name),
          const SizedBox(height: 16),

          // Plan title
          Text(
            plan.name,
            style: theme.textTheme.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),

          // Goal
          if (plan.goal != null && plan.goal!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              plan.goal!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onTertiary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],

          // Status and completion row
          const SizedBox(height: 16),
          _PlanMetaRow(plan: plan),

          // Description
          if (plan.description != null &&
              plan.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Description'),
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
                plan.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ],

          // Flow diagram
          if (plan.flowDiagram != null &&
              plan.flowDiagram!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Flow Diagram'),
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
                plan.flowDiagram!,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  color: cs.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ],

          // Phases
          const SizedBox(height: 20),
          _SectionHeader(title: 'Phases (${phases.length})'),
          const SizedBox(height: 8),
          for (int i = 0; i < phases.length; i++) ...[
            _PhaseSection(phase: phases[i], index: i + 1),
            if (i < phases.length - 1) const SizedBox(height: 12),
          ],

          const SizedBox(height: 32),

          // Footer meta
          _PlanFooterMeta(plan: plan),
        ],
      ),
    );
  }

  List<Phase> _sortedPhases(List<Phase> phases) {
    final sorted = List<Phase>.from(phases);
    sorted.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return sorted;
  }
}

// ---------------------------------------------------------------------------
// Breadcrumb
// ---------------------------------------------------------------------------

class _Breadcrumb extends ConsumerWidget {
  const _Breadcrumb({required this.planName});
  final String planName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        GestureDetector(
          onTap: () => ref.read(planNavigationProvider.notifier).clear(),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              'Dashboard',
              style: TextStyle(
                color: cs.onTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.chevron_right, size: 14, color: cs.onTertiary),
        ),
        Flexible(
          child: Text(
            planName,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Plan meta row
// ---------------------------------------------------------------------------

class _PlanMetaRow extends StatelessWidget {
  const _PlanMetaRow({required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _MetaChip(
          label: 'Completion',
          value: '${plan.completionPct.round()}%',
        ),
        const SizedBox(width: 8),
        _MetaChip(
          label: 'Status',
          value: plan.status.name,
          color: switch (plan.status) {
            PlanStatus.active => AppTheme.info,
            PlanStatus.completed => AppTheme.success,
            PlanStatus.archived => cs.onTertiary,
          },
        ),
        if (plan.qualityScore != null) ...[
          const SizedBox(width: 8),
          _MetaChip(
            label: 'Quality',
            value: '${(plan.qualityScore! * 10).round()}%',
            color: (plan.qualityScore! * 10).round() >= 80
                ? AppTheme.success
                : (plan.qualityScore! * 10).round() >= 50
                    ? AppTheme.warning
                    : AppTheme.danger,
          ),
        ],
        if (plan.branchName != null) ...[
          const SizedBox(width: 8),
          _MetaChip(
            label: 'Branch',
            value: plan.branchName!,
            icon: Icons.fork_right,
          ),
        ],
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
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
          Text(
            value,
            style: TextStyle(
              color: chipColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Phase section
// ---------------------------------------------------------------------------

class _PhaseSection extends ConsumerStatefulWidget {
  const _PhaseSection({required this.phase, required this.index});
  final Phase phase;
  final int index;

  @override
  ConsumerState<_PhaseSection> createState() => _PhaseSectionState();
}

class _PhaseSectionState extends ConsumerState<_PhaseSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final phase = widget.phase;
    final tasks = _sortedTasks(phase.tasks ?? []);
    final completedTasks =
        tasks.where((t) => t.status == TaskStatus.done).length;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase header (clickable to collapse)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: _expanded
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        )
                      : BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: _expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child:
                          Icon(Icons.chevron_right, size: 16, color: cs.onTertiary),
                    ),
                    const SizedBox(width: 4),
                    // Phase number + name
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${widget.index}. ',
                              style: TextStyle(
                                color: cs.onTertiary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: phase.name,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Phase status + completion
                    _PhaseStatusBadge(status: phase.status),
                    const SizedBox(width: 8),
                    Text(
                      '$completedTasks/${tasks.length}',
                      style: TextStyle(
                        color: cs.onTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Phase description
          if (_expanded && phase.description != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(
                phase.description!,
                style: TextStyle(
                  color: cs.onTertiary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],

          // Flow diagram
          if (_expanded &&
              phase.flowDiagram != null &&
              phase.flowDiagram!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: cs.outline),
                ),
                child: Text(
                  phase.flowDiagram!,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: cs.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],

          // Tasks
          if (_expanded && tasks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                children: [
                  for (int i = 0; i < tasks.length; i++) ...[
                    _TaskDetailRow(task: tasks[i]),
                    if (i < tasks.length - 1)
                      Divider(
                        height: 1,
                        color: cs.outline.withValues(alpha: 0.5),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Task> _sortedTasks(List<Task> tasks) {
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      final groupCmp =
          (a.executionGroup ?? 0).compareTo(b.executionGroup ?? 0);
      if (groupCmp != 0) return groupCmp;
      return a.orderIndex.compareTo(b.orderIndex);
    });
    return sorted;
  }
}

// ---------------------------------------------------------------------------
// Task row in the plan detail view
// ---------------------------------------------------------------------------

class _TaskDetailRow extends ConsumerWidget {
  const _TaskDetailRow({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: () {
        ref.read(planNavigationProvider.notifier).selectTask(
              planId: task.planId,
              taskId: task.id,
            );
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            _TaskStatusIcon(status: task.status),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: task.status == TaskStatus.done
                      ? cs.onTertiary
                      : cs.onSurface,
                  fontSize: 12,
                  decoration: task.status == TaskStatus.done
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: cs.onTertiary,
                ),
              ),
            ),
            if (task.assignedAgent != null) ...[
              const SizedBox(width: 8),
              Text(
                task.assignedAgent!,
                style: TextStyle(
                  color: cs.onTertiary,
                  fontSize: 10,
                ),
              ),
            ],
            if (task.executionGroup != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'G${task.executionGroup}',
                  style: const TextStyle(
                    color: AppTheme.info,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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

    return Icon(icon, size: 14, color: color);
  }
}

class _PhaseStatusBadge extends StatelessWidget {
  const _PhaseStatusBadge({required this.status});
  final PhaseStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      PhaseStatus.pending => (
          Theme.of(context).colorScheme.onTertiary,
          'Pending',
        ),
      PhaseStatus.inProgress => (AppTheme.info, 'In Progress'),
      PhaseStatus.completed => (AppTheme.success, 'Completed'),
      PhaseStatus.blocked => (AppTheme.danger, 'Blocked'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
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
// Footer meta
// ---------------------------------------------------------------------------

class _PlanFooterMeta extends StatelessWidget {
  const _PlanFooterMeta({required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          'Status: ${plan.status.name}',
          style: TextStyle(color: cs.onTertiary, fontSize: 10),
        ),
        const SizedBox(width: 16),
        Text(
          'Created: ${_formatDate(plan.createdAt)}',
          style: TextStyle(color: cs.onTertiary, fontSize: 10),
        ),
        const SizedBox(width: 16),
        Text(
          'Updated: ${_formatDate(plan.updatedAt)}',
          style: TextStyle(color: cs.onTertiary, fontSize: 10),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

// ---------------------------------------------------------------------------
// Loading & error states
// ---------------------------------------------------------------------------

class _PlanDetailSkeleton extends StatelessWidget {
  const _PlanDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb skeleton
          Container(
            width: 200,
            height: 14,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Title skeleton
          Container(
            width: 300,
            height: 24,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          // Description skeleton
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          // Phase skeletons
          for (int i = 0; i < 3; i++) ...[
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PlanDetailError extends StatelessWidget {
  const _PlanDetailError({required this.error});
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
            'Failed to load plan details',
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
