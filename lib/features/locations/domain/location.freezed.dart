// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TournamentLocation {

 String get id; String get name; String get googleMapsUrl; String get description; int get numberOfCourts; String? get imageUrl;
/// Create a copy of TournamentLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentLocationCopyWith<TournamentLocation> get copyWith => _$TournamentLocationCopyWithImpl<TournamentLocation>(this as TournamentLocation, _$identity);

  /// Serializes this TournamentLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.googleMapsUrl, googleMapsUrl) || other.googleMapsUrl == googleMapsUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.numberOfCourts, numberOfCourts) || other.numberOfCourts == numberOfCourts)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,googleMapsUrl,description,numberOfCourts,imageUrl);

@override
String toString() {
  return 'TournamentLocation(id: $id, name: $name, googleMapsUrl: $googleMapsUrl, description: $description, numberOfCourts: $numberOfCourts, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $TournamentLocationCopyWith<$Res>  {
  factory $TournamentLocationCopyWith(TournamentLocation value, $Res Function(TournamentLocation) _then) = _$TournamentLocationCopyWithImpl;
@useResult
$Res call({
 String id, String name, String googleMapsUrl, String description, int numberOfCourts, String? imageUrl
});




}
/// @nodoc
class _$TournamentLocationCopyWithImpl<$Res>
    implements $TournamentLocationCopyWith<$Res> {
  _$TournamentLocationCopyWithImpl(this._self, this._then);

  final TournamentLocation _self;
  final $Res Function(TournamentLocation) _then;

/// Create a copy of TournamentLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? googleMapsUrl = null,Object? description = null,Object? numberOfCourts = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,googleMapsUrl: null == googleMapsUrl ? _self.googleMapsUrl : googleMapsUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,numberOfCourts: null == numberOfCourts ? _self.numberOfCourts : numberOfCourts // ignore: cast_nullable_to_non_nullable
as int,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentLocation].
extension TournamentLocationPatterns on TournamentLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentLocation value)  $default,){
final _that = this;
switch (_that) {
case _TournamentLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentLocation value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String googleMapsUrl,  String description,  int numberOfCourts,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentLocation() when $default != null:
return $default(_that.id,_that.name,_that.googleMapsUrl,_that.description,_that.numberOfCourts,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String googleMapsUrl,  String description,  int numberOfCourts,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _TournamentLocation():
return $default(_that.id,_that.name,_that.googleMapsUrl,_that.description,_that.numberOfCourts,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String googleMapsUrl,  String description,  int numberOfCourts,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _TournamentLocation() when $default != null:
return $default(_that.id,_that.name,_that.googleMapsUrl,_that.description,_that.numberOfCourts,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentLocation implements TournamentLocation {
  const _TournamentLocation({required this.id, required this.name, required this.googleMapsUrl, required this.description, required this.numberOfCourts, this.imageUrl});
  factory _TournamentLocation.fromJson(Map<String, dynamic> json) => _$TournamentLocationFromJson(json);

@override final  String id;
@override final  String name;
@override final  String googleMapsUrl;
@override final  String description;
@override final  int numberOfCourts;
@override final  String? imageUrl;

/// Create a copy of TournamentLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentLocationCopyWith<_TournamentLocation> get copyWith => __$TournamentLocationCopyWithImpl<_TournamentLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.googleMapsUrl, googleMapsUrl) || other.googleMapsUrl == googleMapsUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.numberOfCourts, numberOfCourts) || other.numberOfCourts == numberOfCourts)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,googleMapsUrl,description,numberOfCourts,imageUrl);

@override
String toString() {
  return 'TournamentLocation(id: $id, name: $name, googleMapsUrl: $googleMapsUrl, description: $description, numberOfCourts: $numberOfCourts, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$TournamentLocationCopyWith<$Res> implements $TournamentLocationCopyWith<$Res> {
  factory _$TournamentLocationCopyWith(_TournamentLocation value, $Res Function(_TournamentLocation) _then) = __$TournamentLocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String googleMapsUrl, String description, int numberOfCourts, String? imageUrl
});




}
/// @nodoc
class __$TournamentLocationCopyWithImpl<$Res>
    implements _$TournamentLocationCopyWith<$Res> {
  __$TournamentLocationCopyWithImpl(this._self, this._then);

  final _TournamentLocation _self;
  final $Res Function(_TournamentLocation) _then;

/// Create a copy of TournamentLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? googleMapsUrl = null,Object? description = null,Object? numberOfCourts = null,Object? imageUrl = freezed,}) {
  return _then(_TournamentLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,googleMapsUrl: null == googleMapsUrl ? _self.googleMapsUrl : googleMapsUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,numberOfCourts: null == numberOfCourts ? _self.numberOfCourts : numberOfCourts // ignore: cast_nullable_to_non_nullable
as int,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
