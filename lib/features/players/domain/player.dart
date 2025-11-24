
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
abstract class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    required String title,
    required String category,
    required String playingSince,
    required int wins,
    required int losses,
    required int rank,
    required String bio,
    required String avatarUrl,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
