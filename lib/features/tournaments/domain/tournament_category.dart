import 'package:freezed_annotation/freezed_annotation.dart';

part 'tournament_category.freezed.dart';
part 'tournament_category.g.dart';

@freezed
abstract class TournamentCategory with _$TournamentCategory {
  const factory TournamentCategory({
    required String id,
    required String tournamentId,
    required String name, // e.g., "Men's A", "Mixed Doubles"
    required String type, // 'singles' | 'doubles'
    @Default('round_robin') String format, // 'round_robin' | 'elimination'
  }) = _TournamentCategory;

  factory TournamentCategory.fromJson(Map<String, dynamic> json) =>
      _$TournamentCategoryFromJson(json);
}
