// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Plan _$PlanFromJson(Map<String, dynamic> json) => _Plan(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  projectId: json['project_id'] as String,
  name: json['name'] as String,
  goal: json['goal'] as String?,
  description: json['description'] as String?,
  status:
      $enumDecodeNullable(_$PlanStatusEnumMap, json['status']) ??
      PlanStatus.active,
  flowDiagram: json['flow_diagram'] as String?,
  completionPct: (json['completion_pct'] as num?)?.toDouble() ?? 0,
  metadata: json['metadata'] as Map<String, dynamic>?,
  branchName: json['branch_name'] as String?,
  branchStatus:
      $enumDecodeNullable(_$BranchStatusEnumMap, json['branch_status']) ??
      BranchStatus.none,
  branchEnableCount: (json['branch_enable_count'] as num?)?.toInt() ?? 0,
  worktreePath: json['worktree_path'] as String?,
  qualityScore: (json['quality_score'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  phases: (json['phases'] as List<dynamic>?)
      ?.map((e) => Phase.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlanToJson(_Plan instance) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'project_id': instance.projectId,
  'name': instance.name,
  'goal': instance.goal,
  'description': instance.description,
  'status': _$PlanStatusEnumMap[instance.status]!,
  'flow_diagram': instance.flowDiagram,
  'completion_pct': instance.completionPct,
  'metadata': instance.metadata,
  'branch_name': instance.branchName,
  'branch_status': _$BranchStatusEnumMap[instance.branchStatus]!,
  'branch_enable_count': instance.branchEnableCount,
  'worktree_path': instance.worktreePath,
  'quality_score': instance.qualityScore,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'phases': instance.phases,
};

const _$PlanStatusEnumMap = {
  PlanStatus.active: 'active',
  PlanStatus.completed: 'completed',
  PlanStatus.archived: 'archived',
};

const _$BranchStatusEnumMap = {
  BranchStatus.none: 'none',
  BranchStatus.active: 'active',
  BranchStatus.merged: 'merged',
};

_Phase _$PhaseFromJson(Map<String, dynamic> json) => _Phase(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  planId: json['plan_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  status:
      $enumDecodeNullable(_$PhaseStatusEnumMap, json['status']) ??
      PhaseStatus.pending,
  orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
  flowDiagram: json['flow_diagram'] as String?,
  blockerReason: json['blocker_reason'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  tasks: (json['tasks'] as List<dynamic>?)
      ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PhaseToJson(_Phase instance) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'plan_id': instance.planId,
  'name': instance.name,
  'description': instance.description,
  'status': _$PhaseStatusEnumMap[instance.status]!,
  'order_index': instance.orderIndex,
  'flow_diagram': instance.flowDiagram,
  'blocker_reason': instance.blockerReason,
  'metadata': instance.metadata,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'tasks': instance.tasks,
};

const _$PhaseStatusEnumMap = {
  PhaseStatus.pending: 'pending',
  PhaseStatus.inProgress: 'in_progress',
  PhaseStatus.completed: 'completed',
  PhaseStatus.blocked: 'blocked',
};

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  phaseId: json['phase_id'] as String,
  planId: json['plan_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  status:
      $enumDecodeNullable(_$TaskStatusEnumMap, json['status']) ??
      TaskStatus.pending,
  assignedAgent: json['assigned_agent'] as String?,
  skill: json['skill'] as String?,
  executionGroup: (json['execution_group'] as num?)?.toInt(),
  orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
  completionSummary: json['completion_summary'] as Map<String, dynamic>?,
  blockerReason: json['blocker_reason'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  subtasks: (json['subtasks'] as List<dynamic>?)
      ?.map((e) => Subtask.fromJson(e as Map<String, dynamic>))
      .toList(),
  acceptanceCriteria: (json['acceptance_criteria'] as List<dynamic>?)
      ?.map((e) => AcceptanceCriteria.fromJson(e as Map<String, dynamic>))
      .toList(),
  fileScopes: (json['file_scopes'] as List<dynamic>?)
      ?.map((e) => FileScope.fromJson(e as Map<String, dynamic>))
      .toList(),
  dependsOn: (json['depends_on'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'phase_id': instance.phaseId,
  'plan_id': instance.planId,
  'name': instance.name,
  'description': instance.description,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'assigned_agent': instance.assignedAgent,
  'skill': instance.skill,
  'execution_group': instance.executionGroup,
  'order_index': instance.orderIndex,
  'completion_summary': instance.completionSummary,
  'blocker_reason': instance.blockerReason,
  'metadata': instance.metadata,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'subtasks': instance.subtasks,
  'acceptance_criteria': instance.acceptanceCriteria,
  'file_scopes': instance.fileScopes,
  'depends_on': instance.dependsOn,
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.ready: 'ready',
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.done: 'done',
  TaskStatus.blocked: 'blocked',
  TaskStatus.canceled: 'canceled',
};

_Subtask _$SubtaskFromJson(Map<String, dynamic> json) => _Subtask(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  taskId: json['task_id'] as String,
  details: json['details'] as String,
  status:
      $enumDecodeNullable(_$SubtaskStatusEnumMap, json['status']) ??
      SubtaskStatus.notStarted,
  orderNumber: (json['order_number'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SubtaskToJson(_Subtask instance) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'task_id': instance.taskId,
  'details': instance.details,
  'status': _$SubtaskStatusEnumMap[instance.status]!,
  'order_number': instance.orderNumber,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$SubtaskStatusEnumMap = {
  SubtaskStatus.notStarted: 'not_started',
  SubtaskStatus.inProgress: 'in_progress',
  SubtaskStatus.done: 'done',
  SubtaskStatus.skipped: 'skipped',
};

_AcceptanceCriteria _$AcceptanceCriteriaFromJson(Map<String, dynamic> json) =>
    _AcceptanceCriteria(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      taskId: json['task_id'] as String,
      description: json['description'] as String,
      criteriaType:
          $enumDecodeNullable(_$CriteriaTypeEnumMap, json['criteria_type']) ??
          CriteriaType.manual,
      command: json['command'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AcceptanceCriteriaToJson(_AcceptanceCriteria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'task_id': instance.taskId,
      'description': instance.description,
      'criteria_type': _$CriteriaTypeEnumMap[instance.criteriaType]!,
      'command': instance.command,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$CriteriaTypeEnumMap = {
  CriteriaType.manual: 'manual',
  CriteriaType.build: 'build',
  CriteriaType.test: 'test',
  CriteriaType.lint: 'lint',
  CriteriaType.command: 'command',
};

_FileScope _$FileScopeFromJson(Map<String, dynamic> json) => _FileScope(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  taskId: json['task_id'] as String,
  filePath: json['file_path'] as String,
  scopeType: $enumDecode(_$FileScopeTypeEnumMap, json['scope_type']),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$FileScopeToJson(_FileScope instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'task_id': instance.taskId,
      'file_path': instance.filePath,
      'scope_type': _$FileScopeTypeEnumMap[instance.scopeType]!,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$FileScopeTypeEnumMap = {
  FileScopeType.read: 'read',
  FileScopeType.write: 'write',
  FileScopeType.create: 'create',
};
