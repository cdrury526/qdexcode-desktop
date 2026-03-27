// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'indexing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IndexingProgress {

@JsonKey(name: 'project_id') String get projectId;@JsonKey(name: 'current_file') String? get currentFile;@JsonKey(name: 'files_done') int get filesDone;@JsonKey(name: 'files_total') int get filesTotal; IndexingStatus get status; String? get error;/// Timestamp of this progress update.
 DateTime? get timestamp;
/// Create a copy of IndexingProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IndexingProgressCopyWith<IndexingProgress> get copyWith => _$IndexingProgressCopyWithImpl<IndexingProgress>(this as IndexingProgress, _$identity);

  /// Serializes this IndexingProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IndexingProgress&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.currentFile, currentFile) || other.currentFile == currentFile)&&(identical(other.filesDone, filesDone) || other.filesDone == filesDone)&&(identical(other.filesTotal, filesTotal) || other.filesTotal == filesTotal)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,projectId,currentFile,filesDone,filesTotal,status,error,timestamp);

@override
String toString() {
  return 'IndexingProgress(projectId: $projectId, currentFile: $currentFile, filesDone: $filesDone, filesTotal: $filesTotal, status: $status, error: $error, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $IndexingProgressCopyWith<$Res>  {
  factory $IndexingProgressCopyWith(IndexingProgress value, $Res Function(IndexingProgress) _then) = _$IndexingProgressCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'project_id') String projectId,@JsonKey(name: 'current_file') String? currentFile,@JsonKey(name: 'files_done') int filesDone,@JsonKey(name: 'files_total') int filesTotal, IndexingStatus status, String? error, DateTime? timestamp
});




}
/// @nodoc
class _$IndexingProgressCopyWithImpl<$Res>
    implements $IndexingProgressCopyWith<$Res> {
  _$IndexingProgressCopyWithImpl(this._self, this._then);

  final IndexingProgress _self;
  final $Res Function(IndexingProgress) _then;

/// Create a copy of IndexingProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? projectId = null,Object? currentFile = freezed,Object? filesDone = null,Object? filesTotal = null,Object? status = null,Object? error = freezed,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,currentFile: freezed == currentFile ? _self.currentFile : currentFile // ignore: cast_nullable_to_non_nullable
as String?,filesDone: null == filesDone ? _self.filesDone : filesDone // ignore: cast_nullable_to_non_nullable
as int,filesTotal: null == filesTotal ? _self.filesTotal : filesTotal // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IndexingStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [IndexingProgress].
extension IndexingProgressPatterns on IndexingProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IndexingProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IndexingProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IndexingProgress value)  $default,){
final _that = this;
switch (_that) {
case _IndexingProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IndexingProgress value)?  $default,){
final _that = this;
switch (_that) {
case _IndexingProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'project_id')  String projectId, @JsonKey(name: 'current_file')  String? currentFile, @JsonKey(name: 'files_done')  int filesDone, @JsonKey(name: 'files_total')  int filesTotal,  IndexingStatus status,  String? error,  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IndexingProgress() when $default != null:
return $default(_that.projectId,_that.currentFile,_that.filesDone,_that.filesTotal,_that.status,_that.error,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'project_id')  String projectId, @JsonKey(name: 'current_file')  String? currentFile, @JsonKey(name: 'files_done')  int filesDone, @JsonKey(name: 'files_total')  int filesTotal,  IndexingStatus status,  String? error,  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _IndexingProgress():
return $default(_that.projectId,_that.currentFile,_that.filesDone,_that.filesTotal,_that.status,_that.error,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'project_id')  String projectId, @JsonKey(name: 'current_file')  String? currentFile, @JsonKey(name: 'files_done')  int filesDone, @JsonKey(name: 'files_total')  int filesTotal,  IndexingStatus status,  String? error,  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _IndexingProgress() when $default != null:
return $default(_that.projectId,_that.currentFile,_that.filesDone,_that.filesTotal,_that.status,_that.error,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IndexingProgress implements IndexingProgress {
  const _IndexingProgress({@JsonKey(name: 'project_id') required this.projectId, @JsonKey(name: 'current_file') this.currentFile, @JsonKey(name: 'files_done') this.filesDone = 0, @JsonKey(name: 'files_total') this.filesTotal = 0, this.status = IndexingStatus.idle, this.error, this.timestamp});
  factory _IndexingProgress.fromJson(Map<String, dynamic> json) => _$IndexingProgressFromJson(json);

@override@JsonKey(name: 'project_id') final  String projectId;
@override@JsonKey(name: 'current_file') final  String? currentFile;
@override@JsonKey(name: 'files_done') final  int filesDone;
@override@JsonKey(name: 'files_total') final  int filesTotal;
@override@JsonKey() final  IndexingStatus status;
@override final  String? error;
/// Timestamp of this progress update.
@override final  DateTime? timestamp;

/// Create a copy of IndexingProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IndexingProgressCopyWith<_IndexingProgress> get copyWith => __$IndexingProgressCopyWithImpl<_IndexingProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IndexingProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IndexingProgress&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.currentFile, currentFile) || other.currentFile == currentFile)&&(identical(other.filesDone, filesDone) || other.filesDone == filesDone)&&(identical(other.filesTotal, filesTotal) || other.filesTotal == filesTotal)&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,projectId,currentFile,filesDone,filesTotal,status,error,timestamp);

@override
String toString() {
  return 'IndexingProgress(projectId: $projectId, currentFile: $currentFile, filesDone: $filesDone, filesTotal: $filesTotal, status: $status, error: $error, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$IndexingProgressCopyWith<$Res> implements $IndexingProgressCopyWith<$Res> {
  factory _$IndexingProgressCopyWith(_IndexingProgress value, $Res Function(_IndexingProgress) _then) = __$IndexingProgressCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'project_id') String projectId,@JsonKey(name: 'current_file') String? currentFile,@JsonKey(name: 'files_done') int filesDone,@JsonKey(name: 'files_total') int filesTotal, IndexingStatus status, String? error, DateTime? timestamp
});




}
/// @nodoc
class __$IndexingProgressCopyWithImpl<$Res>
    implements _$IndexingProgressCopyWith<$Res> {
  __$IndexingProgressCopyWithImpl(this._self, this._then);

  final _IndexingProgress _self;
  final $Res Function(_IndexingProgress) _then;

/// Create a copy of IndexingProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? projectId = null,Object? currentFile = freezed,Object? filesDone = null,Object? filesTotal = null,Object? status = null,Object? error = freezed,Object? timestamp = freezed,}) {
  return _then(_IndexingProgress(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,currentFile: freezed == currentFile ? _self.currentFile : currentFile // ignore: cast_nullable_to_non_nullable
as String?,filesDone: null == filesDone ? _self.filesDone : filesDone // ignore: cast_nullable_to_non_nullable
as int,filesTotal: null == filesTotal ? _self.filesTotal : filesTotal // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IndexingStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
