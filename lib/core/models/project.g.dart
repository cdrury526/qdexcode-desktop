// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  name: json['name'] as String,
  cloneUrl: json['clone_url'] as String,
  defaultBranch: json['default_branch'] as String? ?? 'main',
  lastIndexedCommitSha: json['last_indexed_commit_sha'] as String?,
  indexStatus:
      $enumDecodeNullable(_$IndexStatusEnumMap, json['index_status']) ??
      IndexStatus.idle,
  dirtyFlag: json['dirty_flag'] as bool? ?? false,
  webhookId: json['webhook_id'] as String?,
  webhookSecret: json['webhook_secret'] as String?,
  webhookStatus:
      $enumDecodeNullable(_$WebhookStatusEnumMap, json['webhook_status']) ??
      WebhookStatus.none,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'name': instance.name,
  'clone_url': instance.cloneUrl,
  'default_branch': instance.defaultBranch,
  'last_indexed_commit_sha': instance.lastIndexedCommitSha,
  'index_status': _$IndexStatusEnumMap[instance.indexStatus]!,
  'dirty_flag': instance.dirtyFlag,
  'webhook_id': instance.webhookId,
  'webhook_secret': instance.webhookSecret,
  'webhook_status': _$WebhookStatusEnumMap[instance.webhookStatus]!,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
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
