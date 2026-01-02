import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class PlayerProfileScreen extends ConsumerWidget {
  final String playerId;

  const PlayerProfileScreen({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final allPlayersAsync = ref.watch(allPlayersProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.playerProfile),
      ),
      body: allPlayersAsync.when(
        data: (players) {
          final player = players.firstWhere(
            (p) => p.id == playerId,
            orElse: () => const Player(
              id: 'unknown',
              name: 'Unknown Player',
              avatarUrl: '',
              userType: 'player',
              title: 'N/A',
              category: 'N/A',
              playingSince: 'N/A',
              wins: 0,
              losses: 0,
              rank: 0,
              bio: '',
            ),
          );

          if (player.id == 'unknown') {
            return Center(child: Text(loc.playerNotFound));
          }

          final currentUser = currentUserAsync.value;
          final isMe = currentUser?.id == player.id;
          final isFollowing = currentUser?.following.contains(player.id) ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                  foregroundImage: player.avatarUrl.isNotEmpty ? NetworkImage(player.avatarUrl) : null,
                ),
                const SizedBox(height: 16),
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  player.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (!isMe && currentUser != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (isFollowing) {
                          await ref.read(playerControllerProvider).unfollowUser(player.id);
                        } else {
                          await ref.read(playerControllerProvider).followUser(player.id);
                        }
                      },
                      icon: Icon(isFollowing ? Icons.check : Icons.person_add),
                      label: Text(isFollowing ? loc.following : loc.follow),
                      style: isFollowing 
                          ? FilledButton.styleFrom(backgroundColor: Colors.grey)
                          : null,
                    ),
                  ),
                const SizedBox(height: 32),
                _StatRow(label: loc.category, value: player.category),
                _StatRow(label: loc.rank, value: '#${player.rank}'),
                _StatRow(label: loc.wins, value: '${player.wins}'),
                _StatRow(label: loc.losses, value: '${player.losses}'),
                const SizedBox(height: 24),
                if (player.bio.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loc.bio,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(player.bio),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(loc.errorOccurred(e.toString()))),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
