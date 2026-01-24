// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_standing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupStanding {

 String get id; String get tournamentId; String get categoryId; String get groupId;// e.g., 'A', 'B', 'C'
 String get participantId; String get participantName; List<String> get participantUserIds; List<String?> get participantAvatarUrls; int get matchesPlayed; int get wins; int get losses; int get points; int get setsWon; int get setsLost; int get gamesWon; int get gamesLost;
/// Create a copy of GroupStanding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupStandingCopyWith<GroupStanding> get copyWith => _$GroupStandingCopyWithImpl<GroupStanding>(this as GroupStanding, _$identity);

  /// Serializes this GroupStanding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupStanding&&(identical(other.id, id) || other.id == id)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.participantName, participantName) || other.participantName == participantName)&&const DeepCollectionEquality().equals(other.participantUserIds, participantUserIds)&&const DeepCollectionEquality().equals(other.participantAvatarUrls, participantAvatarUrls)&&(identical(other.matchesPlayed, matchesPlayed) || other.matchesPlayed == matchesPlayed)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.losses, losses) || other.losses == losses)&&(identical(other.points, points) || other.points == points)&&(identical(other.setsWon, setsWon) || other.setsWon == setsWon)&&(identical(other.setsLost, setsLost) || other.setsLost == setsLost)&&(identical(other.gamesWon, gamesWon) || other.gamesWon == gamesWon)&&(identical(other.gamesLost, gamesLost) || other.gamesLost == gamesLost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tournamentId,categoryId,groupId,participantId,participantName,const DeepCollectionEquality().hash(participantUserIds),const DeepCollectionEquality().hash(participantAvatarUrls),matchesPlayed,wins,losses,points,setsWon,setsLost,gamesWon,gamesLost);

@override
String toString() {
  return 'GroupStanding(id: $id, tournamentId: $tournamentId, categoryId: $categoryId, groupId: $groupId, participantId: $participantId, participantName: $participantName, participantUserIds: $participantUserIds, participantAvatarUrls: $participantAvatarUrls, matchesPlayed: $matchesPlayed, wins: $wins, losses: $losses, points: $points, setsWon: $setsWon, setsLost: $setsLost, gamesWon: $gamesWon, gamesLost: $gamesLost)';
}


}

/// @nodoc
abstract mixin class $GroupStandingCopyWith<$Res>  {
  factory $GroupStandingCopyWith(GroupStanding value, $Res Function(GroupStanding) _then) = _$GroupStandingCopyWithImpl;
@useResult
$Res call({
 String id, String tournamentId, String categoryId, String groupId, String participantId, String participantName, List<String> participantUserIds, List<String?> participantAvatarUrls, int matchesPlayed, int wins, int losses, int points, int setsWon, int setsLost, int gamesWon, int gamesLost
});




}
/// @nodoc
class _$GroupStandingCopyWithImpl<$Res>
    implements $GroupStandingCopyWith<$Res> {
  _$GroupStandingCopyWithImpl(this._self, this._then);

  final GroupStanding _self;
  final $Res Function(GroupStanding) _then;

/// Create a copy of GroupStanding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tournamentId = null,Object? categoryId = null,Object? groupId = null,Object? participantId = null,Object? participantName = null,Object? participantUserIds = null,Object? participantAvatarUrls = null,Object? matchesPlayed = null,Object? wins = null,Object? losses = null,Object? points = null,Object? setsWon = null,Object? setsLost = null,Object? gamesWon = null,Object? gamesLost = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as String,participantName: null == participantName ? _self.participantName : participantName // ignore: cast_nullable_to_non_nullable
as String,participantUserIds: null == participantUserIds ? _self.participantUserIds : participantUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,participantAvatarUrls: null == participantAvatarUrls ? _self.participantAvatarUrls : participantAvatarUrls // ignore: cast_nullable_to_non_nullable
as List<String?>,matchesPlayed: null == matchesPlayed ? _self.matchesPlayed : matchesPlayed // ignore: cast_nullable_to_non_nullable
as int,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,setsWon: null == setsWon ? _self.setsWon : setsWon // ignore: cast_nullable_to_non_nullable
as int,setsLost: null == setsLost ? _self.setsLost : setsLost // ignore: cast_nullable_to_non_nullable
as int,gamesWon: null == gamesWon ? _self.gamesWon : gamesWon // ignore: cast_nullable_to_non_nullable
as int,gamesLost: null == gamesLost ? _self.gamesLost : gamesLost // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupStanding].
extension GroupStandingPatterns on GroupStanding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupStanding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupStanding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupStanding value)  $default,){
final _that = this;
switch (_that) {
case _GroupStanding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupStanding value)?  $default,){
final _that = this;
switch (_that) {
case _GroupStanding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tournamentId,  String categoryId,  String groupId,  String participantId,  String participantName,  List<String> participantUserIds,  List<String?> participantAvatarUrls,  int matchesPlayed,  int wins,  int losses,  int points,  int setsWon,  int setsLost,  int gamesWon,  int gamesLost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupStanding() when $default != null:
return $default(_that.id,_that.tournamentId,_that.categoryId,_that.groupId,_that.participantId,_that.participantName,_that.participantUserIds,_that.participantAvatarUrls,_that.matchesPlayed,_that.wins,_that.losses,_that.points,_that.setsWon,_that.setsLost,_that.gamesWon,_that.gamesLost);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tournamentId,  String categoryId,  String groupId,  String participantId,  String participantName,  List<String> participantUserIds,  List<String?> participantAvatarUrls,  int matchesPlayed,  int wins,  int losses,  int points,  int setsWon,  int setsLost,  int gamesWon,  int gamesLost)  $default,) {final _that = this;
switch (_that) {
case _GroupStanding():
return $default(_that.id,_that.tournamentId,_that.categoryId,_that.groupId,_that.participantId,_that.participantName,_that.participantUserIds,_that.participantAvatarUrls,_that.matchesPlayed,_that.wins,_that.losses,_that.points,_that.setsWon,_that.setsLost,_that.gamesWon,_that.gamesLost);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tournamentId,  String categoryId,  String groupId,  String participantId,  String participantName,  List<String> participantUserIds,  List<String?> participantAvatarUrls,  int matchesPlayed,  int wins,  int losses,  int points,  int setsWon,  int setsLost,  int gamesWon,  int gamesLost)?  $default,) {final _that = this;
switch (_that) {
case _GroupStanding() when $default != null:
return $default(_that.id,_that.tournamentId,_that.categoryId,_that.groupId,_that.participantId,_that.participantName,_that.participantUserIds,_that.participantAvatarUrls,_that.matchesPlayed,_that.wins,_that.losses,_that.points,_that.setsWon,_that.setsLost,_that.gamesWon,_that.gamesLost);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GroupStanding implements GroupStanding {
  const _GroupStanding({required this.id, required this.tournamentId, required this.categoryId, required this.groupId, required this.participantId, required this.participantName, final  List<String> participantUserIds = const [], final  List<String?> participantAvatarUrls = const [], this.matchesPlayed = 0, this.wins = 0, this.losses = 0, this.points = 0, this.setsWon = 0, this.setsLost = 0, this.gamesWon = 0, this.gamesLost = 0}): _participantUserIds = participantUserIds,_participantAvatarUrls = participantAvatarUrls;
  factory _GroupStanding.fromJson(Map<String, dynamic> json) => _$GroupStandingFromJson(json);

@override final  String id;
@override final  String tournamentId;
@override final  String categoryId;
@override final  String groupId;
// e.g., 'A', 'B', 'C'
@override final  String participantId;
@override final  String participantName;
 final  List<String> _participantUserIds;
@override@JsonKey() List<String> get participantUserIds {
  if (_participantUserIds is EqualUnmodifiableListView) return _participantUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantUserIds);
}

 final  List<String?> _participantAvatarUrls;
@override@JsonKey() List<String?> get participantAvatarUrls {
  if (_participantAvatarUrls is EqualUnmodifiableListView) return _participantAvatarUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantAvatarUrls);
}

@override@JsonKey() final  int matchesPlayed;
@override@JsonKey() final  int wins;
@override@JsonKey() final  int losses;
@override@JsonKey() final  int points;
@override@JsonKey() final  int setsWon;
@override@JsonKey() final  int setsLost;
@override@JsonKey() final  int gamesWon;
@override@JsonKey() final  int gamesLost;

/// Create a copy of GroupStanding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupStandingCopyWith<_GroupStanding> get copyWith => __$GroupStandingCopyWithImpl<_GroupStanding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupStandingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupStanding&&(identical(other.id, id) || other.id == id)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.participantName, participantName) || other.participantName == participantName)&&const DeepCollectionEquality().equals(other._participantUserIds, _participantUserIds)&&const DeepCollectionEquality().equals(other._participantAvatarUrls, _participantAvatarUrls)&&(identical(other.matchesPlayed, matchesPlayed) || other.matchesPlayed == matchesPlayed)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.losses, losses) || other.losses == losses)&&(identical(other.points, points) || other.points == points)&&(identical(other.setsWon, setsWon) || other.setsWon == setsWon)&&(identical(other.setsLost, setsLost) || other.setsLost == setsLost)&&(identical(other.gamesWon, gamesWon) || other.gamesWon == gamesWon)&&(identical(other.gamesLost, gamesLost) || other.gamesLost == gamesLost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tournamentId,categoryId,groupId,participantId,participantName,const DeepCollectionEquality().hash(_participantUserIds),const DeepCollectionEquality().hash(_participantAvatarUrls),matchesPlayed,wins,losses,points,setsWon,setsLost,gamesWon,gamesLost);

@override
String toString() {
  return 'GroupStanding(id: $id, tournamentId: $tournamentId, categoryId: $categoryId, groupId: $groupId, participantId: $participantId, participantName: $participantName, participantUserIds: $participantUserIds, participantAvatarUrls: $participantAvatarUrls, matchesPlayed: $matchesPlayed, wins: $wins, losses: $losses, points: $points, setsWon: $setsWon, setsLost: $setsLost, gamesWon: $gamesWon, gamesLost: $gamesLost)';
}


}

/// @nodoc
abstract mixin class _$GroupStandingCopyWith<$Res> implements $GroupStandingCopyWith<$Res> {
  factory _$GroupStandingCopyWith(_GroupStanding value, $Res Function(_GroupStanding) _then) = __$GroupStandingCopyWithImpl;
@override @useResult
$Res call({
 String id, String tournamentId, String categoryId, String groupId, String participantId, String participantName, List<String> participantUserIds, List<String?> participantAvatarUrls, int matchesPlayed, int wins, int losses, int points, int setsWon, int setsLost, int gamesWon, int gamesLost
});




}
/// @nodoc
class __$GroupStandingCopyWithImpl<$Res>
    implements _$GroupStandingCopyWith<$Res> {
  __$GroupStandingCopyWithImpl(this._self, this._then);

  final _GroupStanding _self;
  final $Res Function(_GroupStanding) _then;

/// Create a copy of GroupStanding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tournamentId = null,Object? categoryId = null,Object? groupId = null,Object? participantId = null,Object? participantName = null,Object? participantUserIds = null,Object? participantAvatarUrls = null,Object? matchesPlayed = null,Object? wins = null,Object? losses = null,Object? points = null,Object? setsWon = null,Object? setsLost = null,Object? gamesWon = null,Object? gamesLost = null,}) {
  return _then(_GroupStanding(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as String,participantName: null == participantName ? _self.participantName : participantName // ignore: cast_nullable_to_non_nullable
as String,participantUserIds: null == participantUserIds ? _self._participantUserIds : participantUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,participantAvatarUrls: null == participantAvatarUrls ? _self._participantAvatarUrls : participantAvatarUrls // ignore: cast_nullable_to_non_nullable
as List<String?>,matchesPlayed: null == matchesPlayed ? _self.matchesPlayed : matchesPlayed // ignore: cast_nullable_to_non_nullable
as int,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,setsWon: null == setsWon ? _self.setsWon : setsWon // ignore: cast_nullable_to_non_nullable
as int,setsLost: null == setsLost ? _self.setsLost : setsLost // ignore: cast_nullable_to_non_nullable
as int,gamesWon: null == gamesWon ? _self.gamesWon : gamesWon // ignore: cast_nullable_to_non_nullable
as int,gamesLost: null == gamesLost ? _self.gamesLost : gamesLost // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TournamentGroup {

 String get id;// e.g., 'A', 'B'
 String get name;// e.g., 'Group A'
 String get tournamentId; String get categoryId; List<GroupStanding> get standings; bool get isComplete;
/// Create a copy of TournamentGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentGroupCopyWith<TournamentGroup> get copyWith => _$TournamentGroupCopyWithImpl<TournamentGroup>(this as TournamentGroup, _$identity);

  /// Serializes this TournamentGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other.standings, standings)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,tournamentId,categoryId,const DeepCollectionEquality().hash(standings),isComplete);

@override
String toString() {
  return 'TournamentGroup(id: $id, name: $name, tournamentId: $tournamentId, categoryId: $categoryId, standings: $standings, isComplete: $isComplete)';
}


}

/// @nodoc
abstract mixin class $TournamentGroupCopyWith<$Res>  {
  factory $TournamentGroupCopyWith(TournamentGroup value, $Res Function(TournamentGroup) _then) = _$TournamentGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, String tournamentId, String categoryId, List<GroupStanding> standings, bool isComplete
});




}
/// @nodoc
class _$TournamentGroupCopyWithImpl<$Res>
    implements $TournamentGroupCopyWith<$Res> {
  _$TournamentGroupCopyWithImpl(this._self, this._then);

  final TournamentGroup _self;
  final $Res Function(TournamentGroup) _then;

/// Create a copy of TournamentGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? tournamentId = null,Object? categoryId = null,Object? standings = null,Object? isComplete = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,standings: null == standings ? _self.standings : standings // ignore: cast_nullable_to_non_nullable
as List<GroupStanding>,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentGroup].
extension TournamentGroupPatterns on TournamentGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentGroup value)  $default,){
final _that = this;
switch (_that) {
case _TournamentGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentGroup value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String tournamentId,  String categoryId,  List<GroupStanding> standings,  bool isComplete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentGroup() when $default != null:
return $default(_that.id,_that.name,_that.tournamentId,_that.categoryId,_that.standings,_that.isComplete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String tournamentId,  String categoryId,  List<GroupStanding> standings,  bool isComplete)  $default,) {final _that = this;
switch (_that) {
case _TournamentGroup():
return $default(_that.id,_that.name,_that.tournamentId,_that.categoryId,_that.standings,_that.isComplete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String tournamentId,  String categoryId,  List<GroupStanding> standings,  bool isComplete)?  $default,) {final _that = this;
switch (_that) {
case _TournamentGroup() when $default != null:
return $default(_that.id,_that.name,_that.tournamentId,_that.categoryId,_that.standings,_that.isComplete);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentGroup implements TournamentGroup {
  const _TournamentGroup({required this.id, required this.name, required this.tournamentId, required this.categoryId, final  List<GroupStanding> standings = const [], this.isComplete = false}): _standings = standings;
  factory _TournamentGroup.fromJson(Map<String, dynamic> json) => _$TournamentGroupFromJson(json);

@override final  String id;
// e.g., 'A', 'B'
@override final  String name;
// e.g., 'Group A'
@override final  String tournamentId;
@override final  String categoryId;
 final  List<GroupStanding> _standings;
@override@JsonKey() List<GroupStanding> get standings {
  if (_standings is EqualUnmodifiableListView) return _standings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_standings);
}

@override@JsonKey() final  bool isComplete;

/// Create a copy of TournamentGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentGroupCopyWith<_TournamentGroup> get copyWith => __$TournamentGroupCopyWithImpl<_TournamentGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other._standings, _standings)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,tournamentId,categoryId,const DeepCollectionEquality().hash(_standings),isComplete);

@override
String toString() {
  return 'TournamentGroup(id: $id, name: $name, tournamentId: $tournamentId, categoryId: $categoryId, standings: $standings, isComplete: $isComplete)';
}


}

/// @nodoc
abstract mixin class _$TournamentGroupCopyWith<$Res> implements $TournamentGroupCopyWith<$Res> {
  factory _$TournamentGroupCopyWith(_TournamentGroup value, $Res Function(_TournamentGroup) _then) = __$TournamentGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String tournamentId, String categoryId, List<GroupStanding> standings, bool isComplete
});




}
/// @nodoc
class __$TournamentGroupCopyWithImpl<$Res>
    implements _$TournamentGroupCopyWith<$Res> {
  __$TournamentGroupCopyWithImpl(this._self, this._then);

  final _TournamentGroup _self;
  final $Res Function(_TournamentGroup) _then;

/// Create a copy of TournamentGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? tournamentId = null,Object? categoryId = null,Object? standings = null,Object? isComplete = null,}) {
  return _then(_TournamentGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,standings: null == standings ? _self._standings : standings // ignore: cast_nullable_to_non_nullable
as List<GroupStanding>,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
