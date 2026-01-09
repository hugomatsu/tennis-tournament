import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNavBar'));

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: loc.home,
          ),
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
                final userAsync = ref.watch(currentUserProvider); // Make sure to import currentUserProvider
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
        onDestinationSelected: _goBranch,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
