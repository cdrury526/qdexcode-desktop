/// Language distribution chart for the dashboard.
///
/// Displays a donut/pie chart with a legend showing language names,
/// file counts, and percentages. Uses fl_chart for rendering.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/features/dashboard/dashboard_provider.dart';

/// Color palette for language slices.
const _languageColors = [
  Color(0xFF6366F1), // indigo
  Color(0xFF3B82F6), // blue
  Color(0xFF06B6D4), // cyan
  Color(0xFF10B981), // emerald
  Color(0xFFF59E0B), // amber
  Color(0xFFEF4444), // red
  Color(0xFF8B5CF6), // violet
  Color(0xFFEC4899), // pink
  Color(0xFF14B8A6), // teal
  Color(0xFFF97316), // orange
];

/// Pie chart showing language distribution by file count.
class LanguageChart extends StatefulWidget {
  const LanguageChart({super.key, required this.languages});

  final List<LanguageStat> languages;

  @override
  State<LanguageChart> createState() => _LanguageChartState();
}

class _LanguageChartState extends State<LanguageChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (widget.languages.isEmpty) {
      return _emptyState(theme, cs);
    }

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
            'LANGUAGES',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex =
                                response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: _buildSections(),
                      centerSpaceRadius: 28,
                      sectionsSpace: 1.5,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                const SizedBox(width: 14),
                // Legend
                Expanded(
                  flex: 4,
                  child: _buildLegend(theme, cs),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.languages.length, (i) {
      final lang = widget.languages[i];
      final isTouched = i == _touchedIndex;
      final color = _languageColors[i % _languageColors.length];

      return PieChartSectionData(
        value: lang.fileCount.toDouble(),
        color: color,
        radius: isTouched ? 32 : 26,
        showTitle: false,
      );
    });
  }

  Widget _buildLegend(ThemeData theme, ColorScheme cs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.languages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, i) {
        final lang = widget.languages[i];
        final color = _languageColors[i % _languageColors.length];
        final isTouched = i == _touchedIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isTouched ? color.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lang.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface,
                    fontSize: 12,
                    fontWeight: isTouched ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${lang.fileCount} files',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onTertiary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 38,
                child: Text(
                  '${lang.percentage.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
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
          'No language data',
          style: theme.textTheme.bodySmall?.copyWith(color: cs.onTertiary),
        ),
      ),
    );
  }
}
