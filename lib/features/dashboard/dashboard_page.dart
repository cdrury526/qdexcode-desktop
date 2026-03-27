/// Main dashboard page for the center panel.
///
/// Assembles stat cards, secondary stats, charts, and module breakdown
/// in a scrollable layout matching the V1 dashboard design.
/// View-only -- no re-index or purge buttons.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/features/dashboard/dashboard_provider.dart';
import 'package:qdexcode_desktop/features/dashboard/widgets/indexing_progress.dart';
import 'package:qdexcode_desktop/features/dashboard/widgets/language_chart.dart';
import 'package:qdexcode_desktop/features/dashboard/widgets/module_chart.dart';
import 'package:qdexcode_desktop/features/dashboard/widgets/stat_card.dart';
import 'package:qdexcode_desktop/features/dashboard/widgets/symbol_chart.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

/// Dashboard tab content showing project statistics and charts.
///
/// Watches [selectedProjectProvider] via the stats provider so it
/// automatically refetches when the user switches projects.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final projectAsync = ref.watch(selectedProjectProvider);

    return statsAsync.when(
      loading: () => const _DashboardSkeleton(),
      error: (error, _) => _DashboardError(
        message: _friendlyError(error),
        onRetry: () => ref.invalidate(dashboardStatsProvider),
      ),
      data: (stats) {
        final project = projectAsync.valueOrNull;
        return _DashboardContent(stats: stats, project: project);
      },
    );
  }

  String _friendlyError(Object error) {
    final msg = error.toString();
    if (msg.contains('No project selected')) {
      return 'Select a project to view dashboard stats';
    }
    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return 'Unable to reach the server. Check your internet connection.';
    }
    return 'Failed to load stats';
  }
}

// ---------------------------------------------------------------------------
// Dashboard content (data loaded)
// ---------------------------------------------------------------------------

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.stats, this.project});

  final ProjectStats stats;
  final dynamic project; // Project? but avoid import cycle in type

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // -- Breadcrumb / section header --
        _SectionHeader(
          text:
              'Codebase Summary  ·  Symbol distribution  ·  Call graph resolution  ·  Vector embedding',
          color: cs.onTertiary,
        ),
        const SizedBox(height: 12),

        // -- Top row: 4 stat cards --
        _StatCardRow(stats: stats),
        const SizedBox(height: 12),

        // -- Secondary stats row --
        _SecondaryStatsRow(stats: stats),
        const SizedBox(height: 12),

        // -- Indexing progress --
        if (project != null)
          IndexingProgress(
            indexStatus: project.indexStatus,
            lastIndexedAt: stats.lastIndexedAt,
          ),
        if (project != null) const SizedBox(height: 16),

        // -- Charts row: Language + Symbol composition side by side --
        SizedBox(
          height: 240,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LanguageChart(languages: stats.languages),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SymbolChart(symbolKinds: stats.symbolKinds),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // -- Top modules bar chart --
        SizedBox(
          height: 260,
          child: ModuleChart(modules: stats.topModules),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stat card row
// ---------------------------------------------------------------------------

class _StatCardRow extends StatelessWidget {
  const _StatCardRow({required this.stats});

  final ProjectStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Files',
            value: _format(stats.totalFiles),
            icon: Icons.insert_drive_file_outlined,
            iconColor: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Symbols',
            value: _format(stats.totalSymbols),
            icon: Icons.code_outlined,
            iconColor: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Edges',
            value: _format(stats.totalEdges),
            icon: Icons.share_outlined,
            iconColor: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            label: 'Vectors',
            value: _format(stats.totalVectors),
            icon: Icons.scatter_plot_outlined,
            iconColor: const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Secondary stats row
// ---------------------------------------------------------------------------

class _SecondaryStatsRow extends StatelessWidget {
  const _SecondaryStatsRow({required this.stats});

  final ProjectStats stats;

  @override
  Widget build(BuildContext context) {
    final coveragePct = (stats.embeddingCoverage * 100).clamp(0, 100);

    return Row(
      children: [
        Expanded(
          child: SecondaryStatItem(
            label: 'Total Files',
            value: _format(stats.totalFiles),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SecondaryStatItem(
            label: 'Total Symbols',
            value: _format(stats.totalSymbols),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SecondaryStatItem(
            label: 'Total Edges',
            value: _format(stats.totalEdges),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SecondaryStatItem(
            label: 'Syncing Coverage',
            value: '${coveragePct.toStringAsFixed(0)}%',
            trailing: CoverageBar(
              coverage: stats.embeddingCoverage,
              color: coveragePct >= 100
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF6366F1),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: 11,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loading state
// ---------------------------------------------------------------------------

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Skeleton stat cards
        const Row(
          children: [
            Expanded(child: StatCardSkeleton()),
            SizedBox(width: 10),
            Expanded(child: StatCardSkeleton()),
            SizedBox(width: 10),
            Expanded(child: StatCardSkeleton()),
            SizedBox(width: 10),
            Expanded(child: StatCardSkeleton()),
          ],
        ),
        const SizedBox(height: 12),
        // Skeleton secondary row
        const Row(
          children: [
            Expanded(child: StatCardSkeleton()),
            SizedBox(width: 10),
            Expanded(child: StatCardSkeleton()),
            SizedBox(width: 10),
            Expanded(child: StatCardSkeleton()),
            SizedBox(width: 10),
            Expanded(child: StatCardSkeleton()),
          ],
        ),
        const SizedBox(height: 16),
        // Skeleton charts
        const Row(
          children: [
            Expanded(child: _SkeletonCard(height: 240)),
            SizedBox(width: 12),
            Expanded(child: _SkeletonCard(height: 240)),
          ],
        ),
        const SizedBox(height: 16),
        const _SkeletonCard(height: 260),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 40, color: cs.onTertiary),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Formats large numbers with comma separators.
String _format(int value) {
  if (value < 1000) return value.toString();
  final str = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(str[i]);
  }
  return buffer.toString();
}
