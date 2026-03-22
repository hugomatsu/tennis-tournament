
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
    String? locationId, // Added to link to Location entity
    String? ownerId, // Added for monetization/ownership
    @Default([]) List<String> adminIds, // Added for shared administration
    required String imageUrl,
    required String description,
    required String dateRange,
    @Default('Open') String category,
    @Default('singles') String format, // 'singles', 'doubles'
    @Default('Free') String subscriptionTier, // 'Free', 'Premium'
    @Default([]) List<DailySchedule> scheduleRules,
    // Open Tennis Mode fields
    @Default('mataMata') String tournamentType, // 'mataMata', 'openTennis'
    @Default(0) int groupCount, // 0 = auto (half of players)
    @Default(3) int pointsPerWin, // Points awarded for each win
    @Default(1) int advanceCount, // How many players from each group advance to playoff
    @Default({}) Map<String, String> defaultWeekdayTimes, // e.g. {"1":"18:00","3":"18:00"}
    @Default({}) Map<String, dynamic> matchRules, // structured match rules
  }) = _Tournament;

  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);
}

@freezed
abstract class DailySchedule with _$DailySchedule {
  const factory DailySchedule({
    required String date,
    required String startTime,
    required String endTime,
    @Default(1) int courtCount,
  }) = _DailySchedule;

  factory DailySchedule.fromJson(Map<String, dynamic> json) =>
      _$DailyScheduleFromJson(json);
}
