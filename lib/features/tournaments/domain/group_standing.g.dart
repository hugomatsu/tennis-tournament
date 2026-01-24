// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_standing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupStanding _$GroupStandingFromJson(Map<String, dynamic> json) =>
    _GroupStanding(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      categoryId: json['categoryId'] as String,
      groupId: json['groupId'] as String,
      participantId: json['participantId'] as String,
      participantName: json['participantName'] as String,
      participantUserIds:
          (json['participantUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      participantAvatarUrls:
          (json['participantAvatarUrls'] as List<dynamic>?)
              ?.map((e) => e as String?)
              .toList() ??
          const [],
      matchesPlayed: (json['matchesPlayed'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      setsWon: (json['setsWon'] as num?)?.toInt() ?? 0,
      setsLost: (json['setsLost'] as num?)?.toInt() ?? 0,
      gamesWon: (json['gamesWon'] as num?)?.toInt() ?? 0,
      gamesLost: (json['gamesLost'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GroupStandingToJson(_GroupStanding instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tournamentId': instance.tournamentId,
      'categoryId': instance.categoryId,
      'groupId': instance.groupId,
      'participantId': instance.participantId,
      'participantName': instance.participantName,
      'participantUserIds': instance.participantUserIds,
      'participantAvatarUrls': instance.participantAvatarUrls,
      'matchesPlayed': instance.matchesPlayed,
      'wins': instance.wins,
      'losses': instance.losses,
      'points': instance.points,
      'setsWon': instance.setsWon,
      'setsLost': instance.setsLost,
      'gamesWon': instance.gamesWon,
      'gamesLost': instance.gamesLost,
    };

_TournamentGroup _$TournamentGroupFromJson(Map<String, dynamic> json) =>
    _TournamentGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      tournamentId: json['tournamentId'] as String,
      categoryId: json['categoryId'] as String,
      standings:
          (json['standings'] as List<dynamic>?)
              ?.map((e) => GroupStanding.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isComplete: json['isComplete'] as bool? ?? false,
    );

Map<String, dynamic> _$TournamentGroupToJson(_TournamentGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tournamentId': instance.tournamentId,
      'categoryId': instance.categoryId,
      'standings': instance.standings,
      'isComplete': instance.isComplete,
    };
