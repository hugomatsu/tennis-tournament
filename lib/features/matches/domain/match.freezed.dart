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

 String get id; String get tournamentId; String get tournamentName; DateTime get time; String get court; String get round; String get status;// 'Scheduled', 'Live', 'Completed', 'Pending'
 String get player1Id; String get player1Name; String? get player1AvatarUrl; String? get player2Id; String? get player2Name; String? get player2AvatarUrl; String? get opponentName;// Deprecated, kept for backward compatibility if needed, or remove
 String? get score; String? get winner; String? get nextMatchId;// ID of the match where the winner goes
 int get matchIndex;
/// Create a copy of TennisMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TennisMatchCopyWith<TennisMatch> get copyWith => _$TennisMatchCopyWithImpl<TennisMatch>(this as TennisMatch, _$identity);

  /// Serializes this TennisMatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TennisMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.tournamentName, tournamentName) || other.tournamentName == tournamentName)&&(identical(other.time, time) || other.time == time)&&(identical(other.court, court) || other.court == court)&&(identical(other.round, round) || other.round == round)&&(identical(other.status, status) || other.status == status)&&(identical(other.player1Id, player1Id) || other.player1Id == player1Id)&&(identical(other.player1Name, player1Name) || other.player1Name == player1Name)&&(identical(other.player1AvatarUrl, player1AvatarUrl) || other.player1AvatarUrl == player1AvatarUrl)&&(identical(other.player2Id, player2Id) || other.player2Id == player2Id)&&(identical(other.player2Name, player2Name) || other.player2Name == player2Name)&&(identical(other.player2AvatarUrl, player2AvatarUrl) || other.player2AvatarUrl == player2AvatarUrl)&&(identical(other.opponentName, opponentName) || other.opponentName == opponentName)&&(identical(other.score, score) || other.score == score)&&(identical(other.winner, winner) || other.winner == winner)&&(identical(other.nextMatchId, nextMatchId) || other.nextMatchId == nextMatchId)&&(identical(other.matchIndex, matchIndex) || other.matchIndex == matchIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tournamentId,tournamentName,time,court,round,status,player1Id,player1Name,player1AvatarUrl,player2Id,player2Name,player2AvatarUrl,opponentName,score,winner,nextMatchId,matchIndex);

@override
String toString() {
  return 'TennisMatch(id: $id, tournamentId: $tournamentId, tournamentName: $tournamentName, time: $time, court: $court, round: $round, status: $status, player1Id: $player1Id, player1Name: $player1Name, player1AvatarUrl: $player1AvatarUrl, player2Id: $player2Id, player2Name: $player2Name, player2AvatarUrl: $player2AvatarUrl, opponentName: $opponentName, score: $score, winner: $winner, nextMatchId: $nextMatchId, matchIndex: $matchIndex)';
}


}

/// @nodoc
abstract mixin class $TennisMatchCopyWith<$Res>  {
  factory $TennisMatchCopyWith(TennisMatch value, $Res Function(TennisMatch) _then) = _$TennisMatchCopyWithImpl;
@useResult
$Res call({
 String id, String tournamentId, String tournamentName, DateTime time, String court, String round, String status, String player1Id, String player1Name, String? player1AvatarUrl, String? player2Id, String? player2Name, String? player2AvatarUrl, String? opponentName, String? score, String? winner, String? nextMatchId, int matchIndex
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tournamentId = null,Object? tournamentName = null,Object? time = null,Object? court = null,Object? round = null,Object? status = null,Object? player1Id = null,Object? player1Name = null,Object? player1AvatarUrl = freezed,Object? player2Id = freezed,Object? player2Name = freezed,Object? player2AvatarUrl = freezed,Object? opponentName = freezed,Object? score = freezed,Object? winner = freezed,Object? nextMatchId = freezed,Object? matchIndex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,tournamentName: null == tournamentName ? _self.tournamentName : tournamentName // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,court: null == court ? _self.court : court // ignore: cast_nullable_to_non_nullable
as String,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,player1Id: null == player1Id ? _self.player1Id : player1Id // ignore: cast_nullable_to_non_nullable
as String,player1Name: null == player1Name ? _self.player1Name : player1Name // ignore: cast_nullable_to_non_nullable
as String,player1AvatarUrl: freezed == player1AvatarUrl ? _self.player1AvatarUrl : player1AvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,player2Id: freezed == player2Id ? _self.player2Id : player2Id // ignore: cast_nullable_to_non_nullable
as String?,player2Name: freezed == player2Name ? _self.player2Name : player2Name // ignore: cast_nullable_to_non_nullable
as String?,player2AvatarUrl: freezed == player2AvatarUrl ? _self.player2AvatarUrl : player2AvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,opponentName: freezed == opponentName ? _self.opponentName : opponentName // ignore: cast_nullable_to_non_nullable
as String?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String?,winner: freezed == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as String?,nextMatchId: freezed == nextMatchId ? _self.nextMatchId : nextMatchId // ignore: cast_nullable_to_non_nullable
as String?,matchIndex: null == matchIndex ? _self.matchIndex : matchIndex // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tournamentId,  String tournamentName,  DateTime time,  String court,  String round,  String status,  String player1Id,  String player1Name,  String? player1AvatarUrl,  String? player2Id,  String? player2Name,  String? player2AvatarUrl,  String? opponentName,  String? score,  String? winner,  String? nextMatchId,  int matchIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TennisMatch() when $default != null:
return $default(_that.id,_that.tournamentId,_that.tournamentName,_that.time,_that.court,_that.round,_that.status,_that.player1Id,_that.player1Name,_that.player1AvatarUrl,_that.player2Id,_that.player2Name,_that.player2AvatarUrl,_that.opponentName,_that.score,_that.winner,_that.nextMatchId,_that.matchIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tournamentId,  String tournamentName,  DateTime time,  String court,  String round,  String status,  String player1Id,  String player1Name,  String? player1AvatarUrl,  String? player2Id,  String? player2Name,  String? player2AvatarUrl,  String? opponentName,  String? score,  String? winner,  String? nextMatchId,  int matchIndex)  $default,) {final _that = this;
switch (_that) {
case _TennisMatch():
return $default(_that.id,_that.tournamentId,_that.tournamentName,_that.time,_that.court,_that.round,_that.status,_that.player1Id,_that.player1Name,_that.player1AvatarUrl,_that.player2Id,_that.player2Name,_that.player2AvatarUrl,_that.opponentName,_that.score,_that.winner,_that.nextMatchId,_that.matchIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tournamentId,  String tournamentName,  DateTime time,  String court,  String round,  String status,  String player1Id,  String player1Name,  String? player1AvatarUrl,  String? player2Id,  String? player2Name,  String? player2AvatarUrl,  String? opponentName,  String? score,  String? winner,  String? nextMatchId,  int matchIndex)?  $default,) {final _that = this;
switch (_that) {
case _TennisMatch() when $default != null:
return $default(_that.id,_that.tournamentId,_that.tournamentName,_that.time,_that.court,_that.round,_that.status,_that.player1Id,_that.player1Name,_that.player1AvatarUrl,_that.player2Id,_that.player2Name,_that.player2AvatarUrl,_that.opponentName,_that.score,_that.winner,_that.nextMatchId,_that.matchIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TennisMatch implements TennisMatch {
  const _TennisMatch({required this.id, required this.tournamentId, required this.tournamentName, required this.time, required this.court, required this.round, required this.status, required this.player1Id, required this.player1Name, this.player1AvatarUrl, this.player2Id, this.player2Name, this.player2AvatarUrl, this.opponentName, this.score, this.winner, this.nextMatchId, this.matchIndex = 0});
  factory _TennisMatch.fromJson(Map<String, dynamic> json) => _$TennisMatchFromJson(json);

@override final  String id;
@override final  String tournamentId;
@override final  String tournamentName;
@override final  DateTime time;
@override final  String court;
@override final  String round;
@override final  String status;
// 'Scheduled', 'Live', 'Completed', 'Pending'
@override final  String player1Id;
@override final  String player1Name;
@override final  String? player1AvatarUrl;
@override final  String? player2Id;
@override final  String? player2Name;
@override final  String? player2AvatarUrl;
@override final  String? opponentName;
// Deprecated, kept for backward compatibility if needed, or remove
@override final  String? score;
@override final  String? winner;
@override final  String? nextMatchId;
// ID of the match where the winner goes
@override@JsonKey() final  int matchIndex;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TennisMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.tournamentName, tournamentName) || other.tournamentName == tournamentName)&&(identical(other.time, time) || other.time == time)&&(identical(other.court, court) || other.court == court)&&(identical(other.round, round) || other.round == round)&&(identical(other.status, status) || other.status == status)&&(identical(other.player1Id, player1Id) || other.player1Id == player1Id)&&(identical(other.player1Name, player1Name) || other.player1Name == player1Name)&&(identical(other.player1AvatarUrl, player1AvatarUrl) || other.player1AvatarUrl == player1AvatarUrl)&&(identical(other.player2Id, player2Id) || other.player2Id == player2Id)&&(identical(other.player2Name, player2Name) || other.player2Name == player2Name)&&(identical(other.player2AvatarUrl, player2AvatarUrl) || other.player2AvatarUrl == player2AvatarUrl)&&(identical(other.opponentName, opponentName) || other.opponentName == opponentName)&&(identical(other.score, score) || other.score == score)&&(identical(other.winner, winner) || other.winner == winner)&&(identical(other.nextMatchId, nextMatchId) || other.nextMatchId == nextMatchId)&&(identical(other.matchIndex, matchIndex) || other.matchIndex == matchIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tournamentId,tournamentName,time,court,round,status,player1Id,player1Name,player1AvatarUrl,player2Id,player2Name,player2AvatarUrl,opponentName,score,winner,nextMatchId,matchIndex);

@override
String toString() {
  return 'TennisMatch(id: $id, tournamentId: $tournamentId, tournamentName: $tournamentName, time: $time, court: $court, round: $round, status: $status, player1Id: $player1Id, player1Name: $player1Name, player1AvatarUrl: $player1AvatarUrl, player2Id: $player2Id, player2Name: $player2Name, player2AvatarUrl: $player2AvatarUrl, opponentName: $opponentName, score: $score, winner: $winner, nextMatchId: $nextMatchId, matchIndex: $matchIndex)';
}


}

/// @nodoc
abstract mixin class _$TennisMatchCopyWith<$Res> implements $TennisMatchCopyWith<$Res> {
  factory _$TennisMatchCopyWith(_TennisMatch value, $Res Function(_TennisMatch) _then) = __$TennisMatchCopyWithImpl;
@override @useResult
$Res call({
 String id, String tournamentId, String tournamentName, DateTime time, String court, String round, String status, String player1Id, String player1Name, String? player1AvatarUrl, String? player2Id, String? player2Name, String? player2AvatarUrl, String? opponentName, String? score, String? winner, String? nextMatchId, int matchIndex
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tournamentId = null,Object? tournamentName = null,Object? time = null,Object? court = null,Object? round = null,Object? status = null,Object? player1Id = null,Object? player1Name = null,Object? player1AvatarUrl = freezed,Object? player2Id = freezed,Object? player2Name = freezed,Object? player2AvatarUrl = freezed,Object? opponentName = freezed,Object? score = freezed,Object? winner = freezed,Object? nextMatchId = freezed,Object? matchIndex = null,}) {
  return _then(_TennisMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,tournamentName: null == tournamentName ? _self.tournamentName : tournamentName // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,court: null == court ? _self.court : court // ignore: cast_nullable_to_non_nullable
as String,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,player1Id: null == player1Id ? _self.player1Id : player1Id // ignore: cast_nullable_to_non_nullable
as String,player1Name: null == player1Name ? _self.player1Name : player1Name // ignore: cast_nullable_to_non_nullable
as String,player1AvatarUrl: freezed == player1AvatarUrl ? _self.player1AvatarUrl : player1AvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,player2Id: freezed == player2Id ? _self.player2Id : player2Id // ignore: cast_nullable_to_non_nullable
as String?,player2Name: freezed == player2Name ? _self.player2Name : player2Name // ignore: cast_nullable_to_non_nullable
as String?,player2AvatarUrl: freezed == player2AvatarUrl ? _self.player2AvatarUrl : player2AvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,opponentName: freezed == opponentName ? _self.opponentName : opponentName // ignore: cast_nullable_to_non_nullable
as String?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String?,winner: freezed == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as String?,nextMatchId: freezed == nextMatchId ? _self.nextMatchId : nextMatchId // ignore: cast_nullable_to_non_nullable
as String?,matchIndex: null == matchIndex ? _self.matchIndex : matchIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
