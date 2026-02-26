import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/notifications/application/notification_providers.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNavBar'));

  void _goBranch(int index, WidgetRef ref) {
    final isSameTab = index == navigationShell.currentIndex;
    
    // When clicking on the same tab, go to initial location (reset to root)
    // This behavior reloads the tab by forcing re-navigation to the initial route
    navigationShell.goBranch(
      index,
      initialLocation: isSameTab,
    );
    
    // For profile tab, also refresh user data when re-selecting
    if (isSameTab && index == 2) {
      ref.invalidate(currentUserProvider);
    }
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final unreadCount = unreadCountAsync.value ?? 0;

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          // Floating notification bell
          if (navigationShell.currentIndex == 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => context.push('/notifications'),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(fontSize: 10),
                      ),
                      child: Icon(
                        unreadCount > 0
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color: unreadCount > 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).iconTheme.color,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: loc.tournaments,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: loc.schedule,
          ),
          NavigationDestination( // Profile Tab
            icon: Consumer(
              builder: (context, ref, _) {
                final userAsync = ref.watch(currentUserProvider);
                final isPremium = userAsync.value?.isPremium ?? false;
                if (!isPremium) return const Icon(Icons.person_outline);
                
                return Stack(
                  children: [
                    const Icon(Icons.person_outline),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(Icons.workspace_premium, size: 12, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                );
              },
            ),
            selectedIcon: Consumer(
              builder: (context, ref, _) {
                final userAsync = ref.watch(currentUserProvider);
                final isPremium = userAsync.value?.isPremium ?? false;
                if (!isPremium) return const Icon(Icons.person);

                return Stack(
                  children: [
                    const Icon(Icons.person),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(Icons.workspace_premium, size: 12, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                );
              },
            ),
            label: loc.profile,
          ),
        ],
        onDestinationSelected: (index) => _goBranch(index, ref),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
