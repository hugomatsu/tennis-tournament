// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TennisMatch _$TennisMatchFromJson(Map<String, dynamic> json) => _TennisMatch(
  id: json['id'] as String,
  tournamentId: json['tournamentId'] as String,
  categoryId: json['categoryId'] as String,
  tournamentName: json['tournamentName'] as String,
  time: json['time'] == null ? null : DateTime.parse(json['time'] as String),
  court: json['court'] as String?,
  round: json['round'] as String,
  status: json['status'] as String,
  durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 90,
  locationId: json['locationId'] as String?,
  player1Id: json['player1Id'] as String,
  player1Name: json['player1Name'] as String,
  player1UserIds:
      (json['player1UserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  player1AvatarUrls:
      (json['player1AvatarUrls'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList() ??
      const [],
  player2Id: json['player2Id'] as String?,
  player2Name: json['player2Name'] as String?,
  player2UserIds:
      (json['player2UserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  player2AvatarUrls:
      (json['player2AvatarUrls'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList() ??
      const [],
  opponentName: json['opponentName'] as String?,
  score: json['score'] as String?,
  winner: json['winner'] as String?,
  resultType: json['resultType'] as String? ?? 'normal',
  categoryName: json['categoryName'] as String?,
  nextMatchId: json['nextMatchId'] as String?,
  matchIndex: (json['matchIndex'] as num?)?.toInt() ?? 0,
  player1Cheers: (json['player1Cheers'] as num?)?.toInt() ?? 0,
  player2Cheers: (json['player2Cheers'] as num?)?.toInt() ?? 0,
  player1Confirmed: json['player1Confirmed'] as bool? ?? false,
  player2Confirmed: json['player2Confirmed'] as bool? ?? false,
  player1Justification: json['player1Justification'] as String?,
  player2Justification: json['player2Justification'] as String?,
);

Map<String, dynamic> _$TennisMatchToJson(_TennisMatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tournamentId': instance.tournamentId,
      'categoryId': instance.categoryId,
      'tournamentName': instance.tournamentName,
      'time': instance.time?.toIso8601String(),
      'court': instance.court,
      'round': instance.round,
      'status': instance.status,
      'durationMinutes': instance.durationMinutes,
      'locationId': instance.locationId,
      'player1Id': instance.player1Id,
      'player1Name': instance.player1Name,
      'player1UserIds': instance.player1UserIds,
      'player1AvatarUrls': instance.player1AvatarUrls,
      'player2Id': instance.player2Id,
      'player2Name': instance.player2Name,
      'player2UserIds': instance.player2UserIds,
      'player2AvatarUrls': instance.player2AvatarUrls,
      'opponentName': instance.opponentName,
      'score': instance.score,
      'winner': instance.winner,
      'resultType': instance.resultType,
      'categoryName': instance.categoryName,
      'nextMatchId': instance.nextMatchId,
      'matchIndex': instance.matchIndex,
      'player1Cheers': instance.player1Cheers,
      'player2Cheers': instance.player2Cheers,
      'player1Confirmed': instance.player1Confirmed,
      'player2Confirmed': instance.player2Confirmed,
      'player1Justification': instance.player1Justification,
      'player2Justification': instance.player2Justification,
    };
