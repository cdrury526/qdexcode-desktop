/// Indexing progress model for realtime updates.
///
/// This model represents the data sent via `pg_notify('index_progress')`
/// from the Go indexer during parsing. It is not a direct table mapping
/// but matches the NOTIFY payload structure used by pg-bridge.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'indexing.freezed.dart';
part 'indexing.g.dart';

/// The current status of an indexing operation.
enum IndexingStatus {
  idle,
  cloning,
  parsing,
  embedding,
  @JsonValue('generating_hierarchy')
  generatingHierarchy,
  completed,
  failed,
}

/// Real-time indexing progress broadcast via pg-bridge WebSocket.
///
/// Emitted by the Go indexer every 500ms during parsing via
/// `pg_notify('index_progress', ...)`.
@freezed
abstract class IndexingProgress with _$IndexingProgress {
  const factory IndexingProgress({
    @JsonKey(name: 'project_id') required String projectId,
    @JsonKey(name: 'current_file') String? currentFile,
    @JsonKey(name: 'files_done') @Default(0) int filesDone,
    @JsonKey(name: 'files_total') @Default(0) int filesTotal,
    @Default(IndexingStatus.idle) IndexingStatus status,
    String? error,

    /// Timestamp of this progress update.
    DateTime? timestamp,
  }) = _IndexingProgress;

  factory IndexingProgress.fromJson(Map<String, dynamic> json) =>
      _$IndexingProgressFromJson(json);
}
