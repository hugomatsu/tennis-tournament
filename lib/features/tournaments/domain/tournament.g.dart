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
  imageUrl: json['imageUrl'] as String,
  description: json['description'] as String,
  dateRange: json['dateRange'] as String,
);

Map<String, dynamic> _$TournamentToJson(_Tournament instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'playersCount': instance.playersCount,
      'location': instance.location,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'dateRange': instance.dateRange,
    };
