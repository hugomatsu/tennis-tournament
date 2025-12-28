import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:uuid/uuid.dart';

import 'package:tennis_tournament/features/tournaments/application/tournament_providers.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class ParticipantManagementScreen extends ConsumerWidget {
  final String tournamentId;

  const ParticipantManagementScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantsProvider(tournamentId));
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.managePlayers),
      ),
      body: participantsAsync.when(
        data: (participants) {
          final pending = participants.where((p) => p.status == 'pending').toList();
          final approved = participants.where((p) => p.status == 'approved').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                Text(
                  '${loc.pendingRequests} (${pending.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                ),
                const SizedBox(height: 8),
                ...pending.map((p) => _ParticipantTile(
                      participant: p,
                      tournamentId: tournamentId,
                      isPending: true,
                    )),
                const SizedBox(height: 24),
              ],
              Text(
                '${loc.approvedPlayers} (${approved.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
              ),
              const SizedBox(height: 8),
              if (approved.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(loc.noApprovedPlayers),
                ),
              ...approved.map((p) => _ParticipantTile(
                    participant: p,
                    tournamentId: tournamentId,
                    isPending: false,
                  )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Add Existing Users'),
            subtitle: const Text('Select from registered users'),
            onTap: () {
              Navigator.pop(context);
              _showAddExistingUsersDialog(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Add Manual Entry'),
            subtitle: const Text('For guests or non-app users'),
            onTap: () {
              Navigator.pop(context);
              _showAddParticipantDialog(context, ref);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAddExistingUsersDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddExistingUsersDialog(tournamentId: tournamentId),
    );
  }

  void _showAddParticipantDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddParticipantDialog(tournamentId: tournamentId),
    );
  }
}

class _AddExistingUsersDialog extends ConsumerStatefulWidget {
  final String tournamentId;

  const _AddExistingUsersDialog({required this.tournamentId});

  @override
  ConsumerState<_AddExistingUsersDialog> createState() => _AddExistingUsersDialogState();
}

class _AddExistingUsersDialogState extends ConsumerState<_AddExistingUsersDialog> {
  final Set<String> _selectedUserIds = {};
  final Set<String> _selectedCategoryIds = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(tournamentCategoriesProvider(widget.tournamentId));
    final allPlayersAsync = ref.watch(allPlayersProvider);
    final participantsAsync = ref.watch(participantsProvider(widget.tournamentId));
    
    return AlertDialog(
      title: const Text('Add Participants'),
      content: SizedBox(
        width: double.maxFinite,
        child: categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) return const Text('No categories found. Please create a category first.');
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Categories:', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((c) {
                    final isSelected = _selectedCategoryIds.contains(c.id);
                    return FilterChip(
                      label: Text(c.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategoryIds.add(c.id);
                          } else {
                            _selectedCategoryIds.remove(c.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Users',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: allPlayersAsync.when(
                    data: (players) {
                      final filteredPlayers = players.where((p) {
                         if (_searchQuery.isNotEmpty) {
                           return p.name.toLowerCase().contains(_searchQuery);
                         }
                         return true;
                      }).toList();

                      if (filteredPlayers.isEmpty) {
                        return const Center(child: Text('No users found.'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredPlayers.length,
                        itemBuilder: (context, index) {
                          final player = filteredPlayers[index];
                          final isSelected = _selectedUserIds.contains(player.id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedUserIds.add(player.id);
                                } else {
                                  _selectedUserIds.remove(player.id);
                                }
                              });
                            },
                            title: Text(player.name),
                            subtitle: Text(player.title),
                            secondary: CircleAvatar(
                              backgroundImage: NetworkImage(player.avatarUrl),
                              onBackgroundImageError: (_, __) {},
                              child: Text(player.name.isNotEmpty ? player.name[0] : '?'), 
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error loading players: $e'),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error: $e'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedUserIds.isEmpty || _selectedCategoryIds.isEmpty ? null : _submit,
          child: Text('Add (${_selectedUserIds.length})'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final players = await ref.read(allPlayersProvider.future);
      final participants = await ref.read(participantsProvider(widget.tournamentId).future);
      final repo = ref.read(tournamentRepositoryProvider);
      
      int addedCount = 0;
      final futures = <Future>[];

      for (final userId in _selectedUserIds) {
        final player = players.firstWhere((p) => p.id == userId);
        
        for (final catId in _selectedCategoryIds) {
            // _AddExistingUsersDialog _submit
            // Avoid duplicates: check if this user is already in this category
           final alreadyIn = participants.any((p) => p.userIds.contains(userId) && p.categoryId == catId);
           if (alreadyIn) continue;

           final participant = Participant(
             id: const Uuid().v4(),
             name: player.name,
             userIds: [player.id],
             categoryId: catId,
             status: 'approved',
             joinedAt: DateTime.now(),
             avatarUrls: [player.avatarUrl],
           );
           futures.add(repo.addParticipant(widget.tournamentId, participant));
           addedCount++;
        }
      }
      
      await Future.wait(futures);
      
      ref.invalidate(participantsProvider(widget.tournamentId));
      if (mounted) {
        Navigator.pop(context);
        if (addedCount > 0) {
           scaffoldMessenger.showSnackBar(SnackBar(content: Text('Added $addedCount participants')));
        } else {
           scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Selected participants are already in selected categories')));
        }
      }
    } catch (e) {
      if (mounted) {
         scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error adding participants: $e')));
      }
    }
  }
}

class _ParticipantTile extends ConsumerWidget {
  final Participant participant;
  final String tournamentId;
  final bool isPending;

  const _ParticipantTile({
    required this.participant,
    required this.tournamentId,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(tournamentRepositoryProvider).getCategories(tournamentId);
    final loc = AppLocalizations.of(context)!;
    
    // Simple display for now: Show first avatar or default
    final firstAvatar = participant.avatarUrls.isNotEmpty ? participant.avatarUrls.first : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: firstAvatar != null
              ? NetworkImage(firstAvatar)
              : null,
          child: firstAvatar == null
              ? Text(participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?')
              : null,
        ),
        title: Text(participant.name),
        subtitle: FutureBuilder(
          future: categoriesAsync,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('${loc.joined}: ${_formatDate(participant.joinedAt)}');
            final category = snapshot.data!.firstWhere(
              (c) => c.id == participant.categoryId,
              orElse: () => TournamentCategory(id: '', tournamentId: '', name: 'Unknown', type: ''),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${loc.category}: ${category.name}'),
                Text('${loc.joined}: ${_formatDate(participant.joinedAt)}'),
              ],
            );
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPending) ...[
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _updateStatus(ref, 'approved'),
                tooltip: loc.accept,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _updateStatus(ref, 'rejected'),
                tooltip: loc.deny,
              ),
            ] else
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () => _updateStatus(ref, 'rejected'), // Or delete
                tooltip: loc.remove,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(WidgetRef ref, String status) async {
    await ref.read(tournamentRepositoryProvider).updateParticipantStatus(
          tournamentId,
          participant.id,
          status,
        );
    ref.invalidate(participantsProvider(tournamentId));
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _AddParticipantDialog extends ConsumerStatefulWidget {
  final String tournamentId;

  const _AddParticipantDialog({required this.tournamentId});

  @override
  ConsumerState<_AddParticipantDialog> createState() => _AddParticipantDialogState();
}

class _AddParticipantDialogState extends ConsumerState<_AddParticipantDialog> {
  final _nameController = TextEditingController();
  final _uuid = const Uuid();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(tournamentRepositoryProvider).getCategories(widget.tournamentId);
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.addParticipant),
      content: FutureBuilder(
        future: categoriesAsync,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final categories = snapshot.data!;
          if (categories.isEmpty) return const Text('No categories found.');
          
          if (_selectedCategoryId == null && categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: loc.name,
                  hintText: 'e.g. Hugo or Hugo & Arthur',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(labelText: loc.category),
                items: categories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(loc.add),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedCategoryId == null) return;

    final participant = Participant(
      id: _uuid.v4(),
      name: name,
      userIds: [], // Manual entry, no user IDs
      categoryId: _selectedCategoryId!,
      status: 'approved', // Auto-approve manual entries
      joinedAt: DateTime.now(),
      avatarUrls: [],
    );

    await ref.read(tournamentRepositoryProvider).addParticipant(
          widget.tournamentId,
          participant,
        );
    
    ref.invalidate(participantsProvider(widget.tournamentId));
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
