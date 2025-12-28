import 'package:freezed_annotation/freezed_annotation.dart';

part 'participant.freezed.dart';
part 'participant.g.dart';

@freezed
abstract class Participant with _$Participant {
  const factory Participant({
    required String id,
    required String name,
    required String categoryId,
    @Default([]) List<String> userIds, // Changed from userId
    @Default([]) List<String?> avatarUrls, // Changed from avatarUrl
    @Default('pending') String status, // 'pending', 'approved', 'rejected'
    required DateTime joinedAt,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
}
