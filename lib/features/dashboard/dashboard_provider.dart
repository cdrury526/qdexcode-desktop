/// Riverpod providers for dashboard stats.
///
/// Fetches project statistics from GET /api/stats?projectId=X and
/// auto-invalidates when the selected project changes.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:qdexcode_desktop/core/api/api_client.dart';
import 'package:qdexcode_desktop/features/projects/project_provider.dart';

part 'dashboard_provider.g.dart';

// ---------------------------------------------------------------------------
// Stats data model
// ---------------------------------------------------------------------------

/// Aggregated project statistics returned by /api/stats.
class ProjectStats {
  const ProjectStats({
    required this.totalFiles,
    required this.totalSymbols,
    required this.totalEdges,
    required this.totalVectors,
    required this.embeddingCoverage,
    required this.languages,
    required this.symbolKinds,
    required this.topModules,
    this.lastIndexedAt,
  });

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    return ProjectStats(
      totalFiles: _intFrom(json['total_files']),
      totalSymbols: _intFrom(json['total_symbols']),
      totalEdges: _intFrom(json['total_edges']),
      totalVectors: _intFrom(json['total_vectors']),
      embeddingCoverage: _doubleFrom(json['embedding_coverage']),
      languages: _parseLanguages(json['languages']),
      symbolKinds: _parseSymbolKinds(json['symbol_kinds']),
      topModules: _parseTopModules(json['top_modules']),
      lastIndexedAt: json['last_indexed_at'] != null
          ? DateTime.tryParse(json['last_indexed_at'] as String)
          : null,
    );
  }

  final int totalFiles;
  final int totalSymbols;
  final int totalEdges;
  final int totalVectors;
  final double embeddingCoverage; // 0.0 to 1.0
  final List<LanguageStat> languages;
  final List<SymbolKindStat> symbolKinds;
  final List<ModuleStat> topModules;
  final DateTime? lastIndexedAt;

  static int _intFrom(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _doubleFrom(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static List<LanguageStat> _parseLanguages(dynamic data) {
    if (data is! List) return [];
    return data
        .map((e) => LanguageStat(
              name: (e as Map<String, dynamic>)['name'] as String? ?? '',
              fileCount: _intFrom(e['file_count']),
              percentage: _doubleFrom(e['percentage']),
            ))
        .toList();
  }

  static List<SymbolKindStat> _parseSymbolKinds(dynamic data) {
    if (data is! List) return [];
    return data
        .map((e) => SymbolKindStat(
              kind: (e as Map<String, dynamic>)['kind'] as String? ?? '',
              count: _intFrom(e['count']),
            ))
        .toList();
  }

  static List<ModuleStat> _parseTopModules(dynamic data) {
    if (data is! List) return [];
    return data
        .map((e) => ModuleStat(
              path: (e as Map<String, dynamic>)['path'] as String? ?? '',
              symbolCount: _intFrom(e['symbol_count']),
            ))
        .toList();
  }
}

/// Language distribution entry.
class LanguageStat {
  const LanguageStat({
    required this.name,
    required this.fileCount,
    required this.percentage,
  });

  final String name;
  final int fileCount;
  final double percentage;
}

/// Symbol kind breakdown entry.
class SymbolKindStat {
  const SymbolKindStat({
    required this.kind,
    required this.count,
  });

  final String kind;
  final int count;
}

/// Top module entry.
class ModuleStat {
  const ModuleStat({
    required this.path,
    required this.symbolCount,
  });

  final String path;
  final int symbolCount;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Fetches dashboard stats for the currently selected project.
///
/// Watches [selectedProjectProvider] so stats automatically refetch
/// when the user switches projects.
@riverpod
Future<ProjectStats> dashboardStats(Ref ref) async {
  final project = await ref.watch(selectedProjectProvider.future);
  if (project == null) {
    throw Exception('No project selected');
  }

  final dio = ref.watch(apiClientProvider);
  final response = await dio.get<Map<String, dynamic>>(
    '/api/stats',
    queryParameters: {'projectId': project.id},
  );

  final data = response.data;
  if (data == null) {
    throw Exception('Empty stats response');
  }

  return ProjectStats.fromJson(data);
}
