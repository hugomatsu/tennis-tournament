
import 'package:freezed_annotation/freezed_annotation.dart';

part 'match.freezed.dart';
part 'match.g.dart';

@freezed
abstract class TennisMatch with _$TennisMatch {
  const factory TennisMatch({
    required String id,
    required String tournamentId,
    required String tournamentName,
    required String opponentName,
    required DateTime time,
    required String court,
    required String round,
    required String status, // 'Scheduled', 'Live', 'Completed', 'Pending'
    String? score,
    String? winner,
  }) = _TennisMatch;

  factory TennisMatch.fromJson(Map<String, dynamic> json) =>
      _$TennisMatchFromJson(json);
}
