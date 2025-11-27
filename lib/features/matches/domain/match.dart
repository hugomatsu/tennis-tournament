
import 'package:freezed_annotation/freezed_annotation.dart';

part 'match.freezed.dart';
part 'match.g.dart';

@freezed
abstract class TennisMatch with _$TennisMatch {
  const factory TennisMatch({
    required String id,
    required String tournamentId,
    required String tournamentName,
    required DateTime time,
    required String court,
    required String round,
    required String status, // 'Scheduled', 'Live', 'Completed', 'Pending'
    required String player1Id,
    required String player1Name,
    String? player1AvatarUrl,
    String? player2Id,
    String? player2Name,
    String? player2AvatarUrl,
    String? opponentName, // Deprecated, kept for backward compatibility if needed, or remove
    String? score,
    String? winner,
    String? nextMatchId, // ID of the match where the winner goes
    @Default(0) int matchIndex, // For sorting in bracket
    @Default(0) int player1Cheers,
    @Default(0) int player2Cheers,
    @Default(false) bool player1Confirmed,
    @Default(false) bool player2Confirmed,
  }) = _TennisMatch;

  factory TennisMatch.fromJson(Map<String, dynamic> json) =>
      _$TennisMatchFromJson(json);
}
