import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/core/config/feature_flags.dart';
import 'package:tennis_tournament/features/notifications/data/firestore_notification_repository.dart';
import 'package:tennis_tournament/features/notifications/domain/app_notification.dart';
import 'package:tennis_tournament/features/notifications/domain/notification_settings.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  if (FeatureFlags.enableMockUi) {
    // For now, return Firestore even in mock mode (no mock needed yet)
    return FirestoreNotificationRepository();
  }
  return FirestoreNotificationRepository();
});

abstract class NotificationRepository {
  Stream<List<AppNotification>> watchNotifications(String userId);
  Stream<int> getUnreadCount(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<NotificationSettings> getNotificationSettings(String userId);
  Future<void> updateNotificationSettings(String userId, NotificationSettings settings);
  Future<void> saveFcmToken(String userId, String token);
  Future<void> removeFcmToken(String userId, String token);
}
