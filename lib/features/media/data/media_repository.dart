import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/media/domain/media_asset.dart';
import 'package:tennis_tournament/features/media/data/firestore_media_repository.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return FirestoreMediaRepository();
});

abstract class MediaRepository {
  Future<MediaAsset> uploadImage(File file, String userId);
  Future<MediaAsset> uploadImageBytes(Uint8List bytes, String fileName, String userId);
  Future<void> deleteMedia(String mediaId);
  Future<List<MediaAsset>> getUserMedia(String userId);
  Future<int> getUserStorageUsage(String userId);
}
