import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_standing.freezed.dart';
part 'group_standing.g.dart';

/// Represents a player's standing within a tournament group (for Open Tennis Mode)
@freezed
abstract class GroupStanding with _$GroupStanding {
  const factory GroupStanding({
    required String id,
    required String tournamentId,
    required String categoryId,
    required String groupId, // e.g., 'A', 'B', 'C'
    required String participantId,
    required String participantName,
    @Default([]) List<String> participantUserIds,
    @Default([]) List<String?> participantAvatarUrls,
    @Default(0) int matchesPlayed,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int points,
    @Default(0) int setsWon,
    @Default(0) int setsLost,
    @Default(0) int gamesWon,
    @Default(0) int gamesLost,
  }) = _GroupStanding;

  factory GroupStanding.fromJson(Map<String, dynamic> json) =>
      _$GroupStandingFromJson(json);
}

/// Represents a tournament group containing multiple standings
@freezed
abstract class TournamentGroup with _$TournamentGroup {
  const factory TournamentGroup({
    required String id, // e.g., 'A', 'B'
    required String name, // e.g., 'Group A'
    required String tournamentId,
    required String categoryId,
    @Default([]) List<GroupStanding> standings,
    @Default(false) bool isComplete, // All group matches finished
  }) = _TournamentGroup;

  factory TournamentGroup.fromJson(Map<String, dynamic> json) =>
      _$TournamentGroupFromJson(json);
}
