import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/app.dart';
import 'package:tennis_tournament/features/notifications/application/notification_service.dart';
import 'package:tennis_tournament/features/notifications/data/notification_repository.dart';
import 'package:tennis_tournament/features/notifications/domain/app_notification.dart';
import 'package:tennis_tournament/features/notifications/domain/notification_settings.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';

final notificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value([]);

  return ref.watch(notificationRepositoryProvider).watchNotifications(user.id);
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value(0);

  return ref.watch(notificationRepositoryProvider).getUnreadCount(user.id);
});

final notificationSettingsProvider = FutureProvider<NotificationSettings>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return const NotificationSettings();

  return ref.watch(notificationRepositoryProvider).getNotificationSettings(user.id);
});

/// Initializes FCM: requests permission, saves device token, and listens for messages.
/// Eagerly watched in [TennisApp] so it activates once the user is authenticated.
final notificationServiceProvider = FutureProvider<void>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return; // Not logged in yet

  final repository = ref.read(notificationRepositoryProvider);
  final router = ref.read(routerProvider);

  final service = NotificationService(
    repository: repository,
    userId: user.id,
    router: router,
  );

  try {
    await service.initialize();
    debugPrint('NotificationService initialized for user ${user.id}');
  } catch (e) {
    debugPrint('Error initializing NotificationService: $e');
  }
});
