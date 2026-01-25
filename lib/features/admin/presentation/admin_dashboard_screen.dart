import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';

import 'package:tennis_tournament/l10n/app_localizations.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.adminDashboard),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null || user.userType != 'admin') {
            return Center(child: Text(loc.accessDenied));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AdminCard(
                title: loc.createTournament,
                icon: Icons.add_circle,
                onTap: () => context.push('/admin/create-tournament'),
              ),
              const SizedBox(height: 16),
              _AdminCard(
                title: loc.managePlayers,
                icon: Icons.people,
                onTap: () {
                  // TODO: Implement player management
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.comingSoon)),
                  );
                },
              ),
              const SizedBox(height: 16),
              _AdminCard(
                title: loc.manageLocations,
                icon: Icons.stadium,
                onTap: () => context.push('/admin/locations'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(loc.errorOccurred(err.toString()))),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
