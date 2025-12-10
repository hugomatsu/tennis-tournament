import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_asset.freezed.dart';
part 'media_asset.g.dart';

@freezed
abstract class MediaAsset with _$MediaAsset {
  const factory MediaAsset({
    required String id,
    required String url,
    required String path,
    required int size,
    required DateTime uploadedAt,
    required String userId,
    String? fileName,
    String? contentType,
  }) = _MediaAsset;

  factory MediaAsset.fromJson(Map<String, dynamic> json) =>
      _$MediaAssetFromJson(json);
}
