// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TournamentLocation _$TournamentLocationFromJson(Map<String, dynamic> json) =>
    _TournamentLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      googleMapsUrl: json['googleMapsUrl'] as String,
      description: json['description'] as String,
      numberOfCourts: (json['numberOfCourts'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$TournamentLocationToJson(_TournamentLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'googleMapsUrl': instance.googleMapsUrl,
      'description': instance.description,
      'numberOfCourts': instance.numberOfCourts,
      'imageUrl': instance.imageUrl,
    };
