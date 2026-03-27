/// Planning models matching the Drizzle planning schema.
///
/// Maps to: packages/db/schema/planning.ts
/// (plan, phase, task, subtask, acceptance_criteria, file_scope tables).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

// =============================================================================
// ENUMS
// =============================================================================

/// Status of a plan.
enum PlanStatus {
  active,
  completed,
  archived,
}

/// Status of a phase.
enum PhaseStatus {
  pending,
  @JsonValue('in_progress')
  inProgress,
  completed,
  blocked,
}

/// Status of a task.
enum TaskStatus {
  pending,
  ready,
  @JsonValue('in_progress')
  inProgress,
  done,
  blocked,
  canceled,
}

/// Status of a subtask.
enum SubtaskStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('in_progress')
  inProgress,
  done,
  skipped,
}

/// Branch management status for a plan.
enum BranchStatus {
  none,
  active,
  merged,
}

/// Type of acceptance criteria.
enum CriteriaType {
  manual,
  build,
  test,
  lint,
  command,
}

/// Type of file scope (read, write, or create).
enum FileScopeType {
  read,
  write,
  create,
}

// =============================================================================
// MODELS
// =============================================================================

/// A plan from the `plan` table.
@freezed
abstract class Plan with _$Plan {
  const factory Plan({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'project_id') required String projectId,
    required String name,
    String? goal,
    String? description,
    @Default(PlanStatus.active) PlanStatus status,
    @JsonKey(name: 'flow_diagram') String? flowDiagram,
    @JsonKey(name: 'completion_pct') @Default(0) double completionPct,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'branch_name') String? branchName,
    @JsonKey(name: 'branch_status') @Default(BranchStatus.none) BranchStatus branchStatus,
    @JsonKey(name: 'branch_enable_count') @Default(0) int branchEnableCount,
    @JsonKey(name: 'worktree_path') String? worktreePath,
    @JsonKey(name: 'quality_score') double? qualityScore,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    /// Nested phases, populated by API responses that include relations.
    List<Phase>? phases,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}

/// A phase within a plan, from the `phase` table.
@freezed
abstract class Phase with _$Phase {
  const factory Phase({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'plan_id') required String planId,
    required String name,
    String? description,
    @Default(PhaseStatus.pending) PhaseStatus status,
    @JsonKey(name: 'order_index') @Default(0) int orderIndex,
    @JsonKey(name: 'flow_diagram') String? flowDiagram,
    @JsonKey(name: 'blocker_reason') String? blockerReason,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    /// Nested tasks, populated by API responses that include relations.
    List<Task>? tasks,
  }) = _Phase;

  factory Phase.fromJson(Map<String, dynamic> json) => _$PhaseFromJson(json);
}

/// A task within a phase, from the `task` table.
@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'phase_id') required String phaseId,
    @JsonKey(name: 'plan_id') required String planId,
    required String name,
    String? description,
    @Default(TaskStatus.pending) TaskStatus status,
    @JsonKey(name: 'assigned_agent') String? assignedAgent,
    String? skill,
    @JsonKey(name: 'execution_group') int? executionGroup,
    @JsonKey(name: 'order_index') @Default(0) int orderIndex,
    @JsonKey(name: 'completion_summary') Map<String, dynamic>? completionSummary,
    @JsonKey(name: 'blocker_reason') String? blockerReason,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    /// Nested subtasks, populated by API responses that include relations.
    List<Subtask>? subtasks,

    /// Nested acceptance criteria, populated by API responses.
    @JsonKey(name: 'acceptance_criteria')
    List<AcceptanceCriteria>? acceptanceCriteria,

    /// Nested file scopes, populated by API responses.
    @JsonKey(name: 'file_scopes') List<FileScope>? fileScopes,

    /// IDs of tasks this task depends on.
    @JsonKey(name: 'depends_on') List<String>? dependsOn,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

/// A subtask within a task, from the `subtask` table.
@freezed
abstract class Subtask with _$Subtask {
  const factory Subtask({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'task_id') required String taskId,
    required String details,
    @Default(SubtaskStatus.notStarted) SubtaskStatus status,
    @JsonKey(name: 'order_number') @Default(0) int orderNumber,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Subtask;

  factory Subtask.fromJson(Map<String, dynamic> json) =>
      _$SubtaskFromJson(json);
}

/// Acceptance criteria for a task, from the `acceptance_criteria` table.
@freezed
abstract class AcceptanceCriteria with _$AcceptanceCriteria {
  const factory AcceptanceCriteria({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'task_id') required String taskId,
    required String description,
    @JsonKey(name: 'criteria_type') @Default(CriteriaType.manual) CriteriaType criteriaType,
    String? command,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AcceptanceCriteria;

  factory AcceptanceCriteria.fromJson(Map<String, dynamic> json) =>
      _$AcceptanceCriteriaFromJson(json);
}

/// A file scope entry for a task, from the `file_scope` table.
@freezed
abstract class FileScope with _$FileScope {
  const factory FileScope({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'task_id') required String taskId,
    @JsonKey(name: 'file_path') required String filePath,
    @JsonKey(name: 'scope_type') required FileScopeType scopeType,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _FileScope;

  factory FileScope.fromJson(Map<String, dynamic> json) =>
      _$FileScopeFromJson(json);
}
