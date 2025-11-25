import 'package:freezed_annotation/freezed_annotation.dart';

part 'participant.freezed.dart';
part 'participant.g.dart';

@freezed
abstract class Participant with _$Participant {
  const factory Participant({
    required String id,
    required String name,
    String? userId, // Nullable for manual entries
    String? avatarUrl,
    @Default('pending') String status, // 'pending', 'approved', 'rejected'
    required DateTime joinedAt,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
}
