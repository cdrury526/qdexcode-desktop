// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IndexingProgress _$IndexingProgressFromJson(Map<String, dynamic> json) =>
    _IndexingProgress(
      projectId: json['project_id'] as String,
      currentFile: json['current_file'] as String?,
      filesDone: (json['files_done'] as num?)?.toInt() ?? 0,
      filesTotal: (json['files_total'] as num?)?.toInt() ?? 0,
      status:
          $enumDecodeNullable(_$IndexingStatusEnumMap, json['status']) ??
          IndexingStatus.idle,
      error: json['error'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$IndexingProgressToJson(_IndexingProgress instance) =>
    <String, dynamic>{
      'project_id': instance.projectId,
      'current_file': instance.currentFile,
      'files_done': instance.filesDone,
      'files_total': instance.filesTotal,
      'status': _$IndexingStatusEnumMap[instance.status]!,
      'error': instance.error,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

const _$IndexingStatusEnumMap = {
  IndexingStatus.idle: 'idle',
  IndexingStatus.cloning: 'cloning',
  IndexingStatus.parsing: 'parsing',
  IndexingStatus.embedding: 'embedding',
  IndexingStatus.generatingHierarchy: 'generating_hierarchy',
  IndexingStatus.completed: 'completed',
  IndexingStatus.failed: 'failed',
};
