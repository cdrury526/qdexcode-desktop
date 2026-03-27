/// Project model matching the Drizzle project schema.
///
/// Maps to: packages/db/schema/projects.ts (project table).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

/// The indexing status of a project.
enum IndexStatus {
  idle,
  indexing,
  @JsonValue('index_failed')
  indexFailed,
  indexed,
}

/// The webhook installation status for a project.
enum WebhookStatus {
  none,
  pending,
  active,
  failed,
}

/// A code project from the `project` table.
@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String organizationId,
    required String name,
    required String cloneUrl,
    @Default('main') String defaultBranch,
    String? lastIndexedCommitSha,
    @Default(IndexStatus.idle) IndexStatus indexStatus,
    @Default(false) bool dirtyFlag,
    String? webhookId,
    String? webhookSecret,
    @Default(WebhookStatus.none) WebhookStatus webhookStatus,
    String? localPath,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
