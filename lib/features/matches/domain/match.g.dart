// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TennisMatch _$TennisMatchFromJson(Map<String, dynamic> json) => _TennisMatch(
  id: json['id'] as String,
  tournamentId: json['tournamentId'] as String,
  tournamentName: json['tournamentName'] as String,
  time: DateTime.parse(json['time'] as String),
  court: json['court'] as String,
  round: json['round'] as String,
  status: json['status'] as String,
  player1Id: json['player1Id'] as String,
  player1Name: json['player1Name'] as String,
  player1AvatarUrl: json['player1AvatarUrl'] as String?,
  player2Id: json['player2Id'] as String?,
  player2Name: json['player2Name'] as String?,
  player2AvatarUrl: json['player2AvatarUrl'] as String?,
  opponentName: json['opponentName'] as String?,
  score: json['score'] as String?,
  winner: json['winner'] as String?,
  nextMatchId: json['nextMatchId'] as String?,
  matchIndex: (json['matchIndex'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TennisMatchToJson(_TennisMatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tournamentId': instance.tournamentId,
      'tournamentName': instance.tournamentName,
      'time': instance.time.toIso8601String(),
      'court': instance.court,
      'round': instance.round,
      'status': instance.status,
      'player1Id': instance.player1Id,
      'player1Name': instance.player1Name,
      'player1AvatarUrl': instance.player1AvatarUrl,
      'player2Id': instance.player2Id,
      'player2Name': instance.player2Name,
      'player2AvatarUrl': instance.player2AvatarUrl,
      'opponentName': instance.opponentName,
      'score': instance.score,
      'winner': instance.winner,
      'nextMatchId': instance.nextMatchId,
      'matchIndex': instance.matchIndex,
    };
