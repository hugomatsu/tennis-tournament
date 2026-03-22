
import 'package:freezed_annotation/freezed_annotation.dart';

part 'match.freezed.dart';
part 'match.g.dart';

@freezed
abstract class TennisMatch with _$TennisMatch {
  const factory TennisMatch({
    required String id,
    required String tournamentId,
    required String categoryId,
    required String tournamentName,
    required DateTime time,
    required String court,
    required String round,
    required String status, // 'Preparing', 'Scheduled', 'Confirmed', 'Started', 'Finished'
    @Default(90) int durationMinutes,
    String? locationId,
    required String player1Id, // Participant ID
    required String player1Name, // Team Name
    @Default([]) List<String> player1UserIds,
    @Default([]) List<String?> player1AvatarUrls,
    String? player2Id, // Participant ID
    String? player2Name, // Team Name
    @Default([]) List<String> player2UserIds,
    @Default([]) List<String?> player2AvatarUrls,
    String? opponentName, // Deprecated, kept for backward compatibility if needed, or remove
    String? score,
    String? winner,
    @Default('normal') String resultType, // 'normal' or 'walkover'
    String? nextMatchId, // ID of the match where the winner goes
    @Default(0) int matchIndex, // For sorting in bracket
    @Default(0) int player1Cheers,
    @Default(0) int player2Cheers,
    @Default(false) bool player1Confirmed,
    @Default(false) bool player2Confirmed,
    String? player1Justification,
    String? player2Justification,
  }) = _TennisMatch;

  factory TennisMatch.fromJson(Map<String, dynamic> json) =>
      _$TennisMatchFromJson(json);
}
