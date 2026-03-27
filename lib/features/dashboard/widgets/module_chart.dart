/// Top modules horizontal bar chart for the dashboard.
///
/// Shows the top 10 modules by symbol count with module paths on the left
/// and bars extending right, matching the V1 dashboard layout.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/features/dashboard/dashboard_provider.dart';

/// Horizontal bar chart showing top modules by symbol count.
class ModuleChart extends StatelessWidget {
  const ModuleChart({super.key, required this.modules});

  final List<ModuleStat> modules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (modules.isEmpty) {
      return _emptyState(theme, cs);
    }

    // Take top 10, already sorted from API.
    final items = modules.take(10).toList();
    final maxCount =
        items.isEmpty ? 1.0 : items.first.symbolCount.toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOP MODULES',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCount * 1.15,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => cs.surfaceContainerHighest,
                    tooltipBorder: BorderSide(color: cs.outline),
                    tooltipRoundedRadius: 6,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final mod = items[group.x.toInt()];
                      return BarTooltipItem(
                        '${mod.path}\n${mod.symbolCount} symbols',
                        TextStyle(
                          color: cs.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= items.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: SizedBox(
                            width: 80,
                            child: Text(
                              _shortenPath(items[idx].path),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onTertiary,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(items.length, (i) {
                  final fraction = items[i].symbolCount / maxCount;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: items[i].symbolCount.toDouble(),
                        gradient: LinearGradient(
                          colors: [
                            _barColor(fraction).withAlpha(180),
                            _barColor(fraction),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
      child: Center(
        child: Text(
          'No module data',
          style: theme.textTheme.bodySmall?.copyWith(color: cs.onTertiary),
        ),
      ),
    );
  }
}

/// Returns a color from purple to blue based on relative rank.
Color _barColor(double fraction) {
  if (fraction > 0.8) return const Color(0xFF6366F1);
  if (fraction > 0.5) return const Color(0xFF818CF8);
  return const Color(0xFF93A4F8);
}

/// Shortens a module path for display (e.g. "internal/mcp/server" -> "internal/.../server").
String _shortenPath(String path) {
  final parts = path.split('/');
  if (parts.length <= 2) return path;
  return '${parts.first}/.../${parts.last}';
}
