
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tournament.freezed.dart';
part 'tournament.g.dart';

@freezed
abstract class Tournament with _$Tournament {
  const factory Tournament({
    required String id,
    required String name,
    required String status, // 'Live Now', 'Registration Open', 'Upcoming', 'Completed'
    required int playersCount,
    required String location,
    required String imageUrl,
    required String description,
    required String dateRange,
  }) = _Tournament;

  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);
}
