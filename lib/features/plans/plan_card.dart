/// Compact plan card for the left panel tree.
///
/// Displays status badge, quality score, plan name, goal (2-line clamp),
/// and a completion progress bar. Clicking expands to show phases.
library;

import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/core/models/plan.dart';
import 'package:qdexcode_desktop/core/theme/app_theme.dart';

/// Compact plan card shown in the left panel plan tree.
class PlanCard extends StatefulWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
    required this.onTitleTap,
  });

  final Plan plan;
  final bool isExpanded;
  final bool isSelected;

  /// Called when the expand/collapse area is tapped.
  final VoidCallback onTap;

  /// Called when the plan name is tapped (opens detail in center panel).
  final VoidCallback onTitleTap;

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? cs.secondary
                : _hovered
                    ? cs.surfaceContainer
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: widget.isSelected
                ? Border.all(color: cs.outline, width: 0.5)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: chevron + badges + name
              Row(
                children: [
                  // Expand chevron
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: cs.onTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Status badge
                  _StatusBadge(status: widget.plan.status),
                  const SizedBox(width: 4),
                  // Quality score badge (if available)
                  if (widget.plan.qualityScore != null) ...[
                    _QualityBadge(score: widget.plan.qualityScore!),
                    const SizedBox(width: 4),
                  ],
                  // Plan name (clickable to open detail)
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onTitleTap,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          widget.plan.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Goal (2-line clamp)
              if (widget.plan.goal != null &&
                  widget.plan.goal!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    widget.plan.goal!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onTertiary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              // Completion progress bar
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: _CompletionBar(
                  completion: widget.plan.completionPct,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline status badge for plan status.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final PlanStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      PlanStatus.active => (AppTheme.info, 'Active'),
      PlanStatus.completed => (AppTheme.success, 'Done'),
      PlanStatus.archived => (
          Theme.of(context).colorScheme.onTertiary,
          'Archived'
        ),
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
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Inline quality score badge.
class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final percentage = (score * 10).round();
    final color = percentage >= 80
        ? AppTheme.success
        : percentage >= 50
            ? AppTheme.warning
            : AppTheme.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        'Q$percentage',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Thin completion progress bar.
class _CompletionBar extends StatelessWidget {
  const _CompletionBar({required this.completion});
  final double completion;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = completion.clamp(0.0, 100.0);
    final fraction = pct / 100.0;

    final barColor = pct >= 100
        ? AppTheme.success
        : pct >= 50
            ? AppTheme.info
            : cs.primary;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 3,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: cs.tertiary,
                    valueColor: AlwaysStoppedAnimation(barColor),
                    minHeight: 3,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${pct.round()}%',
          style: TextStyle(
            color: cs.onTertiary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
