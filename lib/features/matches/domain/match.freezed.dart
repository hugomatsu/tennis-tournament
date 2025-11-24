// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TennisMatch {

 String get id; String get tournamentId; String get tournamentName; String get opponentName; DateTime get time; String get court; String get round; String get status;// 'Scheduled', 'Live', 'Completed', 'Pending'
 String? get score; String? get winner;
/// Create a copy of TennisMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TennisMatchCopyWith<TennisMatch> get copyWith => _$TennisMatchCopyWithImpl<TennisMatch>(this as TennisMatch, _$identity);

  /// Serializes this TennisMatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TennisMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.tournamentName, tournamentName) || other.tournamentName == tournamentName)&&(identical(other.opponentName, opponentName) || other.opponentName == opponentName)&&(identical(other.time, time) || other.time == time)&&(identical(other.court, court) || other.court == court)&&(identical(other.round, round) || other.round == round)&&(identical(other.status, status) || other.status == status)&&(identical(other.score, score) || other.score == score)&&(identical(other.winner, winner) || other.winner == winner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tournamentId,tournamentName,opponentName,time,court,round,status,score,winner);

@override
String toString() {
  return 'TennisMatch(id: $id, tournamentId: $tournamentId, tournamentName: $tournamentName, opponentName: $opponentName, time: $time, court: $court, round: $round, status: $status, score: $score, winner: $winner)';
}


}

/// @nodoc
abstract mixin class $TennisMatchCopyWith<$Res>  {
  factory $TennisMatchCopyWith(TennisMatch value, $Res Function(TennisMatch) _then) = _$TennisMatchCopyWithImpl;
@useResult
$Res call({
 String id, String tournamentId, String tournamentName, String opponentName, DateTime time, String court, String round, String status, String? score, String? winner
});




}
/// @nodoc
class _$TennisMatchCopyWithImpl<$Res>
    implements $TennisMatchCopyWith<$Res> {
  _$TennisMatchCopyWithImpl(this._self, this._then);

  final TennisMatch _self;
  final $Res Function(TennisMatch) _then;

/// Create a copy of TennisMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tournamentId = null,Object? tournamentName = null,Object? opponentName = null,Object? time = null,Object? court = null,Object? round = null,Object? status = null,Object? score = freezed,Object? winner = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,tournamentName: null == tournamentName ? _self.tournamentName : tournamentName // ignore: cast_nullable_to_non_nullable
as String,opponentName: null == opponentName ? _self.opponentName : opponentName // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,court: null == court ? _self.court : court // ignore: cast_nullable_to_non_nullable
as String,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String?,winner: freezed == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TennisMatch].
extension TennisMatchPatterns on TennisMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TennisMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TennisMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TennisMatch value)  $default,){
final _that = this;
switch (_that) {
case _TennisMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TennisMatch value)?  $default,){
final _that = this;
switch (_that) {
case _TennisMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tournamentId,  String tournamentName,  String opponentName,  DateTime time,  String court,  String round,  String status,  String? score,  String? winner)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TennisMatch() when $default != null:
return $default(_that.id,_that.tournamentId,_that.tournamentName,_that.opponentName,_that.time,_that.court,_that.round,_that.status,_that.score,_that.winner);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tournamentId,  String tournamentName,  String opponentName,  DateTime time,  String court,  String round,  String status,  String? score,  String? winner)  $default,) {final _that = this;
switch (_that) {
case _TennisMatch():
return $default(_that.id,_that.tournamentId,_that.tournamentName,_that.opponentName,_that.time,_that.court,_that.round,_that.status,_that.score,_that.winner);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tournamentId,  String tournamentName,  String opponentName,  DateTime time,  String court,  String round,  String status,  String? score,  String? winner)?  $default,) {final _that = this;
switch (_that) {
case _TennisMatch() when $default != null:
return $default(_that.id,_that.tournamentId,_that.tournamentName,_that.opponentName,_that.time,_that.court,_that.round,_that.status,_that.score,_that.winner);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TennisMatch implements TennisMatch {
  const _TennisMatch({required this.id, required this.tournamentId, required this.tournamentName, required this.opponentName, required this.time, required this.court, required this.round, required this.status, this.score, this.winner});
  factory _TennisMatch.fromJson(Map<String, dynamic> json) => _$TennisMatchFromJson(json);

@override final  String id;
@override final  String tournamentId;
@override final  String tournamentName;
@override final  String opponentName;
@override final  DateTime time;
@override final  String court;
@override final  String round;
@override final  String status;
// 'Scheduled', 'Live', 'Completed', 'Pending'
@override final  String? score;
@override final  String? winner;

/// Create a copy of TennisMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TennisMatchCopyWith<_TennisMatch> get copyWith => __$TennisMatchCopyWithImpl<_TennisMatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TennisMatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TennisMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.tournamentName, tournamentName) || other.tournamentName == tournamentName)&&(identical(other.opponentName, opponentName) || other.opponentName == opponentName)&&(identical(other.time, time) || other.time == time)&&(identical(other.court, court) || other.court == court)&&(identical(other.round, round) || other.round == round)&&(identical(other.status, status) || other.status == status)&&(identical(other.score, score) || other.score == score)&&(identical(other.winner, winner) || other.winner == winner));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tournamentId,tournamentName,opponentName,time,court,round,status,score,winner);

@override
String toString() {
  return 'TennisMatch(id: $id, tournamentId: $tournamentId, tournamentName: $tournamentName, opponentName: $opponentName, time: $time, court: $court, round: $round, status: $status, score: $score, winner: $winner)';
}


}

/// @nodoc
abstract mixin class _$TennisMatchCopyWith<$Res> implements $TennisMatchCopyWith<$Res> {
  factory _$TennisMatchCopyWith(_TennisMatch value, $Res Function(_TennisMatch) _then) = __$TennisMatchCopyWithImpl;
@override @useResult
$Res call({
 String id, String tournamentId, String tournamentName, String opponentName, DateTime time, String court, String round, String status, String? score, String? winner
});




}
/// @nodoc
class __$TennisMatchCopyWithImpl<$Res>
    implements _$TennisMatchCopyWith<$Res> {
  __$TennisMatchCopyWithImpl(this._self, this._then);

  final _TennisMatch _self;
  final $Res Function(_TennisMatch) _then;

/// Create a copy of TennisMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tournamentId = null,Object? tournamentName = null,Object? opponentName = null,Object? time = null,Object? court = null,Object? round = null,Object? status = null,Object? score = freezed,Object? winner = freezed,}) {
  return _then(_TennisMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,tournamentName: null == tournamentName ? _self.tournamentName : tournamentName // ignore: cast_nullable_to_non_nullable
as String,opponentName: null == opponentName ? _self.opponentName : opponentName // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,court: null == court ? _self.court : court // ignore: cast_nullable_to_non_nullable
as String,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String?,winner: freezed == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
