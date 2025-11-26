import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/auth/data/auth_repository.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';

final currentUserProvider = FutureProvider<Player?>((ref) {
  // Invalidate provider when auth state changes to force refresh
  ref.watch(authStateChangesProvider);
  return ref.watch(playerRepositoryProvider).getCurrentUser();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Profile not found'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push('/profile/edit'),
                    child: const Text('Create Profile'),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                  foregroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                  onForegroundImageError: user.avatarUrl.isNotEmpty ? (_, __) {} : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  user.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(label: 'Wins', value: user.wins.toString()),
                    _StatItem(label: 'Losses', value: user.losses.toString()),
                    _StatItem(label: 'Rank', value: '#${user.rank}'),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.bio,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      _ProfileRow(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: user.category,
                      ),
                      const Divider(height: 24),
                      _ProfileRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Playing Since',
                        value: user.playingSince,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.push('/profile/edit'),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                        if (user.userType == 'admin') ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () => context.push('/admin'),
                              child: const Text('Admin Dashboard'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Text(label),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
