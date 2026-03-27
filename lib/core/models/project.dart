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
    @JsonKey(name: 'organization_id') required String organizationId,
    required String name,
    @JsonKey(name: 'clone_url') required String cloneUrl,
    @JsonKey(name: 'default_branch') @Default('main') String defaultBranch,
    @JsonKey(name: 'last_indexed_commit_sha') String? lastIndexedCommitSha,
    @JsonKey(name: 'index_status') @Default(IndexStatus.idle) IndexStatus indexStatus,
    @JsonKey(name: 'dirty_flag') @Default(false) bool dirtyFlag,
    @JsonKey(name: 'webhook_id') String? webhookId,
    @JsonKey(name: 'webhook_secret') String? webhookSecret,
    @JsonKey(name: 'webhook_status') @Default(WebhookStatus.none) WebhookStatus webhookStatus,
    @JsonKey(name: 'local_path') String? localPath,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
