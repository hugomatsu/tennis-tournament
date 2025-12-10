import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tennis_tournament/features/media/data/media_repository.dart';
import 'package:tennis_tournament/features/media/domain/media_asset.dart';
import 'package:uuid/uuid.dart';

class FirestoreMediaRepository implements MediaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  @override
  Future<MediaAsset> uploadImage(File file, String userId) async {
    final bytes = await file.readAsBytes();
    final fileName = '${_uuid.v4()}.jpg'; // Assuming jpg for simplicity or extract from path
    return uploadImageBytes(bytes, fileName, userId);
  }

  @override
  Future<MediaAsset> uploadImageBytes(Uint8List bytes, String fileName, String userId) async {
    final mediaId = _uuid.v4();
    final path = 'users/$userId/media/$fileName';
    final ref = _storage.ref().child(path);
    
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'userId': userId, 'mediaId': mediaId},
    );

    try {
    final uploadTask = await ref.putData(bytes, metadata);
    final url = await uploadTask.ref.getDownloadURL();
    final size = uploadTask.totalBytes;

    final asset = MediaAsset(
      id: mediaId,
      url: url,
      path: path,
      size: size,
      uploadedAt: DateTime.now(),
      userId: userId,
      fileName: fileName,
      contentType: 'image/jpeg',
    );

    await _firestore.collection('media').doc(mediaId).set(asset.toJson());

    return asset;
    } catch (e) {
      print('Error uploading to storage path: $path');
      print('Exception: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    final doc = await _firestore.collection('media').doc(mediaId).get();
    if (!doc.exists) return;

    final asset = MediaAsset.fromJson(doc.data()!);
    
    // Delete from Storage
    await _storage.ref().child(asset.path).delete();
    
    // Delete from Firestore
    await _firestore.collection('media').doc(mediaId).delete();
  }

  @override
  Future<List<MediaAsset>> getUserMedia(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('media')
          .where('userId', isEqualTo: userId)
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => MediaAsset.fromJson(doc.data())).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        print('Error: Missing Firestore Index. Please create an index for collection "media" with fields: userId (Ascending), uploadedAt (Descending).');
        print('Error Details: ${e.message}');
      } else {
        print('Error getting user media: $e');
      }
      rethrow;
    } catch (e) {
      print('Error getting user media: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUserStorageUsage(String userId) async {
    final snapshot = await _firestore
        .collection('media')
        .where('userId', isEqualTo: userId)
        .get();

    int totalSize = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      totalSize += (data['size'] as int? ?? 0);
    }
    return totalSize;
  }
}
