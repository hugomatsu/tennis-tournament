// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationSettings _$NotificationSettingsFromJson(
  Map<String, dynamic> json,
) => _NotificationSettings(
  matchScheduleChanges: json['matchScheduleChanges'] as bool? ?? true,
  matchResults: json['matchResults'] as bool? ?? true,
  followedUpdates: json['followedUpdates'] as bool? ?? true,
  generalAnnouncements: json['generalAnnouncements'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationSettingsToJson(
  _NotificationSettings instance,
) => <String, dynamic>{
  'matchScheduleChanges': instance.matchScheduleChanges,
  'matchResults': instance.matchResults,
  'followedUpdates': instance.followedUpdates,
  'generalAnnouncements': instance.generalAnnouncements,
};
