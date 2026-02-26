import 'package:flutter_riverpod/flutter_riverpod.dart';
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
