// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TournamentCategory _$TournamentCategoryFromJson(Map<String, dynamic> json) =>
    _TournamentCategory(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      format: json['format'] as String? ?? 'round_robin',
    );

Map<String, dynamic> _$TournamentCategoryToJson(_TournamentCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tournamentId': instance.tournamentId,
      'name': instance.name,
      'type': instance.type,
      'format': instance.format,
    };
