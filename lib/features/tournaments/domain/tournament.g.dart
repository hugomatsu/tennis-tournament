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
  imageUrl: json['imageUrl'] as String,
  description: json['description'] as String,
  dateRange: json['dateRange'] as String,
  category: json['category'] as String? ?? 'Open',
  format: json['format'] as String? ?? 'singles',
  scheduleRules:
      (json['scheduleRules'] as List<dynamic>?)
          ?.map((e) => DailySchedule.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TournamentToJson(_Tournament instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'playersCount': instance.playersCount,
      'location': instance.location,
      'locationId': instance.locationId,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'dateRange': instance.dateRange,
      'category': instance.category,
      'format': instance.format,
      'scheduleRules': instance.scheduleRules,
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
