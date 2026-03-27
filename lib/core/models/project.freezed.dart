// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Project {

 String get id;@JsonKey(name: 'organization_id') String get organizationId; String get name;@JsonKey(name: 'clone_url') String get cloneUrl;@JsonKey(name: 'default_branch') String get defaultBranch;@JsonKey(name: 'last_indexed_commit_sha') String? get lastIndexedCommitSha;@JsonKey(name: 'index_status') IndexStatus get indexStatus;@JsonKey(name: 'dirty_flag') bool get dirtyFlag;@JsonKey(name: 'webhook_id') String? get webhookId;@JsonKey(name: 'webhook_secret') String? get webhookSecret;@JsonKey(name: 'webhook_status') WebhookStatus get webhookStatus;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCopyWith<Project> get copyWith => _$ProjectCopyWithImpl<Project>(this as Project, _$identity);

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Project&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.cloneUrl, cloneUrl) || other.cloneUrl == cloneUrl)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&(identical(other.lastIndexedCommitSha, lastIndexedCommitSha) || other.lastIndexedCommitSha == lastIndexedCommitSha)&&(identical(other.indexStatus, indexStatus) || other.indexStatus == indexStatus)&&(identical(other.dirtyFlag, dirtyFlag) || other.dirtyFlag == dirtyFlag)&&(identical(other.webhookId, webhookId) || other.webhookId == webhookId)&&(identical(other.webhookSecret, webhookSecret) || other.webhookSecret == webhookSecret)&&(identical(other.webhookStatus, webhookStatus) || other.webhookStatus == webhookStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,cloneUrl,defaultBranch,lastIndexedCommitSha,indexStatus,dirtyFlag,webhookId,webhookSecret,webhookStatus,createdAt,updatedAt);

@override
String toString() {
  return 'Project(id: $id, organizationId: $organizationId, name: $name, cloneUrl: $cloneUrl, defaultBranch: $defaultBranch, lastIndexedCommitSha: $lastIndexedCommitSha, indexStatus: $indexStatus, dirtyFlag: $dirtyFlag, webhookId: $webhookId, webhookSecret: $webhookSecret, webhookStatus: $webhookStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectCopyWith<$Res>  {
  factory $ProjectCopyWith(Project value, $Res Function(Project) _then) = _$ProjectCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId, String name,@JsonKey(name: 'clone_url') String cloneUrl,@JsonKey(name: 'default_branch') String defaultBranch,@JsonKey(name: 'last_indexed_commit_sha') String? lastIndexedCommitSha,@JsonKey(name: 'index_status') IndexStatus indexStatus,@JsonKey(name: 'dirty_flag') bool dirtyFlag,@JsonKey(name: 'webhook_id') String? webhookId,@JsonKey(name: 'webhook_secret') String? webhookSecret,@JsonKey(name: 'webhook_status') WebhookStatus webhookStatus,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$ProjectCopyWithImpl<$Res>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._self, this._then);

  final Project _self;
  final $Res Function(Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? cloneUrl = null,Object? defaultBranch = null,Object? lastIndexedCommitSha = freezed,Object? indexStatus = null,Object? dirtyFlag = null,Object? webhookId = freezed,Object? webhookSecret = freezed,Object? webhookStatus = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cloneUrl: null == cloneUrl ? _self.cloneUrl : cloneUrl // ignore: cast_nullable_to_non_nullable
as String,defaultBranch: null == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String,lastIndexedCommitSha: freezed == lastIndexedCommitSha ? _self.lastIndexedCommitSha : lastIndexedCommitSha // ignore: cast_nullable_to_non_nullable
as String?,indexStatus: null == indexStatus ? _self.indexStatus : indexStatus // ignore: cast_nullable_to_non_nullable
as IndexStatus,dirtyFlag: null == dirtyFlag ? _self.dirtyFlag : dirtyFlag // ignore: cast_nullable_to_non_nullable
as bool,webhookId: freezed == webhookId ? _self.webhookId : webhookId // ignore: cast_nullable_to_non_nullable
as String?,webhookSecret: freezed == webhookSecret ? _self.webhookSecret : webhookSecret // ignore: cast_nullable_to_non_nullable
as String?,webhookStatus: null == webhookStatus ? _self.webhookStatus : webhookStatus // ignore: cast_nullable_to_non_nullable
as WebhookStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Project].
extension ProjectPatterns on Project {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Project value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Project value)  $default,){
final _that = this;
switch (_that) {
case _Project():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Project value)?  $default,){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId,  String name, @JsonKey(name: 'clone_url')  String cloneUrl, @JsonKey(name: 'default_branch')  String defaultBranch, @JsonKey(name: 'last_indexed_commit_sha')  String? lastIndexedCommitSha, @JsonKey(name: 'index_status')  IndexStatus indexStatus, @JsonKey(name: 'dirty_flag')  bool dirtyFlag, @JsonKey(name: 'webhook_id')  String? webhookId, @JsonKey(name: 'webhook_secret')  String? webhookSecret, @JsonKey(name: 'webhook_status')  WebhookStatus webhookStatus, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.cloneUrl,_that.defaultBranch,_that.lastIndexedCommitSha,_that.indexStatus,_that.dirtyFlag,_that.webhookId,_that.webhookSecret,_that.webhookStatus,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId,  String name, @JsonKey(name: 'clone_url')  String cloneUrl, @JsonKey(name: 'default_branch')  String defaultBranch, @JsonKey(name: 'last_indexed_commit_sha')  String? lastIndexedCommitSha, @JsonKey(name: 'index_status')  IndexStatus indexStatus, @JsonKey(name: 'dirty_flag')  bool dirtyFlag, @JsonKey(name: 'webhook_id')  String? webhookId, @JsonKey(name: 'webhook_secret')  String? webhookSecret, @JsonKey(name: 'webhook_status')  WebhookStatus webhookStatus, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Project():
return $default(_that.id,_that.organizationId,_that.name,_that.cloneUrl,_that.defaultBranch,_that.lastIndexedCommitSha,_that.indexStatus,_that.dirtyFlag,_that.webhookId,_that.webhookSecret,_that.webhookStatus,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId,  String name, @JsonKey(name: 'clone_url')  String cloneUrl, @JsonKey(name: 'default_branch')  String defaultBranch, @JsonKey(name: 'last_indexed_commit_sha')  String? lastIndexedCommitSha, @JsonKey(name: 'index_status')  IndexStatus indexStatus, @JsonKey(name: 'dirty_flag')  bool dirtyFlag, @JsonKey(name: 'webhook_id')  String? webhookId, @JsonKey(name: 'webhook_secret')  String? webhookSecret, @JsonKey(name: 'webhook_status')  WebhookStatus webhookStatus, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.cloneUrl,_that.defaultBranch,_that.lastIndexedCommitSha,_that.indexStatus,_that.dirtyFlag,_that.webhookId,_that.webhookSecret,_that.webhookStatus,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Project implements Project {
  const _Project({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, required this.name, @JsonKey(name: 'clone_url') required this.cloneUrl, @JsonKey(name: 'default_branch') this.defaultBranch = 'main', @JsonKey(name: 'last_indexed_commit_sha') this.lastIndexedCommitSha, @JsonKey(name: 'index_status') this.indexStatus = IndexStatus.idle, @JsonKey(name: 'dirty_flag') this.dirtyFlag = false, @JsonKey(name: 'webhook_id') this.webhookId, @JsonKey(name: 'webhook_secret') this.webhookSecret, @JsonKey(name: 'webhook_status') this.webhookStatus = WebhookStatus.none, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override final  String name;
@override@JsonKey(name: 'clone_url') final  String cloneUrl;
@override@JsonKey(name: 'default_branch') final  String defaultBranch;
@override@JsonKey(name: 'last_indexed_commit_sha') final  String? lastIndexedCommitSha;
@override@JsonKey(name: 'index_status') final  IndexStatus indexStatus;
@override@JsonKey(name: 'dirty_flag') final  bool dirtyFlag;
@override@JsonKey(name: 'webhook_id') final  String? webhookId;
@override@JsonKey(name: 'webhook_secret') final  String? webhookSecret;
@override@JsonKey(name: 'webhook_status') final  WebhookStatus webhookStatus;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCopyWith<_Project> get copyWith => __$ProjectCopyWithImpl<_Project>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Project&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.cloneUrl, cloneUrl) || other.cloneUrl == cloneUrl)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&(identical(other.lastIndexedCommitSha, lastIndexedCommitSha) || other.lastIndexedCommitSha == lastIndexedCommitSha)&&(identical(other.indexStatus, indexStatus) || other.indexStatus == indexStatus)&&(identical(other.dirtyFlag, dirtyFlag) || other.dirtyFlag == dirtyFlag)&&(identical(other.webhookId, webhookId) || other.webhookId == webhookId)&&(identical(other.webhookSecret, webhookSecret) || other.webhookSecret == webhookSecret)&&(identical(other.webhookStatus, webhookStatus) || other.webhookStatus == webhookStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,cloneUrl,defaultBranch,lastIndexedCommitSha,indexStatus,dirtyFlag,webhookId,webhookSecret,webhookStatus,createdAt,updatedAt);

@override
String toString() {
  return 'Project(id: $id, organizationId: $organizationId, name: $name, cloneUrl: $cloneUrl, defaultBranch: $defaultBranch, lastIndexedCommitSha: $lastIndexedCommitSha, indexStatus: $indexStatus, dirtyFlag: $dirtyFlag, webhookId: $webhookId, webhookSecret: $webhookSecret, webhookStatus: $webhookStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$ProjectCopyWith(_Project value, $Res Function(_Project) _then) = __$ProjectCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId, String name,@JsonKey(name: 'clone_url') String cloneUrl,@JsonKey(name: 'default_branch') String defaultBranch,@JsonKey(name: 'last_indexed_commit_sha') String? lastIndexedCommitSha,@JsonKey(name: 'index_status') IndexStatus indexStatus,@JsonKey(name: 'dirty_flag') bool dirtyFlag,@JsonKey(name: 'webhook_id') String? webhookId,@JsonKey(name: 'webhook_secret') String? webhookSecret,@JsonKey(name: 'webhook_status') WebhookStatus webhookStatus,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$ProjectCopyWithImpl<$Res>
    implements _$ProjectCopyWith<$Res> {
  __$ProjectCopyWithImpl(this._self, this._then);

  final _Project _self;
  final $Res Function(_Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? cloneUrl = null,Object? defaultBranch = null,Object? lastIndexedCommitSha = freezed,Object? indexStatus = null,Object? dirtyFlag = null,Object? webhookId = freezed,Object? webhookSecret = freezed,Object? webhookStatus = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Project(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cloneUrl: null == cloneUrl ? _self.cloneUrl : cloneUrl // ignore: cast_nullable_to_non_nullable
as String,defaultBranch: null == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String,lastIndexedCommitSha: freezed == lastIndexedCommitSha ? _self.lastIndexedCommitSha : lastIndexedCommitSha // ignore: cast_nullable_to_non_nullable
as String?,indexStatus: null == indexStatus ? _self.indexStatus : indexStatus // ignore: cast_nullable_to_non_nullable
as IndexStatus,dirtyFlag: null == dirtyFlag ? _self.dirtyFlag : dirtyFlag // ignore: cast_nullable_to_non_nullable
as bool,webhookId: freezed == webhookId ? _self.webhookId : webhookId // ignore: cast_nullable_to_non_nullable
as String?,webhookSecret: freezed == webhookSecret ? _self.webhookSecret : webhookSecret // ignore: cast_nullable_to_non_nullable
as String?,webhookStatus: null == webhookStatus ? _self.webhookStatus : webhookStatus // ignore: cast_nullable_to_non_nullable
as WebhookStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
