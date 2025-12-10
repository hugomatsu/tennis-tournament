import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null || user.userType != 'admin') {
            return const Center(child: Text('Access Denied'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AdminCard(
                title: 'Create Tournament',
                icon: Icons.add_circle,
                onTap: () => context.push('/admin/create-tournament'),
              ),
              const SizedBox(height: 16),
              _AdminCard(
                title: 'Manage Players',
                icon: Icons.people,
                onTap: () {
                  // TODO: Implement player management
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming Soon')),
                  );
                },
              ),
              const SizedBox(height: 16),
              _AdminCard(
                title: 'Manage Locations',
                icon: Icons.stadium,
                onTap: () => context.push('/admin/locations'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
