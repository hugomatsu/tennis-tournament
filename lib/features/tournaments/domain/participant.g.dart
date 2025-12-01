// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Participant _$ParticipantFromJson(Map<String, dynamic> json) => _Participant(
  id: json['id'] as String,
  name: json['name'] as String,
  categoryId: json['categoryId'] as String,
  userId: json['userId'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  status: json['status'] as String? ?? 'pending',
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$ParticipantToJson(_Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'categoryId': instance.categoryId,
      'userId': instance.userId,
      'avatarUrl': instance.avatarUrl,
      'status': instance.status,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
