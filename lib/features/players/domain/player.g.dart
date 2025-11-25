// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  name: json['name'] as String,
  title: json['title'] as String,
  category: json['category'] as String,
  playingSince: json['playingSince'] as String,
  wins: (json['wins'] as num).toInt(),
  losses: (json['losses'] as num).toInt(),
  rank: (json['rank'] as num).toInt(),
  bio: json['bio'] as String,
  avatarUrl: json['avatarUrl'] as String,
  userType: json['userType'] as String? ?? 'player',
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'title': instance.title,
  'category': instance.category,
  'playingSince': instance.playingSince,
  'wins': instance.wins,
  'losses': instance.losses,
  'rank': instance.rank,
  'bio': instance.bio,
  'avatarUrl': instance.avatarUrl,
  'userType': instance.userType,
};
