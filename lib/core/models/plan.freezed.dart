// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Plan {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'project_id') String get projectId; String get name; String? get goal; String? get description; PlanStatus get status;@JsonKey(name: 'flow_diagram') String? get flowDiagram;@JsonKey(name: 'completion_pct') double get completionPct; Map<String, dynamic>? get metadata;@JsonKey(name: 'branch_name') String? get branchName;@JsonKey(name: 'branch_status') BranchStatus get branchStatus;@JsonKey(name: 'branch_enable_count') int get branchEnableCount;@JsonKey(name: 'worktree_path') String? get worktreePath;@JsonKey(name: 'quality_score') double? get qualityScore;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;/// Nested phases, populated by API responses that include relations.
 List<Phase>? get phases;
/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanCopyWith<Plan> get copyWith => _$PlanCopyWithImpl<Plan>(this as Plan, _$identity);

  /// Serializes this Plan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Plan&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.flowDiagram, flowDiagram) || other.flowDiagram == flowDiagram)&&(identical(other.completionPct, completionPct) || other.completionPct == completionPct)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.branchStatus, branchStatus) || other.branchStatus == branchStatus)&&(identical(other.branchEnableCount, branchEnableCount) || other.branchEnableCount == branchEnableCount)&&(identical(other.worktreePath, worktreePath) || other.worktreePath == worktreePath)&&(identical(other.qualityScore, qualityScore) || other.qualityScore == qualityScore)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.phases, phases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,projectId,name,goal,description,status,flowDiagram,completionPct,const DeepCollectionEquality().hash(metadata),branchName,branchStatus,branchEnableCount,worktreePath,qualityScore,createdAt,updatedAt,const DeepCollectionEquality().hash(phases));

@override
String toString() {
  return 'Plan(id: $id, organizationId: $organizationId, projectId: $projectId, name: $name, goal: $goal, description: $description, status: $status, flowDiagram: $flowDiagram, completionPct: $completionPct, metadata: $metadata, branchName: $branchName, branchStatus: $branchStatus, branchEnableCount: $branchEnableCount, worktreePath: $worktreePath, qualityScore: $qualityScore, createdAt: $createdAt, updatedAt: $updatedAt, phases: $phases)';
}


}

/// @nodoc
abstract mixin class $PlanCopyWith<$Res>  {
  factory $PlanCopyWith(Plan value, $Res Function(Plan) _then) = _$PlanCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'project_id') String projectId, String name, String? goal, String? description, PlanStatus status,@JsonKey(name: 'flow_diagram') String? flowDiagram,@JsonKey(name: 'completion_pct') double completionPct, Map<String, dynamic>? metadata,@JsonKey(name: 'branch_name') String? branchName,@JsonKey(name: 'branch_status') BranchStatus branchStatus,@JsonKey(name: 'branch_enable_count') int branchEnableCount,@JsonKey(name: 'worktree_path') String? worktreePath,@JsonKey(name: 'quality_score') double? qualityScore,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, List<Phase>? phases
});




}
/// @nodoc
class _$PlanCopyWithImpl<$Res>
    implements $PlanCopyWith<$Res> {
  _$PlanCopyWithImpl(this._self, this._then);

  final Plan _self;
  final $Res Function(Plan) _then;

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? projectId = null,Object? name = null,Object? goal = freezed,Object? description = freezed,Object? status = null,Object? flowDiagram = freezed,Object? completionPct = null,Object? metadata = freezed,Object? branchName = freezed,Object? branchStatus = null,Object? branchEnableCount = null,Object? worktreePath = freezed,Object? qualityScore = freezed,Object? createdAt = null,Object? updatedAt = null,Object? phases = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlanStatus,flowDiagram: freezed == flowDiagram ? _self.flowDiagram : flowDiagram // ignore: cast_nullable_to_non_nullable
as String?,completionPct: null == completionPct ? _self.completionPct : completionPct // ignore: cast_nullable_to_non_nullable
as double,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,branchStatus: null == branchStatus ? _self.branchStatus : branchStatus // ignore: cast_nullable_to_non_nullable
as BranchStatus,branchEnableCount: null == branchEnableCount ? _self.branchEnableCount : branchEnableCount // ignore: cast_nullable_to_non_nullable
as int,worktreePath: freezed == worktreePath ? _self.worktreePath : worktreePath // ignore: cast_nullable_to_non_nullable
as String?,qualityScore: freezed == qualityScore ? _self.qualityScore : qualityScore // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,phases: freezed == phases ? _self.phases : phases // ignore: cast_nullable_to_non_nullable
as List<Phase>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Plan].
extension PlanPatterns on Plan {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Plan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Plan() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Plan value)  $default,){
final _that = this;
switch (_that) {
case _Plan():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Plan value)?  $default,){
final _that = this;
switch (_that) {
case _Plan() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'project_id')  String projectId,  String name,  String? goal,  String? description,  PlanStatus status, @JsonKey(name: 'flow_diagram')  String? flowDiagram, @JsonKey(name: 'completion_pct')  double completionPct,  Map<String, dynamic>? metadata, @JsonKey(name: 'branch_name')  String? branchName, @JsonKey(name: 'branch_status')  BranchStatus branchStatus, @JsonKey(name: 'branch_enable_count')  int branchEnableCount, @JsonKey(name: 'worktree_path')  String? worktreePath, @JsonKey(name: 'quality_score')  double? qualityScore, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<Phase>? phases)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Plan() when $default != null:
return $default(_that.id,_that.organizationId,_that.projectId,_that.name,_that.goal,_that.description,_that.status,_that.flowDiagram,_that.completionPct,_that.metadata,_that.branchName,_that.branchStatus,_that.branchEnableCount,_that.worktreePath,_that.qualityScore,_that.createdAt,_that.updatedAt,_that.phases);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'project_id')  String projectId,  String name,  String? goal,  String? description,  PlanStatus status, @JsonKey(name: 'flow_diagram')  String? flowDiagram, @JsonKey(name: 'completion_pct')  double completionPct,  Map<String, dynamic>? metadata, @JsonKey(name: 'branch_name')  String? branchName, @JsonKey(name: 'branch_status')  BranchStatus branchStatus, @JsonKey(name: 'branch_enable_count')  int branchEnableCount, @JsonKey(name: 'worktree_path')  String? worktreePath, @JsonKey(name: 'quality_score')  double? qualityScore, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<Phase>? phases)  $default,) {final _that = this;
switch (_that) {
case _Plan():
return $default(_that.id,_that.organizationId,_that.projectId,_that.name,_that.goal,_that.description,_that.status,_that.flowDiagram,_that.completionPct,_that.metadata,_that.branchName,_that.branchStatus,_that.branchEnableCount,_that.worktreePath,_that.qualityScore,_that.createdAt,_that.updatedAt,_that.phases);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'project_id')  String projectId,  String name,  String? goal,  String? description,  PlanStatus status, @JsonKey(name: 'flow_diagram')  String? flowDiagram, @JsonKey(name: 'completion_pct')  double completionPct,  Map<String, dynamic>? metadata, @JsonKey(name: 'branch_name')  String? branchName, @JsonKey(name: 'branch_status')  BranchStatus branchStatus, @JsonKey(name: 'branch_enable_count')  int branchEnableCount, @JsonKey(name: 'worktree_path')  String? worktreePath, @JsonKey(name: 'quality_score')  double? qualityScore, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<Phase>? phases)?  $default,) {final _that = this;
switch (_that) {
case _Plan() when $default != null:
return $default(_that.id,_that.organizationId,_that.projectId,_that.name,_that.goal,_that.description,_that.status,_that.flowDiagram,_that.completionPct,_that.metadata,_that.branchName,_that.branchStatus,_that.branchEnableCount,_that.worktreePath,_that.qualityScore,_that.createdAt,_that.updatedAt,_that.phases);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Plan implements Plan {
  const _Plan({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'project_id') required this.projectId, required this.name, this.goal, this.description, this.status = PlanStatus.active, @JsonKey(name: 'flow_diagram') this.flowDiagram, @JsonKey(name: 'completion_pct') this.completionPct = 0, final  Map<String, dynamic>? metadata, @JsonKey(name: 'branch_name') this.branchName, @JsonKey(name: 'branch_status') this.branchStatus = BranchStatus.none, @JsonKey(name: 'branch_enable_count') this.branchEnableCount = 0, @JsonKey(name: 'worktree_path') this.worktreePath, @JsonKey(name: 'quality_score') this.qualityScore, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, final  List<Phase>? phases}): _metadata = metadata,_phases = phases;
  factory _Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'project_id') final  String projectId;
@override final  String name;
@override final  String? goal;
@override final  String? description;
@override@JsonKey() final  PlanStatus status;
@override@JsonKey(name: 'flow_diagram') final  String? flowDiagram;
@override@JsonKey(name: 'completion_pct') final  double completionPct;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'branch_name') final  String? branchName;
@override@JsonKey(name: 'branch_status') final  BranchStatus branchStatus;
@override@JsonKey(name: 'branch_enable_count') final  int branchEnableCount;
@override@JsonKey(name: 'worktree_path') final  String? worktreePath;
@override@JsonKey(name: 'quality_score') final  double? qualityScore;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
/// Nested phases, populated by API responses that include relations.
 final  List<Phase>? _phases;
/// Nested phases, populated by API responses that include relations.
@override List<Phase>? get phases {
  final value = _phases;
  if (value == null) return null;
  if (_phases is EqualUnmodifiableListView) return _phases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanCopyWith<_Plan> get copyWith => __$PlanCopyWithImpl<_Plan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Plan&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.flowDiagram, flowDiagram) || other.flowDiagram == flowDiagram)&&(identical(other.completionPct, completionPct) || other.completionPct == completionPct)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.branchStatus, branchStatus) || other.branchStatus == branchStatus)&&(identical(other.branchEnableCount, branchEnableCount) || other.branchEnableCount == branchEnableCount)&&(identical(other.worktreePath, worktreePath) || other.worktreePath == worktreePath)&&(identical(other.qualityScore, qualityScore) || other.qualityScore == qualityScore)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._phases, _phases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,projectId,name,goal,description,status,flowDiagram,completionPct,const DeepCollectionEquality().hash(_metadata),branchName,branchStatus,branchEnableCount,worktreePath,qualityScore,createdAt,updatedAt,const DeepCollectionEquality().hash(_phases));

@override
String toString() {
  return 'Plan(id: $id, organizationId: $organizationId, projectId: $projectId, name: $name, goal: $goal, description: $description, status: $status, flowDiagram: $flowDiagram, completionPct: $completionPct, metadata: $metadata, branchName: $branchName, branchStatus: $branchStatus, branchEnableCount: $branchEnableCount, worktreePath: $worktreePath, qualityScore: $qualityScore, createdAt: $createdAt, updatedAt: $updatedAt, phases: $phases)';
}


}

/// @nodoc
abstract mixin class _$PlanCopyWith<$Res> implements $PlanCopyWith<$Res> {
  factory _$PlanCopyWith(_Plan value, $Res Function(_Plan) _then) = __$PlanCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'project_id') String projectId, String name, String? goal, String? description, PlanStatus status,@JsonKey(name: 'flow_diagram') String? flowDiagram,@JsonKey(name: 'completion_pct') double completionPct, Map<String, dynamic>? metadata,@JsonKey(name: 'branch_name') String? branchName,@JsonKey(name: 'branch_status') BranchStatus branchStatus,@JsonKey(name: 'branch_enable_count') int branchEnableCount,@JsonKey(name: 'worktree_path') String? worktreePath,@JsonKey(name: 'quality_score') double? qualityScore,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, List<Phase>? phases
});




}
/// @nodoc
class __$PlanCopyWithImpl<$Res>
    implements _$PlanCopyWith<$Res> {
  __$PlanCopyWithImpl(this._self, this._then);

  final _Plan _self;
  final $Res Function(_Plan) _then;

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? projectId = null,Object? name = null,Object? goal = freezed,Object? description = freezed,Object? status = null,Object? flowDiagram = freezed,Object? completionPct = null,Object? metadata = freezed,Object? branchName = freezed,Object? branchStatus = null,Object? branchEnableCount = null,Object? worktreePath = freezed,Object? qualityScore = freezed,Object? createdAt = null,Object? updatedAt = null,Object? phases = freezed,}) {
  return _then(_Plan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlanStatus,flowDiagram: freezed == flowDiagram ? _self.flowDiagram : flowDiagram // ignore: cast_nullable_to_non_nullable
as String?,completionPct: null == completionPct ? _self.completionPct : completionPct // ignore: cast_nullable_to_non_nullable
as double,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,branchStatus: null == branchStatus ? _self.branchStatus : branchStatus // ignore: cast_nullable_to_non_nullable
as BranchStatus,branchEnableCount: null == branchEnableCount ? _self.branchEnableCount : branchEnableCount // ignore: cast_nullable_to_non_nullable
as int,worktreePath: freezed == worktreePath ? _self.worktreePath : worktreePath // ignore: cast_nullable_to_non_nullable
as String?,qualityScore: freezed == qualityScore ? _self.qualityScore : qualityScore // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,phases: freezed == phases ? _self._phases : phases // ignore: cast_nullable_to_non_nullable
as List<Phase>?,
  ));
}


}


/// @nodoc
mixin _$Phase {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'plan_id') String get planId; String get name; String? get description; PhaseStatus get status;@JsonKey(name: 'order_index') int get orderIndex;@JsonKey(name: 'flow_diagram') String? get flowDiagram;@JsonKey(name: 'blocker_reason') String? get blockerReason; Map<String, dynamic>? get metadata;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;/// Nested tasks, populated by API responses that include relations.
 List<Task>? get tasks;
/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhaseCopyWith<Phase> get copyWith => _$PhaseCopyWithImpl<Phase>(this as Phase, _$identity);

  /// Serializes this Phase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Phase&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.flowDiagram, flowDiagram) || other.flowDiagram == flowDiagram)&&(identical(other.blockerReason, blockerReason) || other.blockerReason == blockerReason)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.tasks, tasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,planId,name,description,status,orderIndex,flowDiagram,blockerReason,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt,const DeepCollectionEquality().hash(tasks));

@override
String toString() {
  return 'Phase(id: $id, organizationId: $organizationId, planId: $planId, name: $name, description: $description, status: $status, orderIndex: $orderIndex, flowDiagram: $flowDiagram, blockerReason: $blockerReason, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class $PhaseCopyWith<$Res>  {
  factory $PhaseCopyWith(Phase value, $Res Function(Phase) _then) = _$PhaseCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'plan_id') String planId, String name, String? description, PhaseStatus status,@JsonKey(name: 'order_index') int orderIndex,@JsonKey(name: 'flow_diagram') String? flowDiagram,@JsonKey(name: 'blocker_reason') String? blockerReason, Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, List<Task>? tasks
});




}
/// @nodoc
class _$PhaseCopyWithImpl<$Res>
    implements $PhaseCopyWith<$Res> {
  _$PhaseCopyWithImpl(this._self, this._then);

  final Phase _self;
  final $Res Function(Phase) _then;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? planId = null,Object? name = null,Object? description = freezed,Object? status = null,Object? orderIndex = null,Object? flowDiagram = freezed,Object? blockerReason = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,Object? tasks = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PhaseStatus,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,flowDiagram: freezed == flowDiagram ? _self.flowDiagram : flowDiagram // ignore: cast_nullable_to_non_nullable
as String?,blockerReason: freezed == blockerReason ? _self.blockerReason : blockerReason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tasks: freezed == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<Task>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Phase].
extension PhasePatterns on Phase {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Phase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Phase() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Phase value)  $default,){
final _that = this;
switch (_that) {
case _Phase():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Phase value)?  $default,){
final _that = this;
switch (_that) {
case _Phase() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'plan_id')  String planId,  String name,  String? description,  PhaseStatus status, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'flow_diagram')  String? flowDiagram, @JsonKey(name: 'blocker_reason')  String? blockerReason,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<Task>? tasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Phase() when $default != null:
return $default(_that.id,_that.organizationId,_that.planId,_that.name,_that.description,_that.status,_that.orderIndex,_that.flowDiagram,_that.blockerReason,_that.metadata,_that.createdAt,_that.updatedAt,_that.tasks);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'plan_id')  String planId,  String name,  String? description,  PhaseStatus status, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'flow_diagram')  String? flowDiagram, @JsonKey(name: 'blocker_reason')  String? blockerReason,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<Task>? tasks)  $default,) {final _that = this;
switch (_that) {
case _Phase():
return $default(_that.id,_that.organizationId,_that.planId,_that.name,_that.description,_that.status,_that.orderIndex,_that.flowDiagram,_that.blockerReason,_that.metadata,_that.createdAt,_that.updatedAt,_that.tasks);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'plan_id')  String planId,  String name,  String? description,  PhaseStatus status, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'flow_diagram')  String? flowDiagram, @JsonKey(name: 'blocker_reason')  String? blockerReason,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<Task>? tasks)?  $default,) {final _that = this;
switch (_that) {
case _Phase() when $default != null:
return $default(_that.id,_that.organizationId,_that.planId,_that.name,_that.description,_that.status,_that.orderIndex,_that.flowDiagram,_that.blockerReason,_that.metadata,_that.createdAt,_that.updatedAt,_that.tasks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Phase implements Phase {
  const _Phase({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'plan_id') required this.planId, required this.name, this.description, this.status = PhaseStatus.pending, @JsonKey(name: 'order_index') this.orderIndex = 0, @JsonKey(name: 'flow_diagram') this.flowDiagram, @JsonKey(name: 'blocker_reason') this.blockerReason, final  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, final  List<Task>? tasks}): _metadata = metadata,_tasks = tasks;
  factory _Phase.fromJson(Map<String, dynamic> json) => _$PhaseFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'plan_id') final  String planId;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  PhaseStatus status;
@override@JsonKey(name: 'order_index') final  int orderIndex;
@override@JsonKey(name: 'flow_diagram') final  String? flowDiagram;
@override@JsonKey(name: 'blocker_reason') final  String? blockerReason;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
/// Nested tasks, populated by API responses that include relations.
 final  List<Task>? _tasks;
/// Nested tasks, populated by API responses that include relations.
@override List<Task>? get tasks {
  final value = _tasks;
  if (value == null) return null;
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhaseCopyWith<_Phase> get copyWith => __$PhaseCopyWithImpl<_Phase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Phase&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.flowDiagram, flowDiagram) || other.flowDiagram == flowDiagram)&&(identical(other.blockerReason, blockerReason) || other.blockerReason == blockerReason)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._tasks, _tasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,planId,name,description,status,orderIndex,flowDiagram,blockerReason,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt,const DeepCollectionEquality().hash(_tasks));

@override
String toString() {
  return 'Phase(id: $id, organizationId: $organizationId, planId: $planId, name: $name, description: $description, status: $status, orderIndex: $orderIndex, flowDiagram: $flowDiagram, blockerReason: $blockerReason, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class _$PhaseCopyWith<$Res> implements $PhaseCopyWith<$Res> {
  factory _$PhaseCopyWith(_Phase value, $Res Function(_Phase) _then) = __$PhaseCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'plan_id') String planId, String name, String? description, PhaseStatus status,@JsonKey(name: 'order_index') int orderIndex,@JsonKey(name: 'flow_diagram') String? flowDiagram,@JsonKey(name: 'blocker_reason') String? blockerReason, Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, List<Task>? tasks
});




}
/// @nodoc
class __$PhaseCopyWithImpl<$Res>
    implements _$PhaseCopyWith<$Res> {
  __$PhaseCopyWithImpl(this._self, this._then);

  final _Phase _self;
  final $Res Function(_Phase) _then;

/// Create a copy of Phase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? planId = null,Object? name = null,Object? description = freezed,Object? status = null,Object? orderIndex = null,Object? flowDiagram = freezed,Object? blockerReason = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,Object? tasks = freezed,}) {
  return _then(_Phase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PhaseStatus,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,flowDiagram: freezed == flowDiagram ? _self.flowDiagram : flowDiagram // ignore: cast_nullable_to_non_nullable
as String?,blockerReason: freezed == blockerReason ? _self.blockerReason : blockerReason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tasks: freezed == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<Task>?,
  ));
}


}


/// @nodoc
mixin _$Task {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'phase_id') String get phaseId;@JsonKey(name: 'plan_id') String get planId; String get name; String? get description; TaskStatus get status;@JsonKey(name: 'assigned_agent') String? get assignedAgent; String? get skill;@JsonKey(name: 'execution_group') int? get executionGroup;@JsonKey(name: 'order_index') int get orderIndex;@JsonKey(name: 'completion_summary') Map<String, dynamic>? get completionSummary;@JsonKey(name: 'blocker_reason') String? get blockerReason; Map<String, dynamic>? get metadata;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;/// Nested subtasks, populated by API responses that include relations.
 List<Subtask>? get subtasks;/// Nested acceptance criteria, populated by API responses.
@JsonKey(name: 'acceptance_criteria') List<AcceptanceCriteria>? get acceptanceCriteria;/// Nested file scopes, populated by API responses.
@JsonKey(name: 'file_scopes') List<FileScope>? get fileScopes;/// IDs of tasks this task depends on.
@JsonKey(name: 'depends_on') List<String>? get dependsOn;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.phaseId, phaseId) || other.phaseId == phaseId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedAgent, assignedAgent) || other.assignedAgent == assignedAgent)&&(identical(other.skill, skill) || other.skill == skill)&&(identical(other.executionGroup, executionGroup) || other.executionGroup == executionGroup)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&const DeepCollectionEquality().equals(other.completionSummary, completionSummary)&&(identical(other.blockerReason, blockerReason) || other.blockerReason == blockerReason)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.subtasks, subtasks)&&const DeepCollectionEquality().equals(other.acceptanceCriteria, acceptanceCriteria)&&const DeepCollectionEquality().equals(other.fileScopes, fileScopes)&&const DeepCollectionEquality().equals(other.dependsOn, dependsOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,organizationId,phaseId,planId,name,description,status,assignedAgent,skill,executionGroup,orderIndex,const DeepCollectionEquality().hash(completionSummary),blockerReason,const DeepCollectionEquality().hash(metadata),createdAt,updatedAt,const DeepCollectionEquality().hash(subtasks),const DeepCollectionEquality().hash(acceptanceCriteria),const DeepCollectionEquality().hash(fileScopes),const DeepCollectionEquality().hash(dependsOn)]);

@override
String toString() {
  return 'Task(id: $id, organizationId: $organizationId, phaseId: $phaseId, planId: $planId, name: $name, description: $description, status: $status, assignedAgent: $assignedAgent, skill: $skill, executionGroup: $executionGroup, orderIndex: $orderIndex, completionSummary: $completionSummary, blockerReason: $blockerReason, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, subtasks: $subtasks, acceptanceCriteria: $acceptanceCriteria, fileScopes: $fileScopes, dependsOn: $dependsOn)';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'phase_id') String phaseId,@JsonKey(name: 'plan_id') String planId, String name, String? description, TaskStatus status,@JsonKey(name: 'assigned_agent') String? assignedAgent, String? skill,@JsonKey(name: 'execution_group') int? executionGroup,@JsonKey(name: 'order_index') int orderIndex,@JsonKey(name: 'completion_summary') Map<String, dynamic>? completionSummary,@JsonKey(name: 'blocker_reason') String? blockerReason, Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, List<Subtask>? subtasks,@JsonKey(name: 'acceptance_criteria') List<AcceptanceCriteria>? acceptanceCriteria,@JsonKey(name: 'file_scopes') List<FileScope>? fileScopes,@JsonKey(name: 'depends_on') List<String>? dependsOn
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? phaseId = null,Object? planId = null,Object? name = null,Object? description = freezed,Object? status = null,Object? assignedAgent = freezed,Object? skill = freezed,Object? executionGroup = freezed,Object? orderIndex = null,Object? completionSummary = freezed,Object? blockerReason = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,Object? subtasks = freezed,Object? acceptanceCriteria = freezed,Object? fileScopes = freezed,Object? dependsOn = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,phaseId: null == phaseId ? _self.phaseId : phaseId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,assignedAgent: freezed == assignedAgent ? _self.assignedAgent : assignedAgent // ignore: cast_nullable_to_non_nullable
as String?,skill: freezed == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as String?,executionGroup: freezed == executionGroup ? _self.executionGroup : executionGroup // ignore: cast_nullable_to_non_nullable
as int?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,completionSummary: freezed == completionSummary ? _self.completionSummary : completionSummary // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,blockerReason: freezed == blockerReason ? _self.blockerReason : blockerReason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,subtasks: freezed == subtasks ? _self.subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<Subtask>?,acceptanceCriteria: freezed == acceptanceCriteria ? _self.acceptanceCriteria : acceptanceCriteria // ignore: cast_nullable_to_non_nullable
as List<AcceptanceCriteria>?,fileScopes: freezed == fileScopes ? _self.fileScopes : fileScopes // ignore: cast_nullable_to_non_nullable
as List<FileScope>?,dependsOn: freezed == dependsOn ? _self.dependsOn : dependsOn // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'phase_id')  String phaseId, @JsonKey(name: 'plan_id')  String planId,  String name,  String? description,  TaskStatus status, @JsonKey(name: 'assigned_agent')  String? assignedAgent,  String? skill, @JsonKey(name: 'execution_group')  int? executionGroup, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'completion_summary')  Map<String, dynamic>? completionSummary, @JsonKey(name: 'blocker_reason')  String? blockerReason,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<Subtask>? subtasks, @JsonKey(name: 'acceptance_criteria')  List<AcceptanceCriteria>? acceptanceCriteria, @JsonKey(name: 'file_scopes')  List<FileScope>? fileScopes, @JsonKey(name: 'depends_on')  List<String>? dependsOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.organizationId,_that.phaseId,_that.planId,_that.name,_that.description,_that.status,_that.assignedAgent,_that.skill,_that.executionGroup,_that.orderIndex,_that.completionSummary,_that.blockerReason,_that.metadata,_that.createdAt,_that.updatedAt,_that.subtasks,_that.acceptanceCriteria,_that.fileScopes,_that.dependsOn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'phase_id')  String phaseId, @JsonKey(name: 'plan_id')  String planId,  String name,  String? description,  TaskStatus status, @JsonKey(name: 'assigned_agent')  String? assignedAgent,  String? skill, @JsonKey(name: 'execution_group')  int? executionGroup, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'completion_summary')  Map<String, dynamic>? completionSummary, @JsonKey(name: 'blocker_reason')  String? blockerReason,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<Subtask>? subtasks, @JsonKey(name: 'acceptance_criteria')  List<AcceptanceCriteria>? acceptanceCriteria, @JsonKey(name: 'file_scopes')  List<FileScope>? fileScopes, @JsonKey(name: 'depends_on')  List<String>? dependsOn)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.organizationId,_that.phaseId,_that.planId,_that.name,_that.description,_that.status,_that.assignedAgent,_that.skill,_that.executionGroup,_that.orderIndex,_that.completionSummary,_that.blockerReason,_that.metadata,_that.createdAt,_that.updatedAt,_that.subtasks,_that.acceptanceCriteria,_that.fileScopes,_that.dependsOn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'phase_id')  String phaseId, @JsonKey(name: 'plan_id')  String planId,  String name,  String? description,  TaskStatus status, @JsonKey(name: 'assigned_agent')  String? assignedAgent,  String? skill, @JsonKey(name: 'execution_group')  int? executionGroup, @JsonKey(name: 'order_index')  int orderIndex, @JsonKey(name: 'completion_summary')  Map<String, dynamic>? completionSummary, @JsonKey(name: 'blocker_reason')  String? blockerReason,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<Subtask>? subtasks, @JsonKey(name: 'acceptance_criteria')  List<AcceptanceCriteria>? acceptanceCriteria, @JsonKey(name: 'file_scopes')  List<FileScope>? fileScopes, @JsonKey(name: 'depends_on')  List<String>? dependsOn)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.organizationId,_that.phaseId,_that.planId,_that.name,_that.description,_that.status,_that.assignedAgent,_that.skill,_that.executionGroup,_that.orderIndex,_that.completionSummary,_that.blockerReason,_that.metadata,_that.createdAt,_that.updatedAt,_that.subtasks,_that.acceptanceCriteria,_that.fileScopes,_that.dependsOn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task implements Task {
  const _Task({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'phase_id') required this.phaseId, @JsonKey(name: 'plan_id') required this.planId, required this.name, this.description, this.status = TaskStatus.pending, @JsonKey(name: 'assigned_agent') this.assignedAgent, this.skill, @JsonKey(name: 'execution_group') this.executionGroup, @JsonKey(name: 'order_index') this.orderIndex = 0, @JsonKey(name: 'completion_summary') final  Map<String, dynamic>? completionSummary, @JsonKey(name: 'blocker_reason') this.blockerReason, final  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, final  List<Subtask>? subtasks, @JsonKey(name: 'acceptance_criteria') final  List<AcceptanceCriteria>? acceptanceCriteria, @JsonKey(name: 'file_scopes') final  List<FileScope>? fileScopes, @JsonKey(name: 'depends_on') final  List<String>? dependsOn}): _completionSummary = completionSummary,_metadata = metadata,_subtasks = subtasks,_acceptanceCriteria = acceptanceCriteria,_fileScopes = fileScopes,_dependsOn = dependsOn;
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'phase_id') final  String phaseId;
@override@JsonKey(name: 'plan_id') final  String planId;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  TaskStatus status;
@override@JsonKey(name: 'assigned_agent') final  String? assignedAgent;
@override final  String? skill;
@override@JsonKey(name: 'execution_group') final  int? executionGroup;
@override@JsonKey(name: 'order_index') final  int orderIndex;
 final  Map<String, dynamic>? _completionSummary;
@override@JsonKey(name: 'completion_summary') Map<String, dynamic>? get completionSummary {
  final value = _completionSummary;
  if (value == null) return null;
  if (_completionSummary is EqualUnmodifiableMapView) return _completionSummary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'blocker_reason') final  String? blockerReason;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
/// Nested subtasks, populated by API responses that include relations.
 final  List<Subtask>? _subtasks;
/// Nested subtasks, populated by API responses that include relations.
@override List<Subtask>? get subtasks {
  final value = _subtasks;
  if (value == null) return null;
  if (_subtasks is EqualUnmodifiableListView) return _subtasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Nested acceptance criteria, populated by API responses.
 final  List<AcceptanceCriteria>? _acceptanceCriteria;
/// Nested acceptance criteria, populated by API responses.
@override@JsonKey(name: 'acceptance_criteria') List<AcceptanceCriteria>? get acceptanceCriteria {
  final value = _acceptanceCriteria;
  if (value == null) return null;
  if (_acceptanceCriteria is EqualUnmodifiableListView) return _acceptanceCriteria;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Nested file scopes, populated by API responses.
 final  List<FileScope>? _fileScopes;
/// Nested file scopes, populated by API responses.
@override@JsonKey(name: 'file_scopes') List<FileScope>? get fileScopes {
  final value = _fileScopes;
  if (value == null) return null;
  if (_fileScopes is EqualUnmodifiableListView) return _fileScopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// IDs of tasks this task depends on.
 final  List<String>? _dependsOn;
/// IDs of tasks this task depends on.
@override@JsonKey(name: 'depends_on') List<String>? get dependsOn {
  final value = _dependsOn;
  if (value == null) return null;
  if (_dependsOn is EqualUnmodifiableListView) return _dependsOn;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.phaseId, phaseId) || other.phaseId == phaseId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedAgent, assignedAgent) || other.assignedAgent == assignedAgent)&&(identical(other.skill, skill) || other.skill == skill)&&(identical(other.executionGroup, executionGroup) || other.executionGroup == executionGroup)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&const DeepCollectionEquality().equals(other._completionSummary, _completionSummary)&&(identical(other.blockerReason, blockerReason) || other.blockerReason == blockerReason)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._subtasks, _subtasks)&&const DeepCollectionEquality().equals(other._acceptanceCriteria, _acceptanceCriteria)&&const DeepCollectionEquality().equals(other._fileScopes, _fileScopes)&&const DeepCollectionEquality().equals(other._dependsOn, _dependsOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,organizationId,phaseId,planId,name,description,status,assignedAgent,skill,executionGroup,orderIndex,const DeepCollectionEquality().hash(_completionSummary),blockerReason,const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt,const DeepCollectionEquality().hash(_subtasks),const DeepCollectionEquality().hash(_acceptanceCriteria),const DeepCollectionEquality().hash(_fileScopes),const DeepCollectionEquality().hash(_dependsOn)]);

@override
String toString() {
  return 'Task(id: $id, organizationId: $organizationId, phaseId: $phaseId, planId: $planId, name: $name, description: $description, status: $status, assignedAgent: $assignedAgent, skill: $skill, executionGroup: $executionGroup, orderIndex: $orderIndex, completionSummary: $completionSummary, blockerReason: $blockerReason, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, subtasks: $subtasks, acceptanceCriteria: $acceptanceCriteria, fileScopes: $fileScopes, dependsOn: $dependsOn)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'phase_id') String phaseId,@JsonKey(name: 'plan_id') String planId, String name, String? description, TaskStatus status,@JsonKey(name: 'assigned_agent') String? assignedAgent, String? skill,@JsonKey(name: 'execution_group') int? executionGroup,@JsonKey(name: 'order_index') int orderIndex,@JsonKey(name: 'completion_summary') Map<String, dynamic>? completionSummary,@JsonKey(name: 'blocker_reason') String? blockerReason, Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, List<Subtask>? subtasks,@JsonKey(name: 'acceptance_criteria') List<AcceptanceCriteria>? acceptanceCriteria,@JsonKey(name: 'file_scopes') List<FileScope>? fileScopes,@JsonKey(name: 'depends_on') List<String>? dependsOn
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? phaseId = null,Object? planId = null,Object? name = null,Object? description = freezed,Object? status = null,Object? assignedAgent = freezed,Object? skill = freezed,Object? executionGroup = freezed,Object? orderIndex = null,Object? completionSummary = freezed,Object? blockerReason = freezed,Object? metadata = freezed,Object? createdAt = null,Object? updatedAt = null,Object? subtasks = freezed,Object? acceptanceCriteria = freezed,Object? fileScopes = freezed,Object? dependsOn = freezed,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,phaseId: null == phaseId ? _self.phaseId : phaseId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,assignedAgent: freezed == assignedAgent ? _self.assignedAgent : assignedAgent // ignore: cast_nullable_to_non_nullable
as String?,skill: freezed == skill ? _self.skill : skill // ignore: cast_nullable_to_non_nullable
as String?,executionGroup: freezed == executionGroup ? _self.executionGroup : executionGroup // ignore: cast_nullable_to_non_nullable
as int?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,completionSummary: freezed == completionSummary ? _self._completionSummary : completionSummary // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,blockerReason: freezed == blockerReason ? _self.blockerReason : blockerReason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,subtasks: freezed == subtasks ? _self._subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<Subtask>?,acceptanceCriteria: freezed == acceptanceCriteria ? _self._acceptanceCriteria : acceptanceCriteria // ignore: cast_nullable_to_non_nullable
as List<AcceptanceCriteria>?,fileScopes: freezed == fileScopes ? _self._fileScopes : fileScopes // ignore: cast_nullable_to_non_nullable
as List<FileScope>?,dependsOn: freezed == dependsOn ? _self._dependsOn : dependsOn // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$Subtask {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'task_id') String get taskId; String get details; SubtaskStatus get status;@JsonKey(name: 'order_number') int get orderNumber;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Subtask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubtaskCopyWith<Subtask> get copyWith => _$SubtaskCopyWithImpl<Subtask>(this as Subtask, _$identity);

  /// Serializes this Subtask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Subtask&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.details, details) || other.details == details)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,taskId,details,status,orderNumber,createdAt);

@override
String toString() {
  return 'Subtask(id: $id, organizationId: $organizationId, taskId: $taskId, details: $details, status: $status, orderNumber: $orderNumber, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SubtaskCopyWith<$Res>  {
  factory $SubtaskCopyWith(Subtask value, $Res Function(Subtask) _then) = _$SubtaskCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'task_id') String taskId, String details, SubtaskStatus status,@JsonKey(name: 'order_number') int orderNumber,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$SubtaskCopyWithImpl<$Res>
    implements $SubtaskCopyWith<$Res> {
  _$SubtaskCopyWithImpl(this._self, this._then);

  final Subtask _self;
  final $Res Function(Subtask) _then;

/// Create a copy of Subtask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? taskId = null,Object? details = null,Object? status = null,Object? orderNumber = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubtaskStatus,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Subtask].
extension SubtaskPatterns on Subtask {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Subtask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Subtask() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Subtask value)  $default,){
final _that = this;
switch (_that) {
case _Subtask():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Subtask value)?  $default,){
final _that = this;
switch (_that) {
case _Subtask() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'task_id')  String taskId,  String details,  SubtaskStatus status, @JsonKey(name: 'order_number')  int orderNumber, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Subtask() when $default != null:
return $default(_that.id,_that.organizationId,_that.taskId,_that.details,_that.status,_that.orderNumber,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'task_id')  String taskId,  String details,  SubtaskStatus status, @JsonKey(name: 'order_number')  int orderNumber, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Subtask():
return $default(_that.id,_that.organizationId,_that.taskId,_that.details,_that.status,_that.orderNumber,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'task_id')  String taskId,  String details,  SubtaskStatus status, @JsonKey(name: 'order_number')  int orderNumber, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Subtask() when $default != null:
return $default(_that.id,_that.organizationId,_that.taskId,_that.details,_that.status,_that.orderNumber,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Subtask implements Subtask {
  const _Subtask({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'task_id') required this.taskId, required this.details, this.status = SubtaskStatus.notStarted, @JsonKey(name: 'order_number') this.orderNumber = 0, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Subtask.fromJson(Map<String, dynamic> json) => _$SubtaskFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'task_id') final  String taskId;
@override final  String details;
@override@JsonKey() final  SubtaskStatus status;
@override@JsonKey(name: 'order_number') final  int orderNumber;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Subtask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubtaskCopyWith<_Subtask> get copyWith => __$SubtaskCopyWithImpl<_Subtask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubtaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Subtask&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.details, details) || other.details == details)&&(identical(other.status, status) || other.status == status)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,taskId,details,status,orderNumber,createdAt);

@override
String toString() {
  return 'Subtask(id: $id, organizationId: $organizationId, taskId: $taskId, details: $details, status: $status, orderNumber: $orderNumber, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SubtaskCopyWith<$Res> implements $SubtaskCopyWith<$Res> {
  factory _$SubtaskCopyWith(_Subtask value, $Res Function(_Subtask) _then) = __$SubtaskCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'task_id') String taskId, String details, SubtaskStatus status,@JsonKey(name: 'order_number') int orderNumber,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$SubtaskCopyWithImpl<$Res>
    implements _$SubtaskCopyWith<$Res> {
  __$SubtaskCopyWithImpl(this._self, this._then);

  final _Subtask _self;
  final $Res Function(_Subtask) _then;

/// Create a copy of Subtask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? taskId = null,Object? details = null,Object? status = null,Object? orderNumber = null,Object? createdAt = null,}) {
  return _then(_Subtask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubtaskStatus,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AcceptanceCriteria {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'task_id') String get taskId; String get description;@JsonKey(name: 'criteria_type') CriteriaType get criteriaType; String? get command;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of AcceptanceCriteria
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcceptanceCriteriaCopyWith<AcceptanceCriteria> get copyWith => _$AcceptanceCriteriaCopyWithImpl<AcceptanceCriteria>(this as AcceptanceCriteria, _$identity);

  /// Serializes this AcceptanceCriteria to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptanceCriteria&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.description, description) || other.description == description)&&(identical(other.criteriaType, criteriaType) || other.criteriaType == criteriaType)&&(identical(other.command, command) || other.command == command)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,taskId,description,criteriaType,command,createdAt);

@override
String toString() {
  return 'AcceptanceCriteria(id: $id, organizationId: $organizationId, taskId: $taskId, description: $description, criteriaType: $criteriaType, command: $command, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AcceptanceCriteriaCopyWith<$Res>  {
  factory $AcceptanceCriteriaCopyWith(AcceptanceCriteria value, $Res Function(AcceptanceCriteria) _then) = _$AcceptanceCriteriaCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'task_id') String taskId, String description,@JsonKey(name: 'criteria_type') CriteriaType criteriaType, String? command,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$AcceptanceCriteriaCopyWithImpl<$Res>
    implements $AcceptanceCriteriaCopyWith<$Res> {
  _$AcceptanceCriteriaCopyWithImpl(this._self, this._then);

  final AcceptanceCriteria _self;
  final $Res Function(AcceptanceCriteria) _then;

/// Create a copy of AcceptanceCriteria
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? taskId = null,Object? description = null,Object? criteriaType = null,Object? command = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,criteriaType: null == criteriaType ? _self.criteriaType : criteriaType // ignore: cast_nullable_to_non_nullable
as CriteriaType,command: freezed == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AcceptanceCriteria].
extension AcceptanceCriteriaPatterns on AcceptanceCriteria {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcceptanceCriteria value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcceptanceCriteria() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcceptanceCriteria value)  $default,){
final _that = this;
switch (_that) {
case _AcceptanceCriteria():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcceptanceCriteria value)?  $default,){
final _that = this;
switch (_that) {
case _AcceptanceCriteria() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'task_id')  String taskId,  String description, @JsonKey(name: 'criteria_type')  CriteriaType criteriaType,  String? command, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcceptanceCriteria() when $default != null:
return $default(_that.id,_that.organizationId,_that.taskId,_that.description,_that.criteriaType,_that.command,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'task_id')  String taskId,  String description, @JsonKey(name: 'criteria_type')  CriteriaType criteriaType,  String? command, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AcceptanceCriteria():
return $default(_that.id,_that.organizationId,_that.taskId,_that.description,_that.criteriaType,_that.command,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'task_id')  String taskId,  String description, @JsonKey(name: 'criteria_type')  CriteriaType criteriaType,  String? command, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AcceptanceCriteria() when $default != null:
return $default(_that.id,_that.organizationId,_that.taskId,_that.description,_that.criteriaType,_that.command,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AcceptanceCriteria implements AcceptanceCriteria {
  const _AcceptanceCriteria({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'task_id') required this.taskId, required this.description, @JsonKey(name: 'criteria_type') this.criteriaType = CriteriaType.manual, this.command, @JsonKey(name: 'created_at') required this.createdAt});
  factory _AcceptanceCriteria.fromJson(Map<String, dynamic> json) => _$AcceptanceCriteriaFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'task_id') final  String taskId;
@override final  String description;
@override@JsonKey(name: 'criteria_type') final  CriteriaType criteriaType;
@override final  String? command;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of AcceptanceCriteria
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptanceCriteriaCopyWith<_AcceptanceCriteria> get copyWith => __$AcceptanceCriteriaCopyWithImpl<_AcceptanceCriteria>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcceptanceCriteriaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcceptanceCriteria&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.description, description) || other.description == description)&&(identical(other.criteriaType, criteriaType) || other.criteriaType == criteriaType)&&(identical(other.command, command) || other.command == command)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,taskId,description,criteriaType,command,createdAt);

@override
String toString() {
  return 'AcceptanceCriteria(id: $id, organizationId: $organizationId, taskId: $taskId, description: $description, criteriaType: $criteriaType, command: $command, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AcceptanceCriteriaCopyWith<$Res> implements $AcceptanceCriteriaCopyWith<$Res> {
  factory _$AcceptanceCriteriaCopyWith(_AcceptanceCriteria value, $Res Function(_AcceptanceCriteria) _then) = __$AcceptanceCriteriaCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'task_id') String taskId, String description,@JsonKey(name: 'criteria_type') CriteriaType criteriaType, String? command,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$AcceptanceCriteriaCopyWithImpl<$Res>
    implements _$AcceptanceCriteriaCopyWith<$Res> {
  __$AcceptanceCriteriaCopyWithImpl(this._self, this._then);

  final _AcceptanceCriteria _self;
  final $Res Function(_AcceptanceCriteria) _then;

/// Create a copy of AcceptanceCriteria
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? taskId = null,Object? description = null,Object? criteriaType = null,Object? command = freezed,Object? createdAt = null,}) {
  return _then(_AcceptanceCriteria(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,criteriaType: null == criteriaType ? _self.criteriaType : criteriaType // ignore: cast_nullable_to_non_nullable
as CriteriaType,command: freezed == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$FileScope {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'task_id') String get taskId;@JsonKey(name: 'file_path') String get filePath;@JsonKey(name: 'scope_type') FileScopeType get scopeType;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of FileScope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileScopeCopyWith<FileScope> get copyWith => _$FileScopeCopyWithImpl<FileScope>(this as FileScope, _$identity);

  /// Serializes this FileScope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileScope&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,taskId,filePath,scopeType,createdAt);

@override
String toString() {
  return 'FileScope(id: $id, organizationId: $organizationId, taskId: $taskId, filePath: $filePath, scopeType: $scopeType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FileScopeCopyWith<$Res>  {
  factory $FileScopeCopyWith(FileScope value, $Res Function(FileScope) _then) = _$FileScopeCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'task_id') String taskId,@JsonKey(name: 'file_path') String filePath,@JsonKey(name: 'scope_type') FileScopeType scopeType,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$FileScopeCopyWithImpl<$Res>
    implements $FileScopeCopyWith<$Res> {
  _$FileScopeCopyWithImpl(this._self, this._then);

  final FileScope _self;
  final $Res Function(FileScope) _then;

/// Create a copy of FileScope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? taskId = null,Object? filePath = null,Object? scopeType = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as FileScopeType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FileScope].
extension FileScopePatterns on FileScope {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileScope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileScope() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileScope value)  $default,){
final _that = this;
switch (_that) {
case _FileScope():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileScope value)?  $default,){
final _that = this;
switch (_that) {
case _FileScope() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'task_id')  String taskId, @JsonKey(name: 'file_path')  String filePath, @JsonKey(name: 'scope_type')  FileScopeType scopeType, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileScope() when $default != null:
return $default(_that.id,_that.organizationId,_that.taskId,_that.filePath,_that.scopeType,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'task_id')  String taskId, @JsonKey(name: 'file_path')  String filePath, @JsonKey(name: 'scope_type')  FileScopeType scopeType, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _FileScope():
return $default(_that.id,_that.organizationId,_that.taskId,_that.filePath,_that.scopeType,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'task_id')  String taskId, @JsonKey(name: 'file_path')  String filePath, @JsonKey(name: 'scope_type')  FileScopeType scopeType, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FileScope() when $default != null:
return $default(_that.id,_that.organizationId,_that.taskId,_that.filePath,_that.scopeType,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FileScope implements FileScope {
  const _FileScope({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'task_id') required this.taskId, @JsonKey(name: 'file_path') required this.filePath, @JsonKey(name: 'scope_type') required this.scopeType, @JsonKey(name: 'created_at') required this.createdAt});
  factory _FileScope.fromJson(Map<String, dynamic> json) => _$FileScopeFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'task_id') final  String taskId;
@override@JsonKey(name: 'file_path') final  String filePath;
@override@JsonKey(name: 'scope_type') final  FileScopeType scopeType;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of FileScope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileScopeCopyWith<_FileScope> get copyWith => __$FileScopeCopyWithImpl<_FileScope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FileScopeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileScope&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,taskId,filePath,scopeType,createdAt);

@override
String toString() {
  return 'FileScope(id: $id, organizationId: $organizationId, taskId: $taskId, filePath: $filePath, scopeType: $scopeType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FileScopeCopyWith<$Res> implements $FileScopeCopyWith<$Res> {
  factory _$FileScopeCopyWith(_FileScope value, $Res Function(_FileScope) _then) = __$FileScopeCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'task_id') String taskId,@JsonKey(name: 'file_path') String filePath,@JsonKey(name: 'scope_type') FileScopeType scopeType,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$FileScopeCopyWithImpl<$Res>
    implements _$FileScopeCopyWith<$Res> {
  __$FileScopeCopyWithImpl(this._self, this._then);

  final _FileScope _self;
  final $Res Function(_FileScope) _then;

/// Create a copy of FileScope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? taskId = null,Object? filePath = null,Object? scopeType = null,Object? createdAt = null,}) {
  return _then(_FileScope(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as FileScopeType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
