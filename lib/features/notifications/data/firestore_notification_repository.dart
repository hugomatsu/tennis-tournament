import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennis_tournament/features/notifications/data/notification_repository.dart';
import 'package:tennis_tournament/features/notifications/domain/app_notification.dart';
import 'package:tennis_tournament/features/notifications/domain/notification_settings.dart';

class FirestoreNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _notificationFromData(doc.id, data);
      }).toList();
    });
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<NotificationSettings> getNotificationSettings(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      if (data != null && data['notificationSettings'] != null) {
        return NotificationSettings.fromJson(
          Map<String, dynamic>.from(data['notificationSettings']),
        );
      }
    } catch (e) {
      // Return defaults on error
    }
    return const NotificationSettings();
  }

  @override
  Future<void> updateNotificationSettings(
    String userId,
    NotificationSettings settings,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'notificationSettings': settings.toJson(),
    });
  }

  @override
  Future<void> saveFcmToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  @override
  Future<void> removeFcmToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }

  AppNotification _notificationFromData(String id, Map<String, dynamic> data) {
    DateTime createdAt;
    final timeData = data['createdAt'];
    if (timeData is Timestamp) {
      createdAt = timeData.toDate();
    } else if (timeData is String) {
      createdAt = DateTime.tryParse(timeData) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return AppNotification(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'matchUpdate',
      matchId: data['matchId'] as String?,
      tournamentId: data['tournamentId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: createdAt,
    );
  }
}
