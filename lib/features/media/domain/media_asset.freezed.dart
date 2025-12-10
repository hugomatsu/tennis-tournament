// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaAsset {

 String get id; String get url; String get path; int get size; DateTime get uploadedAt; String get userId; String? get fileName; String? get contentType;
/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaAssetCopyWith<MediaAsset> get copyWith => _$MediaAssetCopyWithImpl<MediaAsset>(this as MediaAsset, _$identity);

  /// Serializes this MediaAsset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.path, path) || other.path == path)&&(identical(other.size, size) || other.size == size)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,path,size,uploadedAt,userId,fileName,contentType);

@override
String toString() {
  return 'MediaAsset(id: $id, url: $url, path: $path, size: $size, uploadedAt: $uploadedAt, userId: $userId, fileName: $fileName, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $MediaAssetCopyWith<$Res>  {
  factory $MediaAssetCopyWith(MediaAsset value, $Res Function(MediaAsset) _then) = _$MediaAssetCopyWithImpl;
@useResult
$Res call({
 String id, String url, String path, int size, DateTime uploadedAt, String userId, String? fileName, String? contentType
});




}
/// @nodoc
class _$MediaAssetCopyWithImpl<$Res>
    implements $MediaAssetCopyWith<$Res> {
  _$MediaAssetCopyWithImpl(this._self, this._then);

  final MediaAsset _self;
  final $Res Function(MediaAsset) _then;

/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? path = null,Object? size = null,Object? uploadedAt = null,Object? userId = null,Object? fileName = freezed,Object? contentType = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaAsset].
extension MediaAssetPatterns on MediaAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaAsset value)  $default,){
final _that = this;
switch (_that) {
case _MediaAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaAsset value)?  $default,){
final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String path,  int size,  DateTime uploadedAt,  String userId,  String? fileName,  String? contentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
return $default(_that.id,_that.url,_that.path,_that.size,_that.uploadedAt,_that.userId,_that.fileName,_that.contentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String path,  int size,  DateTime uploadedAt,  String userId,  String? fileName,  String? contentType)  $default,) {final _that = this;
switch (_that) {
case _MediaAsset():
return $default(_that.id,_that.url,_that.path,_that.size,_that.uploadedAt,_that.userId,_that.fileName,_that.contentType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String path,  int size,  DateTime uploadedAt,  String userId,  String? fileName,  String? contentType)?  $default,) {final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
return $default(_that.id,_that.url,_that.path,_that.size,_that.uploadedAt,_that.userId,_that.fileName,_that.contentType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaAsset implements MediaAsset {
  const _MediaAsset({required this.id, required this.url, required this.path, required this.size, required this.uploadedAt, required this.userId, this.fileName, this.contentType});
  factory _MediaAsset.fromJson(Map<String, dynamic> json) => _$MediaAssetFromJson(json);

@override final  String id;
@override final  String url;
@override final  String path;
@override final  int size;
@override final  DateTime uploadedAt;
@override final  String userId;
@override final  String? fileName;
@override final  String? contentType;

/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaAssetCopyWith<_MediaAsset> get copyWith => __$MediaAssetCopyWithImpl<_MediaAsset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaAssetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.path, path) || other.path == path)&&(identical(other.size, size) || other.size == size)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,path,size,uploadedAt,userId,fileName,contentType);

@override
String toString() {
  return 'MediaAsset(id: $id, url: $url, path: $path, size: $size, uploadedAt: $uploadedAt, userId: $userId, fileName: $fileName, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$MediaAssetCopyWith<$Res> implements $MediaAssetCopyWith<$Res> {
  factory _$MediaAssetCopyWith(_MediaAsset value, $Res Function(_MediaAsset) _then) = __$MediaAssetCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String path, int size, DateTime uploadedAt, String userId, String? fileName, String? contentType
});




}
/// @nodoc
class __$MediaAssetCopyWithImpl<$Res>
    implements _$MediaAssetCopyWith<$Res> {
  __$MediaAssetCopyWithImpl(this._self, this._then);

  final _MediaAsset _self;
  final $Res Function(_MediaAsset) _then;

/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? path = null,Object? size = null,Object? uploadedAt = null,Object? userId = null,Object? fileName = freezed,Object? contentType = freezed,}) {
  return _then(_MediaAsset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
