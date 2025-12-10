import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

@freezed
abstract class TournamentLocation with _$TournamentLocation {
  const factory TournamentLocation({
    required String id,
    required String name,
    required String googleMapsUrl,
    required String description,
    required int numberOfCourts,
    String? imageUrl,
  }) = _TournamentLocation;

  factory TournamentLocation.fromJson(Map<String, dynamic> json) =>
      _$TournamentLocationFromJson(json);
}
