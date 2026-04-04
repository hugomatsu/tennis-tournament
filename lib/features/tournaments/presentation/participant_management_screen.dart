import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:tennis_tournament/features/tournaments/application/tournament_providers.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournament_detail_screen.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class ParticipantManagementScreen extends ConsumerWidget {
  final String tournamentId;

  const ParticipantManagementScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantsProvider(tournamentId));
    final tournamentAsync = ref.watch(tournamentDetailProvider(tournamentId));
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.managePlayers),
      ),
      body: tournamentAsync.when(
        data: (tournament) {
          if (tournament == null) {
            return Center(child: Text(loc.tournamentNotFound));
          }
          
          // Check if tournament is in progress or completed
          final isLocked = tournament.status == 'In Progress' || tournament.status == 'Completed';
          
          return participantsAsync.when(
            data: (participants) {
              final pending = participants.where((p) => p.status == 'pending').toList();
              final approved = participants.where((p) => p.status == 'approved').toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Show warning if locked
                  if (isLocked)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tournament.status == 'In Progress' 
                                  ? loc.tournamentInProgress 
                                  : loc.tournamentCompleted,
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          isLocked: isLocked,
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
                        isLocked: isLocked,
                      )),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text(loc.errorOccurred(err.toString()))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(loc.errorOccurred(err.toString()))),
      ),
      floatingActionButton: tournamentAsync.when(
        data: (tournament) {
          if (tournament == null) return null;
          final isLocked = tournament.status == 'In Progress' || tournament.status == 'Completed';
          if (isLocked) return null; // Hide FAB if locked
          return FloatingActionButton(
            onPressed: () => _showAddOptions(context, ref),
            child: const Icon(Icons.add),
          );
        },
        loading: () => null,
        error: (_, __) => null,
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
            title: Text(AppLocalizations.of(context)!.addExistingUsers),
            subtitle: Text(AppLocalizations.of(context)!.selectFromRegisteredUsers),
            onTap: () {
              Navigator.pop(context);
              _showAddExistingUsersDialog(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(AppLocalizations.of(context)!.addManualEntry),
            subtitle: Text(AppLocalizations.of(context)!.forGuestsOrNonAppUsers),
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
      title: Text(AppLocalizations.of(context)!.addParticipants),
      content: SizedBox(
        width: double.maxFinite,
        child: categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) return Text(AppLocalizations.of(context)!.noCategoriesCreateFirst);
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.selectCategoriesColon, style: Theme.of(context).textTheme.bodyMedium),
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
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.searchUsers,
                    prefixIcon: const Icon(Icons.search),
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
                        return Center(child: Text(AppLocalizations.of(context)!.noUsersFound));
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
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: _selectedUserIds.isEmpty || _selectedCategoryIds.isEmpty ? null : _submit,
          child: Text(AppLocalizations.of(context)!.addCount(_selectedUserIds.length)),
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
           scaffoldMessenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.addedParticipants(addedCount))));
        } else {
           scaffoldMessenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.alreadyInCategories)));
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
  final bool isLocked;

  const _ParticipantTile({
    required this.participant,
    required this.tournamentId,
    required this.isPending,
    this.isLocked = false,
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
        trailing: isLocked 
            ? null // Hide actions when locked
            : Row(
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
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Strips leading/trailing junk characters, collapses inner whitespace,
  /// and title-cases each word. Returns empty string if nothing valid remains.
  String _formatName(String raw) {
    // Strip leading/trailing special characters and whitespace
    final stripped = raw.replaceAll(RegExp(r'^[\s\-*><+=]+|[\s\-*><+=]+$'), '');
    // Collapse any inner whitespace runs to a single space
    final normalized = stripped.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return '';
    // Title case: first letter of every word uppercased, rest lowercased
    return normalized
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  List<String> _parseNames(String input) {
    return input
        .split('\n')
        .map(_formatName)
        .where((n) => n.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(tournamentRepositoryProvider).getCategories(widget.tournamentId);
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.addParticipants),
      content: FutureBuilder(
        future: categoriesAsync,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final categories = snapshot.data!;
          if (categories.isEmpty) return Text(loc.noCategoriesFound);

          final sortedCategories = [...categories]..sort((a, b) => a.name.compareTo(b.name));

          if (_selectedCategoryId == null && sortedCategories.isNotEmpty) {
            _selectedCategoryId = sortedCategories.first.id;
          }

          return SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: loc.name,
                    hintText: loc.participantNamesHint,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                  minLines: 4,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(labelText: loc.category),
                  items: sortedCategories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  )).toList(),
                  onChanged: _isLoading ? null : (value) => setState(() => _selectedCategoryId = value),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(loc.add),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_selectedCategoryId == null) return;

    final names = _parseNames(_nameController.text);
    if (names.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(tournamentRepositoryProvider);
      for (final name in names) {
        await repo.addParticipant(
          widget.tournamentId,
          Participant(
            id: _uuid.v4(),
            name: name,
            userIds: [],
            categoryId: _selectedCategoryId!,
            status: 'approved',
            joinedAt: DateTime.now(),
            avatarUrls: [],
          ),
        );
      }

      ref.invalidate(participantsProvider(widget.tournamentId));

      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.participantsAddedCount(names.length))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
