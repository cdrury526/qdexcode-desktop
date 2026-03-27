/// Symbol composition chart for the dashboard.
///
/// Displays a horizontal bar chart showing symbol counts by kind
/// (Function, Variable, Method, Struct, Interface, Type, Class).
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/features/dashboard/dashboard_provider.dart';

/// Color palette for symbol kinds.
const _kindColors = {
  'function': Color(0xFF8B5CF6),
  'variable': Color(0xFF3B82F6),
  'method': Color(0xFF06B6D4),
  'struct': Color(0xFF10B981),
  'interface': Color(0xFFF59E0B),
  'type': Color(0xFFEF4444),
  'class': Color(0xFFEC4899),
  'constant': Color(0xFF14B8A6),
  'enum': Color(0xFFF97316),
  'property': Color(0xFF6366F1),
};

Color _colorForKind(String kind) {
  return _kindColors[kind.toLowerCase()] ?? const Color(0xFF6366F1);
}

/// Horizontal bar chart showing symbol composition by kind.
class SymbolChart extends StatelessWidget {
  const SymbolChart({super.key, required this.symbolKinds});

  final List<SymbolKindStat> symbolKinds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (symbolKinds.isEmpty) {
      return _emptyState(theme, cs);
    }

    // Sort by count descending.
    final sorted = List<SymbolKindStat>.from(symbolKinds)
      ..sort((a, b) => b.count.compareTo(a.count));

    final maxCount =
        sorted.isEmpty ? 1.0 : sorted.first.count.toDouble();

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
            'SYMBOL COMPOSITION',
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
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final kind = sorted[group.x.toInt()];
                      return BarTooltipItem(
                        '${kind.kind}\n${_formatCount(kind.count)}',
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
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= sorted.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            sorted[idx].kind,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onTertiary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(sorted.length, (i) {
                  final kind = sorted[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: kind.count.toDouble(),
                        color: _colorForKind(kind.kind),
                        width: 18,
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
          'No symbol data',
          style: theme.textTheme.bodySmall?.copyWith(color: cs.onTertiary),
        ),
      ),
    );
  }
}

String _formatCount(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}k';
  }
  return count.toString();
}
