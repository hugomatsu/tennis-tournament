// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tournament _$TournamentFromJson(Map<String, dynamic> json) => _Tournament(
  id: json['id'] as String,
  name: json['name'] as String,
  status: json['status'] as String,
  playersCount: (json['playersCount'] as num).toInt(),
  location: json['location'] as String,
  locationId: json['locationId'] as String?,
  ownerId: json['ownerId'] as String?,
  adminIds:
      (json['adminIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  imageUrl: json['imageUrl'] as String,
  description: json['description'] as String,
  dateRange: json['dateRange'] as String,
  category: json['category'] as String? ?? 'Open',
  format: json['format'] as String? ?? 'singles',
  subscriptionTier: json['subscriptionTier'] as String? ?? 'Free',
  scheduleRules:
      (json['scheduleRules'] as List<dynamic>?)
          ?.map((e) => DailySchedule.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  tournamentType: json['tournamentType'] as String? ?? 'mataMata',
  groupCount: (json['groupCount'] as num?)?.toInt() ?? 0,
  pointsPerWin: (json['pointsPerWin'] as num?)?.toInt() ?? 3,
  advanceCount: (json['advanceCount'] as num?)?.toInt() ?? 1,
  defaultWeekdayTimes:
      (json['defaultWeekdayTimes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$TournamentToJson(_Tournament instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'playersCount': instance.playersCount,
      'location': instance.location,
      'locationId': instance.locationId,
      'ownerId': instance.ownerId,
      'adminIds': instance.adminIds,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'dateRange': instance.dateRange,
      'category': instance.category,
      'format': instance.format,
      'subscriptionTier': instance.subscriptionTier,
      'scheduleRules': instance.scheduleRules,
      'tournamentType': instance.tournamentType,
      'groupCount': instance.groupCount,
      'pointsPerWin': instance.pointsPerWin,
      'advanceCount': instance.advanceCount,
      'defaultWeekdayTimes': instance.defaultWeekdayTimes,
    };

_DailySchedule _$DailyScheduleFromJson(Map<String, dynamic> json) =>
    _DailySchedule(
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      courtCount: (json['courtCount'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$DailyScheduleToJson(_DailySchedule instance) =>
    <String, dynamic>{
      'date': instance.date,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'courtCount': instance.courtCount,
    };
