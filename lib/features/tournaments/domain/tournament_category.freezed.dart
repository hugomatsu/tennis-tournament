// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TournamentCategory {

 String get id; String get tournamentId; String get name;// e.g., "Men's A", "Mixed Doubles"
 String get type;// 'singles' | 'doubles'
 String get description; String get format;
/// Create a copy of TournamentCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentCategoryCopyWith<TournamentCategory> get copyWith => _$TournamentCategoryCopyWithImpl<TournamentCategory>(this as TournamentCategory, _$identity);

  /// Serializes this TournamentCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.format, format) || other.format == format));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tournamentId,name,type,description,format);

@override
String toString() {
  return 'TournamentCategory(id: $id, tournamentId: $tournamentId, name: $name, type: $type, description: $description, format: $format)';
}


}

/// @nodoc
abstract mixin class $TournamentCategoryCopyWith<$Res>  {
  factory $TournamentCategoryCopyWith(TournamentCategory value, $Res Function(TournamentCategory) _then) = _$TournamentCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String tournamentId, String name, String type, String description, String format
});




}
/// @nodoc
class _$TournamentCategoryCopyWithImpl<$Res>
    implements $TournamentCategoryCopyWith<$Res> {
  _$TournamentCategoryCopyWithImpl(this._self, this._then);

  final TournamentCategory _self;
  final $Res Function(TournamentCategory) _then;

/// Create a copy of TournamentCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tournamentId = null,Object? name = null,Object? type = null,Object? description = null,Object? format = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentCategory].
extension TournamentCategoryPatterns on TournamentCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentCategory value)  $default,){
final _that = this;
switch (_that) {
case _TournamentCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentCategory value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tournamentId,  String name,  String type,  String description,  String format)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentCategory() when $default != null:
return $default(_that.id,_that.tournamentId,_that.name,_that.type,_that.description,_that.format);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tournamentId,  String name,  String type,  String description,  String format)  $default,) {final _that = this;
switch (_that) {
case _TournamentCategory():
return $default(_that.id,_that.tournamentId,_that.name,_that.type,_that.description,_that.format);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tournamentId,  String name,  String type,  String description,  String format)?  $default,) {final _that = this;
switch (_that) {
case _TournamentCategory() when $default != null:
return $default(_that.id,_that.tournamentId,_that.name,_that.type,_that.description,_that.format);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentCategory implements TournamentCategory {
  const _TournamentCategory({required this.id, required this.tournamentId, required this.name, required this.type, this.description = '', this.format = 'round_robin'});
  factory _TournamentCategory.fromJson(Map<String, dynamic> json) => _$TournamentCategoryFromJson(json);

@override final  String id;
@override final  String tournamentId;
@override final  String name;
// e.g., "Men's A", "Mixed Doubles"
@override final  String type;
// 'singles' | 'doubles'
@override@JsonKey() final  String description;
@override@JsonKey() final  String format;

/// Create a copy of TournamentCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentCategoryCopyWith<_TournamentCategory> get copyWith => __$TournamentCategoryCopyWithImpl<_TournamentCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.format, format) || other.format == format));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tournamentId,name,type,description,format);

@override
String toString() {
  return 'TournamentCategory(id: $id, tournamentId: $tournamentId, name: $name, type: $type, description: $description, format: $format)';
}


}

/// @nodoc
abstract mixin class _$TournamentCategoryCopyWith<$Res> implements $TournamentCategoryCopyWith<$Res> {
  factory _$TournamentCategoryCopyWith(_TournamentCategory value, $Res Function(_TournamentCategory) _then) = __$TournamentCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String tournamentId, String name, String type, String description, String format
});




}
/// @nodoc
class __$TournamentCategoryCopyWithImpl<$Res>
    implements _$TournamentCategoryCopyWith<$Res> {
  __$TournamentCategoryCopyWithImpl(this._self, this._then);

  final _TournamentCategory _self;
  final $Res Function(_TournamentCategory) _then;

/// Create a copy of TournamentCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tournamentId = null,Object? name = null,Object? type = null,Object? description = null,Object? format = null,}) {
  return _then(_TournamentCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
