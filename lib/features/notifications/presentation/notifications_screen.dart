import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/notifications/application/notification_providers.dart';
import 'package:tennis_tournament/features/notifications/data/notification_repository.dart';
import 'package:tennis_tournament/features/notifications/domain/app_notification.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: loc.markAllAsRead,
            onPressed: () async {
              final user = ref.read(currentUserProvider).value;
              if (user == null) return;
              await ref
                  .read(notificationRepositoryProvider)
                  .markAllAsRead(user.id);
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.noNotifications,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(notification: notification);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Text(loc.errorOccurred(e.toString())),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  IconData _iconForType(String type) {
    switch (type) {
      case 'result':
        return Icons.emoji_events;
      case 'dateChange':
        return Icons.schedule;
      case 'statusChange':
        return Icons.sync;
      case 'matchUpdate':
      default:
        return Icons.sports_tennis;
    }
  }

  Color _iconColorForType(String type, BuildContext context) {
    switch (type) {
      case 'result':
        return Colors.amber;
      case 'dateChange':
        return Colors.orange;
      case 'statusChange':
        return Theme.of(context).colorScheme.primary;
      case 'matchUpdate':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = !notification.isRead;

    return ListTile(
      tileColor: isUnread
          ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
          : null,
      leading: CircleAvatar(
        backgroundColor:
            _iconColorForType(notification.type, context).withOpacity(0.15),
        child: Icon(
          _iconForType(notification.type),
          color: _iconColorForType(notification.type, context),
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            timeago.format(notification.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
      trailing: isUnread
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: () async {
        // Mark as read
        if (!notification.isRead) {
          await ref
              .read(notificationRepositoryProvider)
              .markAsRead(notification.id);
        }

        // Navigate via deep link
        if (!context.mounted) return;
        if (notification.matchId != null && notification.matchId!.isNotEmpty) {
          context.push('/matches/${notification.matchId}');
        } else if (notification.tournamentId != null &&
            notification.tournamentId!.isNotEmpty) {
          context.push('/tournaments/${notification.tournamentId}');
        }
      },
    );
  }
}
