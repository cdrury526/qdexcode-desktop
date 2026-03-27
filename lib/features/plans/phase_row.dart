/// Collapsible phase row for the plan tree.
///
/// Shows phase name, status icon, completion percentage, and task count.
/// Expands to reveal task rows when clicked.
library;

import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/core/models/plan.dart';
import 'package:qdexcode_desktop/core/theme/app_theme.dart';

/// A collapsible phase row in the plan tree.
class PhaseRow extends StatefulWidget {
  const PhaseRow({
    super.key,
    required this.phase,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  final Phase phase;
  final bool isExpanded;
  final VoidCallback onToggle;

  /// The expanded content (task rows) shown when expanded.
  final Widget child;

  @override
  State<PhaseRow> createState() => _PhaseRowState();
}

class _PhaseRowState extends State<PhaseRow>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant PhaseRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final taskCount = widget.phase.tasks?.length ?? 0;
    final completedCount = widget.phase.tasks
            ?.where((t) => t.status == TaskStatus.done)
            .length ??
        0;
    final completionPct =
        taskCount > 0 ? (completedCount / taskCount * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phase header row
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 28,
              padding: const EdgeInsets.only(left: 24, right: 8),
              decoration: BoxDecoration(
                color: _hovered ? cs.surfaceContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  // Expand chevron
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      size: 12,
                      color: cs.onTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Status icon
                  _PhaseStatusIcon(status: widget.phase.status),
                  const SizedBox(width: 6),
                  // Phase name
                  Expanded(
                    child: Text(
                      widget.phase.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  // Completion %
                  Text(
                    '$completionPct%',
                    style: TextStyle(
                      color: cs.onTertiary,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Task count badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: cs.tertiary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '$taskCount',
                      style: TextStyle(
                        color: cs.onTertiary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Animated expand/collapse of task rows
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1,
          child: widget.child,
        ),
      ],
    );
  }
}

/// Status icon for a phase.
class _PhaseStatusIcon extends StatelessWidget {
  const _PhaseStatusIcon({required this.status});
  final PhaseStatus status;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (status) {
      PhaseStatus.pending => (
          Icons.circle_outlined,
          Theme.of(context).colorScheme.onTertiary
        ),
      PhaseStatus.inProgress => (Icons.play_circle_filled, AppTheme.info),
      PhaseStatus.completed => (Icons.check_circle, AppTheme.success),
      PhaseStatus.blocked => (Icons.block, AppTheme.danger),
    };

    return Icon(icon, size: 12, color: color);
  }
}
