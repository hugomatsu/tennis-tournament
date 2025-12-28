// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Participant _$ParticipantFromJson(Map<String, dynamic> json) => _Participant(
  id: json['id'] as String,
  name: json['name'] as String,
  categoryId: json['categoryId'] as String,
  userIds:
      (json['userIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  avatarUrls:
      (json['avatarUrls'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList() ??
      const [],
  status: json['status'] as String? ?? 'pending',
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$ParticipantToJson(_Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'categoryId': instance.categoryId,
      'userIds': instance.userIds,
      'avatarUrls': instance.avatarUrls,
      'status': instance.status,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
