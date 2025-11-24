// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TennisMatch _$TennisMatchFromJson(Map<String, dynamic> json) => _TennisMatch(
  id: json['id'] as String,
  tournamentId: json['tournamentId'] as String,
  tournamentName: json['tournamentName'] as String,
  opponentName: json['opponentName'] as String,
  time: DateTime.parse(json['time'] as String),
  court: json['court'] as String,
  round: json['round'] as String,
  status: json['status'] as String,
  score: json['score'] as String?,
  winner: json['winner'] as String?,
);

Map<String, dynamic> _$TennisMatchToJson(_TennisMatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tournamentId': instance.tournamentId,
      'tournamentName': instance.tournamentName,
      'opponentName': instance.opponentName,
      'time': instance.time.toIso8601String(),
      'court': instance.court,
      'round': instance.round,
      'status': instance.status,
      'score': instance.score,
      'winner': instance.winner,
    };
