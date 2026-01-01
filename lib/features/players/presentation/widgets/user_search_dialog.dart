import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';

class UserSearchDialog extends ConsumerStatefulWidget {
  const UserSearchDialog({super.key});

  @override
  ConsumerState<UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends ConsumerState<UserSearchDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allPlayersAsync = ref.watch(allPlayersProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return AlertDialog(
      title: const Text('Find Players'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: allPlayersAsync.when(
                data: (players) {
                  final filtered = players.where((p) {
                    // Filter out current user
                    if (currentUserAsync.value?.id == p.id) return false;
                    
                    if (_searchQuery.isEmpty) return true;
                    return p.name.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No players found'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final player = filtered[index];
                      // Check if already following
                      final isFollowing = currentUserAsync.value?.following.contains(player.id) ?? false;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                          foregroundImage: player.avatarUrl.isNotEmpty ? NetworkImage(player.avatarUrl) : null,
                        ),
                        title: Text(player.name),
                        subtitle: Text(player.title),
                        trailing: isFollowing 
                            ? const Icon(Icons.check, size: 20, color: Colors.green)
                            : null,
                        onTap: () {
                          Navigator.pop(context); // Close dialog
                          context.push('/players/${player.id}'); // Navigate to profile
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
