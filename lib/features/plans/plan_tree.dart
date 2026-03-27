/// Plan tree for the left sidebar panel.
///
/// Displays plans as expandable cards with phases and tasks. Supports
/// text search filtering and a hide-completed toggle. Watches the
/// selected project so it auto-refreshes on project switch.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/models/plan.dart';
import 'package:qdexcode_desktop/features/plans/phase_row.dart';
import 'package:qdexcode_desktop/features/plans/plan_card.dart';
import 'package:qdexcode_desktop/features/plans/plan_list_provider.dart';
import 'package:qdexcode_desktop/features/plans/task_row.dart';

/// The plan tree widget for the left panel's plan navigation slot.
///
/// Shows a search bar, hide-completed toggle, and a scrollable list
/// of plan cards that expand to show phases and tasks.
class PlanTree extends ConsumerWidget {
  const PlanTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final plansAsync = ref.watch(planListProvider);
    final filter = ref.watch(planFilterProvider);
    final expansion = ref.watch(planTreeExpansionProvider);
    final navState = ref.watch(planNavigationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 4),
          child: Row(
            children: [
              Text(
                'PLANS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onTertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Hide completed toggle
              _CompactToggle(
                label: 'Hide done',
                value: filter.hideCompleted,
                onChanged: () =>
                    ref.read(planFilterProvider.notifier).toggleHideCompleted(),
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: _PlanSearchBar(
            value: filter.searchQuery,
            onChanged: (query) =>
                ref.read(planFilterProvider.notifier).setSearchQuery(query),
          ),
        ),

        // Plan list
        Expanded(
          child: plansAsync.when(
            loading: () => const _PlanTreeSkeleton(),
            error: (error, _) => _PlanTreeError(error: error),
            data: (plans) {
              // Apply filters.
              var filtered = plans;
              if (filter.hideCompleted) {
                filtered = filtered
                    .where((p) => p.status != PlanStatus.completed)
                    .toList();
              }
              if (filter.searchQuery.isNotEmpty) {
                final query = filter.searchQuery.toLowerCase();
                filtered = filtered.where((p) {
                  return p.name.toLowerCase().contains(query) ||
                      (p.goal?.toLowerCase().contains(query) ?? false) ||
                      p.status.name.toLowerCase().contains(query);
                }).toList();
              }

              if (filtered.isEmpty) {
                return const _PlanTreeEmpty();
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final plan = filtered[index];
                  final isExpanded =
                      expansion.expandedPlanIds.contains(plan.id);

                  // Determine if this plan is selected in nav state.
                  final isSelected = switch (navState) {
                    PlanNavigationPlanDetail(planId: final id) => id == plan.id,
                    PlanNavigationTaskDetail(planId: final id) =>
                      id == plan.id,
                    _ => false,
                  };

                  return _PlanTreeItem(
                    plan: plan,
                    isExpanded: isExpanded,
                    isSelected: isSelected,
                    navState: navState,
                    expansion: expansion,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A single plan item in the tree with its phases and tasks.
class _PlanTreeItem extends ConsumerWidget {
  const _PlanTreeItem({
    required this.plan,
    required this.isExpanded,
    required this.isSelected,
    required this.navState,
    required this.expansion,
  });

  final Plan plan;
  final bool isExpanded;
  final bool isSelected;
  final PlanNavigationState navState;
  final ({Set<String> expandedPlanIds, Set<String> expandedPhaseIds}) expansion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phases = plan.phases ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlanCard(
          plan: plan,
          isExpanded: isExpanded,
          isSelected: isSelected,
          onTap: () {
            ref.read(planTreeExpansionProvider.notifier).togglePlan(plan.id);
          },
          onTitleTap: () {
            ref.read(planNavigationProvider.notifier).selectPlan(plan.id);
            ref.read(planTreeExpansionProvider.notifier).expandPlan(plan.id);
          },
        ),

        // Expanded phases (animated via plan card's expand state)
        if (isExpanded && phases.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Column(
              children: [
                for (final phase in _sortedPhases(phases))
                  _buildPhaseRow(context, ref, phase),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPhaseRow(BuildContext context, WidgetRef ref, Phase phase) {
    final isPhaseExpanded = expansion.expandedPhaseIds.contains(phase.id);
    final tasks = phase.tasks ?? [];

    return PhaseRow(
      phase: phase,
      isExpanded: isPhaseExpanded,
      onToggle: () {
        ref.read(planTreeExpansionProvider.notifier).togglePhase(phase.id);
      },
      child: Column(
        children: [
          for (final task in _sortedTasks(tasks))
            TaskRow(
              task: task,
              isSelected: switch (navState) {
                PlanNavigationTaskDetail(taskId: final id) => id == task.id,
                _ => false,
              },
              onTap: () {
                ref.read(planNavigationProvider.notifier).selectTask(
                      planId: plan.id,
                      taskId: task.id,
                    );
              },
            ),
        ],
      ),
    );
  }

  List<Phase> _sortedPhases(List<Phase> phases) {
    final sorted = List<Phase>.from(phases);
    sorted.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return sorted;
  }

  List<Task> _sortedTasks(List<Task> tasks) {
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      // Sort by execution group first, then order index.
      final groupCmp =
          (a.executionGroup ?? 0).compareTo(b.executionGroup ?? 0);
      if (groupCmp != 0) return groupCmp;
      return a.orderIndex.compareTo(b.orderIndex);
    });
    return sorted;
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

class _PlanSearchBar extends StatefulWidget {
  const _PlanSearchBar({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_PlanSearchBar> createState() => _PlanSearchBarState();
}

class _PlanSearchBarState extends State<_PlanSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _PlanSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 28,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: TextStyle(fontSize: 11, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: 'Filter plans...',
          hintStyle: TextStyle(fontSize: 11, color: cs.onTertiary),
          prefixIcon: Icon(Icons.search, size: 14, color: cs.onTertiary),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 28, minHeight: 28),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                  child: Icon(Icons.close, size: 12, color: cs.onTertiary),
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 24, minHeight: 24),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          isDense: true,
          filled: true,
          fillColor: cs.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: cs.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: cs.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact toggle button
// ---------------------------------------------------------------------------

class _CompactToggle extends StatefulWidget {
  const _CompactToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final VoidCallback onChanged;

  @override
  State<_CompactToggle> createState() => _CompactToggleState();
}

class _CompactToggleState extends State<_CompactToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onChanged,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: widget.value
                ? cs.primary.withValues(alpha: 0.1)
                : _hovered
                    ? cs.surfaceContainer
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: widget.value
                ? Border.all(color: cs.primary.withValues(alpha: 0.3))
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.value ? cs.primary : cs.onTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading, error, and empty states
// ---------------------------------------------------------------------------

/// Skeleton loading shimmer for the plan tree.
class _PlanTreeSkeleton extends StatelessWidget {
  const _PlanTreeSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: _ShimmerBlock(
              height: 52,
              color: cs.surfaceContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatefulWidget {
  const _ShimmerBlock({required this.height, required this.color});
  final double height;
  final Color color;

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + 0.4 * (0.5 + 0.5 * _controller.value),
          child: child,
        );
      },
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _PlanTreeError extends StatelessWidget {
  const _PlanTreeError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 24, color: cs.onTertiary),
            const SizedBox(height: 8),
            Text(
              'Could not load plans',
              style: TextStyle(
                color: cs.onTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTreeEmpty extends StatelessWidget {
  const _PlanTreeEmpty();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 32,
            color: cs.onTertiary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'No plans yet',
            style: TextStyle(
              color: cs.onTertiary.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Plans are created via Claude Code agents',
            style: TextStyle(
              color: cs.onTertiary.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
