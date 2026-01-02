import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/auth/data/auth_repository.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/players/presentation/widgets/user_search_dialog.dart';



class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profile),
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
                  Text(loc.profileNotFound),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push('/profile/edit'),
                    child: Text(loc.createProfile),
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
                    _StatItem(label: loc.wins, value: user.wins.toString()),
                    _StatItem(label: loc.losses, value: user.losses.toString()),
                    _StatItem(label: loc.rank, value: '#${user.rank}'),
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
                        loc.about,
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
                        label: loc.category,
                        value: user.category,
                      ),
                      const Divider(height: 24),
                      _ProfileRow(
                        icon: Icons.calendar_today_outlined,
                        label: loc.playingSince,
                        value: user.playingSince,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Friends Section
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
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.following,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_search),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const UserSearchDialog(),
                              );
                            },
                            tooltip: loc.findPlayers,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, _) {
                           final friendsAsync = ref.watch(friendsProvider);
                           return friendsAsync.when(
                             data: (friends) {
                               if (friends.isEmpty) return Text(loc.notFollowingAnyone);
                               
                               return SizedBox(
                                 height: 90,
                                 child: ListView.separated(
                                   scrollDirection: Axis.horizontal,
                                   itemCount: friends.length,
                                   separatorBuilder: (_, __) => const SizedBox(width: 12),
                                   itemBuilder: (context, index) {
                                     final friend = friends[index];
                                     return Column(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                                            foregroundImage: friend.avatarUrl.isNotEmpty ? NetworkImage(friend.avatarUrl) : null,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            friend.name.split(' ').first,
                                            style: const TextStyle(fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                       ],
                                     );
                                   },
                                 ),
                               );
                             },
                             loading: () => const LinearProgressIndicator(),
                             error: (e,s) => Text('Error: $e'), 
                           );
                        },
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
                            child: Text(loc.editProfile),
                          ),
                        ),
                        if (user.userType == 'admin') ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () => context.push('/admin'),
                              child: Text(loc.adminDashboard),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/admin/simulation'),
                              icon: const Icon(Icons.bug_report),
                              label: Text(loc.simulationDebug),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/media-library'),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('My Media Library'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(loc.errorOccurred(err.toString()))),
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
