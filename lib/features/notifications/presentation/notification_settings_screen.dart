import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/notifications/application/notification_providers.dart';
import 'package:tennis_tournament/features/notifications/data/notification_repository.dart';
import 'package:tennis_tournament/features/notifications/domain/notification_settings.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  NotificationSettings _settings = const NotificationSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    final settings = await ref
        .read(notificationRepositoryProvider)
        .getNotificationSettings(user.id);

    if (mounted) {
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings(NotificationSettings newSettings) async {
    setState(() => _settings = newSettings);

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    await ref
        .read(notificationRepositoryProvider)
        .updateNotificationSettings(user.id, newSettings);

    ref.invalidate(notificationSettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.notificationSettings),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 8),
                _buildSection(
                  context,
                  title: loc.matchNotifications,
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.schedule),
                      title: Text(loc.matchScheduleChanges),
                      subtitle: Text(loc.matchScheduleChangesDesc),
                      value: _settings.matchScheduleChanges,
                      onChanged: (value) {
                        _saveSettings(
                          _settings.copyWith(matchScheduleChanges: value),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.emoji_events),
                      title: Text(loc.matchResultsNotif),
                      subtitle: Text(loc.matchResultsNotifDesc),
                      value: _settings.matchResults,
                      onChanged: (value) {
                        _saveSettings(
                          _settings.copyWith(matchResults: value),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: loc.socialNotifications,
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.people),
                      title: Text(loc.followedUpdatesNotif),
                      subtitle: Text(loc.followedUpdatesNotifDesc),
                      value: _settings.followedUpdates,
                      onChanged: (value) {
                        _saveSettings(
                          _settings.copyWith(followedUpdates: value),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: loc.otherNotifications,
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.campaign),
                      title: Text(loc.generalAnnouncementsNotif),
                      subtitle: Text(loc.generalAnnouncementsNotifDesc),
                      value: _settings.generalAnnouncements,
                      onChanged: (value) {
                        _saveSettings(
                          _settings.copyWith(generalAnnouncements: value),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
