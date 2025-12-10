// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaAsset _$MediaAssetFromJson(Map<String, dynamic> json) => _MediaAsset(
  id: json['id'] as String,
  url: json['url'] as String,
  path: json['path'] as String,
  size: (json['size'] as num).toInt(),
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
  userId: json['userId'] as String,
  fileName: json['fileName'] as String?,
  contentType: json['contentType'] as String?,
);

Map<String, dynamic> _$MediaAssetToJson(_MediaAsset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'path': instance.path,
      'size': instance.size,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'userId': instance.userId,
      'fileName': instance.fileName,
      'contentType': instance.contentType,
    };
