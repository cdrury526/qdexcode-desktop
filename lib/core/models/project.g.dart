// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  name: json['name'] as String,
  cloneUrl: json['cloneUrl'] as String,
  defaultBranch: json['defaultBranch'] as String? ?? 'main',
  lastIndexedCommitSha: json['lastIndexedCommitSha'] as String?,
  indexStatus:
      $enumDecodeNullable(_$IndexStatusEnumMap, json['indexStatus']) ??
      IndexStatus.idle,
  dirtyFlag: json['dirtyFlag'] as bool? ?? false,
  webhookId: json['webhookId'] as String?,
  webhookSecret: json['webhookSecret'] as String?,
  webhookStatus:
      $enumDecodeNullable(_$WebhookStatusEnumMap, json['webhookStatus']) ??
      WebhookStatus.none,
  localPath: json['localPath'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'name': instance.name,
  'cloneUrl': instance.cloneUrl,
  'defaultBranch': instance.defaultBranch,
  'lastIndexedCommitSha': instance.lastIndexedCommitSha,
  'indexStatus': _$IndexStatusEnumMap[instance.indexStatus]!,
  'dirtyFlag': instance.dirtyFlag,
  'webhookId': instance.webhookId,
  'webhookSecret': instance.webhookSecret,
  'webhookStatus': _$WebhookStatusEnumMap[instance.webhookStatus]!,
  'localPath': instance.localPath,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$IndexStatusEnumMap = {
  IndexStatus.idle: 'idle',
  IndexStatus.indexing: 'indexing',
  IndexStatus.indexFailed: 'index_failed',
  IndexStatus.indexed: 'indexed',
};

const _$WebhookStatusEnumMap = {
  WebhookStatus.none: 'none',
  WebhookStatus.pending: 'pending',
  WebhookStatus.active: 'active',
  WebhookStatus.failed: 'failed',
};
