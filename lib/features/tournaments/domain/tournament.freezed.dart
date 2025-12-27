// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tournament {

 String get id; String get name; String get status;// 'Live Now', 'Registration Open', 'Upcoming', 'Completed'
 int get playersCount; String get location; String? get locationId;// Added to link to Location entity
 String get imageUrl; String get description; String get dateRange; String get category; List<DailySchedule> get scheduleRules;
/// Create a copy of Tournament
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentCopyWith<Tournament> get copyWith => _$TournamentCopyWithImpl<Tournament>(this as Tournament, _$identity);

  /// Serializes this Tournament to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tournament&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.playersCount, playersCount) || other.playersCount == playersCount)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.scheduleRules, scheduleRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,status,playersCount,location,locationId,imageUrl,description,dateRange,category,const DeepCollectionEquality().hash(scheduleRules));

@override
String toString() {
  return 'Tournament(id: $id, name: $name, status: $status, playersCount: $playersCount, location: $location, locationId: $locationId, imageUrl: $imageUrl, description: $description, dateRange: $dateRange, category: $category, scheduleRules: $scheduleRules)';
}


}

/// @nodoc
abstract mixin class $TournamentCopyWith<$Res>  {
  factory $TournamentCopyWith(Tournament value, $Res Function(Tournament) _then) = _$TournamentCopyWithImpl;
@useResult
$Res call({
 String id, String name, String status, int playersCount, String location, String? locationId, String imageUrl, String description, String dateRange, String category, List<DailySchedule> scheduleRules
});




}
/// @nodoc
class _$TournamentCopyWithImpl<$Res>
    implements $TournamentCopyWith<$Res> {
  _$TournamentCopyWithImpl(this._self, this._then);

  final Tournament _self;
  final $Res Function(Tournament) _then;

/// Create a copy of Tournament
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? status = null,Object? playersCount = null,Object? location = null,Object? locationId = freezed,Object? imageUrl = null,Object? description = null,Object? dateRange = null,Object? category = null,Object? scheduleRules = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,playersCount: null == playersCount ? _self.playersCount : playersCount // ignore: cast_nullable_to_non_nullable
as int,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,scheduleRules: null == scheduleRules ? _self.scheduleRules : scheduleRules // ignore: cast_nullable_to_non_nullable
as List<DailySchedule>,
  ));
}

}


/// Adds pattern-matching-related methods to [Tournament].
extension TournamentPatterns on Tournament {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tournament value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tournament() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tournament value)  $default,){
final _that = this;
switch (_that) {
case _Tournament():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tournament value)?  $default,){
final _that = this;
switch (_that) {
case _Tournament() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String status,  int playersCount,  String location,  String? locationId,  String imageUrl,  String description,  String dateRange,  String category,  List<DailySchedule> scheduleRules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tournament() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.playersCount,_that.location,_that.locationId,_that.imageUrl,_that.description,_that.dateRange,_that.category,_that.scheduleRules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String status,  int playersCount,  String location,  String? locationId,  String imageUrl,  String description,  String dateRange,  String category,  List<DailySchedule> scheduleRules)  $default,) {final _that = this;
switch (_that) {
case _Tournament():
return $default(_that.id,_that.name,_that.status,_that.playersCount,_that.location,_that.locationId,_that.imageUrl,_that.description,_that.dateRange,_that.category,_that.scheduleRules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String status,  int playersCount,  String location,  String? locationId,  String imageUrl,  String description,  String dateRange,  String category,  List<DailySchedule> scheduleRules)?  $default,) {final _that = this;
switch (_that) {
case _Tournament() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.playersCount,_that.location,_that.locationId,_that.imageUrl,_that.description,_that.dateRange,_that.category,_that.scheduleRules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tournament implements Tournament {
  const _Tournament({required this.id, required this.name, required this.status, required this.playersCount, required this.location, this.locationId, required this.imageUrl, required this.description, required this.dateRange, this.category = 'Open', final  List<DailySchedule> scheduleRules = const []}): _scheduleRules = scheduleRules;
  factory _Tournament.fromJson(Map<String, dynamic> json) => _$TournamentFromJson(json);

@override final  String id;
@override final  String name;
@override final  String status;
// 'Live Now', 'Registration Open', 'Upcoming', 'Completed'
@override final  int playersCount;
@override final  String location;
@override final  String? locationId;
// Added to link to Location entity
@override final  String imageUrl;
@override final  String description;
@override final  String dateRange;
@override@JsonKey() final  String category;
 final  List<DailySchedule> _scheduleRules;
@override@JsonKey() List<DailySchedule> get scheduleRules {
  if (_scheduleRules is EqualUnmodifiableListView) return _scheduleRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scheduleRules);
}


/// Create a copy of Tournament
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentCopyWith<_Tournament> get copyWith => __$TournamentCopyWithImpl<_Tournament>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tournament&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.playersCount, playersCount) || other.playersCount == playersCount)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._scheduleRules, _scheduleRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,status,playersCount,location,locationId,imageUrl,description,dateRange,category,const DeepCollectionEquality().hash(_scheduleRules));

@override
String toString() {
  return 'Tournament(id: $id, name: $name, status: $status, playersCount: $playersCount, location: $location, locationId: $locationId, imageUrl: $imageUrl, description: $description, dateRange: $dateRange, category: $category, scheduleRules: $scheduleRules)';
}


}

/// @nodoc
abstract mixin class _$TournamentCopyWith<$Res> implements $TournamentCopyWith<$Res> {
  factory _$TournamentCopyWith(_Tournament value, $Res Function(_Tournament) _then) = __$TournamentCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String status, int playersCount, String location, String? locationId, String imageUrl, String description, String dateRange, String category, List<DailySchedule> scheduleRules
});




}
/// @nodoc
class __$TournamentCopyWithImpl<$Res>
    implements _$TournamentCopyWith<$Res> {
  __$TournamentCopyWithImpl(this._self, this._then);

  final _Tournament _self;
  final $Res Function(_Tournament) _then;

/// Create a copy of Tournament
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? status = null,Object? playersCount = null,Object? location = null,Object? locationId = freezed,Object? imageUrl = null,Object? description = null,Object? dateRange = null,Object? category = null,Object? scheduleRules = null,}) {
  return _then(_Tournament(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,playersCount: null == playersCount ? _self.playersCount : playersCount // ignore: cast_nullable_to_non_nullable
as int,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,scheduleRules: null == scheduleRules ? _self._scheduleRules : scheduleRules // ignore: cast_nullable_to_non_nullable
as List<DailySchedule>,
  ));
}


}


/// @nodoc
mixin _$DailySchedule {

 String get date; String get startTime; String get endTime; int get courtCount;
/// Create a copy of DailySchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyScheduleCopyWith<DailySchedule> get copyWith => _$DailyScheduleCopyWithImpl<DailySchedule>(this as DailySchedule, _$identity);

  /// Serializes this DailySchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailySchedule&&(identical(other.date, date) || other.date == date)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.courtCount, courtCount) || other.courtCount == courtCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,startTime,endTime,courtCount);

@override
String toString() {
  return 'DailySchedule(date: $date, startTime: $startTime, endTime: $endTime, courtCount: $courtCount)';
}


}

/// @nodoc
abstract mixin class $DailyScheduleCopyWith<$Res>  {
  factory $DailyScheduleCopyWith(DailySchedule value, $Res Function(DailySchedule) _then) = _$DailyScheduleCopyWithImpl;
@useResult
$Res call({
 String date, String startTime, String endTime, int courtCount
});




}
/// @nodoc
class _$DailyScheduleCopyWithImpl<$Res>
    implements $DailyScheduleCopyWith<$Res> {
  _$DailyScheduleCopyWithImpl(this._self, this._then);

  final DailySchedule _self;
  final $Res Function(DailySchedule) _then;

/// Create a copy of DailySchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? startTime = null,Object? endTime = null,Object? courtCount = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,courtCount: null == courtCount ? _self.courtCount : courtCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailySchedule].
extension DailySchedulePatterns on DailySchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailySchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailySchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailySchedule value)  $default,){
final _that = this;
switch (_that) {
case _DailySchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailySchedule value)?  $default,){
final _that = this;
switch (_that) {
case _DailySchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String startTime,  String endTime,  int courtCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailySchedule() when $default != null:
return $default(_that.date,_that.startTime,_that.endTime,_that.courtCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String startTime,  String endTime,  int courtCount)  $default,) {final _that = this;
switch (_that) {
case _DailySchedule():
return $default(_that.date,_that.startTime,_that.endTime,_that.courtCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String startTime,  String endTime,  int courtCount)?  $default,) {final _that = this;
switch (_that) {
case _DailySchedule() when $default != null:
return $default(_that.date,_that.startTime,_that.endTime,_that.courtCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailySchedule implements DailySchedule {
  const _DailySchedule({required this.date, required this.startTime, required this.endTime, this.courtCount = 1});
  factory _DailySchedule.fromJson(Map<String, dynamic> json) => _$DailyScheduleFromJson(json);

@override final  String date;
@override final  String startTime;
@override final  String endTime;
@override@JsonKey() final  int courtCount;

/// Create a copy of DailySchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyScheduleCopyWith<_DailySchedule> get copyWith => __$DailyScheduleCopyWithImpl<_DailySchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailySchedule&&(identical(other.date, date) || other.date == date)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.courtCount, courtCount) || other.courtCount == courtCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,startTime,endTime,courtCount);

@override
String toString() {
  return 'DailySchedule(date: $date, startTime: $startTime, endTime: $endTime, courtCount: $courtCount)';
}


}

/// @nodoc
abstract mixin class _$DailyScheduleCopyWith<$Res> implements $DailyScheduleCopyWith<$Res> {
  factory _$DailyScheduleCopyWith(_DailySchedule value, $Res Function(_DailySchedule) _then) = __$DailyScheduleCopyWithImpl;
@override @useResult
$Res call({
 String date, String startTime, String endTime, int courtCount
});




}
/// @nodoc
class __$DailyScheduleCopyWithImpl<$Res>
    implements _$DailyScheduleCopyWith<$Res> {
  __$DailyScheduleCopyWithImpl(this._self, this._then);

  final _DailySchedule _self;
  final $Res Function(_DailySchedule) _then;

/// Create a copy of DailySchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? startTime = null,Object? endTime = null,Object? courtCount = null,}) {
  return _then(_DailySchedule(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,courtCount: null == courtCount ? _self.courtCount : courtCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
