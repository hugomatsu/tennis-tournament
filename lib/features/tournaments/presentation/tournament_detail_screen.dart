import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:tennis_tournament/features/matches/data/match_repository.dart';

import 'package:tennis_tournament/features/players/domain/player.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/tournaments/application/single_elimination_service.dart';
import 'package:tennis_tournament/features/tournaments/application/tournament_providers.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/bracket_view.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';

final tournamentDetailProvider = FutureProvider.family<Tournament?, String>((ref, id) {
  return ref.watch(tournamentRepositoryProvider).getTournament(id);
});

class TournamentDetailScreen extends ConsumerWidget {
  final String id;

  const TournamentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(tournamentDetailProvider(id));
    final userAsync = ref.watch(currentUserProvider);

    return tournamentAsync.when(
      data: (tournament) {
        if (tournament == null) {
          return const Scaffold(body: Center(child: Text('Tournament not found')));
        }
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                        onPressed: () {
                          ref.invalidate(tournamentDetailProvider(id));
                          ref.invalidate(tournamentCategoriesProvider(id));
                        },
                      ),
                      if (userAsync.asData?.value?.userType == 'admin') ...[
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit Tournament',
                          onPressed: () {
                            _showEditTournamentDialog(context, ref, tournament);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.category),
                          tooltip: 'Manage Categories',
                          onPressed: () {
                            _showManageCategoriesDialog(context, ref, tournament.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep),
                          tooltip: 'Delete Bracket',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Bracket?'),
                                content: const Text('This will delete all generated matches for this tournament. This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              try {
                                await ref.read(matchRepositoryProvider).deleteMatchesForTournament(tournament.id);
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Bracket deleted successfully')),
                                );
                              } catch (e) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(content: Text('Error deleting bracket: $e')),
                                );
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.shuffle),
                          tooltip: 'Generate Bracket',
                          onPressed: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            
                            // 1. Fetch participants and categories
                            final participants = await ref
                                .read(tournamentRepositoryProvider)
                                .getParticipants(tournament.id);
                            
                            final categories = await ref
                                .read(tournamentRepositoryProvider)
                                .getCategories(tournament.id);

                            if (categories.isEmpty) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text('No categories found to generate bracket')),
                              );
                              return;
                            }

                            // Filter only approved participants
                            final approvedParticipants = participants
                                .where((p) => p.status == 'approved')
                                .toList();

                            // Ask for generation method
                            if (!context.mounted) return;
                            final method = await showDialog<String>(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text('Generation Method'),
                                children: [
                                  SimpleDialogOption(
                                    onPressed: () => Navigator.pop(context, 'automatic'),
                                    child: const ListTile(
                                      leading: Icon(Icons.auto_fix_high),
                                      title: Text('Automatic'),
                                      subtitle: Text('Randomly shuffle players'),
                                    ),
                                  ),
                                  SimpleDialogOption(
                                    onPressed: () => Navigator.pop(context, 'manual'),
                                    child: const ListTile(
                                      leading: Icon(Icons.drag_handle),
                                      title: Text('Manual'),
                                      subtitle: Text('Reorder players manually'),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (method == null) return;

                            final allMatches = <TennisMatch>[];
                            int generatedCount = 0;

                            try {
                              // 2. Generate matches for each category
                              for (final category in categories) {
                                var categoryParticipants = approvedParticipants
                                    .where((p) => p.categoryId == category.id)
                                    .toList();
                                
                                if (categoryParticipants.length < 2) {
                                  continue;
                                }

                                if (method == 'manual') {
                                  if (!context.mounted) return;
                                  // Show reordering dialog for this category
                                  final reordered = await showDialog<List<Participant>>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => _ManualBracketOrderingDialog(
                                      categoryName: category.name,
                                      participants: categoryParticipants,
                                    ),
                                  );

                                  if (reordered == null) {
                                    // User cancelled manual ordering for this category
                                    // We can either skip or abort. Let's abort to be safe.
                                    return;
                                  }
                                  categoryParticipants = reordered;
                                }

                                final matches = await ref
                                    .read(schedulingServiceProvider)
                                    .generateBracket(
                                      tournament, 
                                      categoryParticipants,
                                      shuffle: method == 'automatic', // Only shuffle if automatic
                                    );
                                
                                allMatches.addAll(matches);
                                generatedCount += matches.length;
                              }

                              if (allMatches.isEmpty) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Not enough approved participants in any category')),
                                );
                                return;
                              }

                              // 3. Save matches
                              await ref.read(matchRepositoryProvider).createMatches(allMatches);

                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Generated $generatedCount matches across ${categories.length} categories!')),
                              );
                            } catch (e) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.people),
                          tooltip: 'Manage Players',
                          onPressed: () {
                            context.go('/tournaments/${tournament.id}/participants');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete Tournament',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Tournament?'),
                                content: const Text('This will delete all matches, participants, and categories. This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              try {
                                await ref.read(tournamentRepositoryProvider).deleteTournament(tournament.id);
                                if (context.mounted) {
                                  context.pop(); // Go back to list
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error deleting: $e')),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(tournament.name),
                      background: tournament.imageUrl.isNotEmpty
                          ? Image.network(
                              tournament.imageUrl,
                              fit: BoxFit.cover,
                              color: Colors.black.withValues(alpha: 0.4),
                              colorBlendMode: BlendMode.darken,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/tournament_placeholder.png',
                                  fit: BoxFit.cover,
                                  color: Colors.black.withValues(alpha: 0.4),
                                  colorBlendMode: BlendMode.darken,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/tournament_placeholder.png',
                              fit: BoxFit.cover,
                              color: Colors.black.withValues(alpha: 0.4),
                              colorBlendMode: BlendMode.darken,
                            ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        tabs: [
                          Tab(text: 'Info'),
                          Tab(text: 'Bracket'),
                          Tab(text: 'Standings'),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _InfoTab(tournament: tournament),
                  BracketView(tournament: tournament),
                  const Center(child: Text('Standings Placeholder')),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  void _showEditTournamentDialog(BuildContext context, WidgetRef ref, Tournament tournament) {
    final nameController = TextEditingController(text: tournament.name);
    final descController = TextEditingController(text: tournament.description);
    final locationController = TextEditingController(text: tournament.location);
    final dateController = TextEditingController(text: tournament.dateRange);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tournament'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date Range'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final updated = tournament.copyWith(
                name: nameController.text,
                description: descController.text,
                location: locationController.text,
                dateRange: dateController.text,
              );
              await ref.read(tournamentRepositoryProvider).updateTournament(updated);
              ref.invalidate(tournamentDetailProvider(tournament.id));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showManageCategoriesDialog(BuildContext context, WidgetRef ref, String tournamentId) {
    showDialog(
      context: context,
      builder: (context) => _ManageCategoriesDialog(tournamentId: tournamentId),
    );
  }
}

class _ManageCategoriesDialog extends ConsumerStatefulWidget {
  final String tournamentId;

  const _ManageCategoriesDialog({required this.tournamentId});

  @override
  ConsumerState<_ManageCategoriesDialog> createState() => _ManageCategoriesDialogState();
}

class _ManageCategoriesDialogState extends ConsumerState<_ManageCategoriesDialog> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(tournamentCategoriesProvider(widget.tournamentId));

    return AlertDialog(
      title: const Text('Manage Categories'),
      content: SizedBox(
        width: double.maxFinite,
        child: categoriesAsync.when(
          data: (categories) {
            return ListView(
              shrinkWrap: true,
              children: [
                ...categories.map((category) => ListTile(
                  title: Text(category.name),
                  subtitle: Text('${category.type} - ${category.description}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditCategoryDialog(category),
                  ),
                )),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add New Category'),
                  onTap: () => _showAddCategoryDialog(),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
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

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String type = 'singles';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name (e.g. Men\'s A)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'singles', child: Text('Singles')),
                    DropdownMenuItem(value: 'doubles', child: Text('Doubles')),
                  ],
                  onChanged: (val) => setState(() => type = val!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  final category = TournamentCategory(
                    id: const Uuid().v4(),
                    tournamentId: widget.tournamentId,
                    name: nameController.text,
                    type: type,
                    description: descController.text,
                  );
                  await ref.read(tournamentRepositoryProvider).addCategory(category);
                  ref.invalidate(tournamentCategoriesProvider(widget.tournamentId));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditCategoryDialog(TournamentCategory category) {
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(text: category.description);
    String type = category.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'singles', child: Text('Singles')),
                    DropdownMenuItem(value: 'doubles', child: Text('Doubles')),
                  ],
                  onChanged: (val) => setState(() => type = val!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  final updated = category.copyWith(
                    name: nameController.text,
                    type: type,
                    description: descController.text,
                  );
                  await ref.read(tournamentRepositoryProvider).updateCategory(updated);
                  ref.invalidate(tournamentCategoriesProvider(widget.tournamentId));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTab extends ConsumerWidget {
  final Tournament tournament;

  const _InfoTab({required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final participantsAsync = ref.watch(participantsProvider(tournament.id));
    final categoriesAsync = ref.watch(tournamentCategoriesProvider(tournament.id));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(tournament.description),
        const SizedBox(height: 24),
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.calendar_today, text: tournament.dateRange),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.location_on, text: tournament.location),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.people, text: '${tournament.playersCount} Players'),
        const SizedBox(height: 32),
        Text(
          'Participants',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        participantsAsync.when(
          data: (participants) {
            if (participants.isEmpty) return const Text('No participants yet.');
            
            return categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) return const Text('No categories found.');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.map((category) {
                    final categoryParticipants = participants
                        .where((p) => p.categoryId == category.id)
                        .toList();
                    
                    if (categoryParticipants.isEmpty) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (category.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                              child: Text(
                                category.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          const SizedBox(height: 8),
                          ...categoryParticipants.asMap().entries.map((entry) {
                            final index = entry.key;
                            final participant = entry.value;
                            final isCurrentUser = participant.userId == userAsync.asData?.value?.id;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      '${index + 1}.',
                                      style: TextStyle(
                                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                        color: isCurrentUser ? Theme.of(context).colorScheme.primary : null,
                                      ),
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundImage: participant.avatarUrl != null 
                                        ? NetworkImage(participant.avatarUrl!) 
                                        : null,
                                    child: participant.avatarUrl == null 
                                        ? Text(participant.name[0].toUpperCase(), style: const TextStyle(fontSize: 10)) 
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      participant.name,
                                      style: TextStyle(
                                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                        color: isCurrentUser ? Theme.of(context).colorScheme.primary : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox(height: 20, child: LinearProgressIndicator()),
              error: (e, s) => Text('Error loading categories: $e'),
            );
          },
          loading: () => const SizedBox(height: 20, child: LinearProgressIndicator()),
          error: (e, s) => const Text('Error loading participants'),
        ),
        const SizedBox(height: 32),
        _JoinTournamentButton(
          tournament: tournament,
          currentUser: userAsync.asData?.value,
        ),
      ],
    );
  }
}

class _JoinTournamentButton extends ConsumerStatefulWidget {
  final Tournament tournament;
  final Player? currentUser;

  const _JoinTournamentButton({
    required this.tournament,
    required this.currentUser,
  });

  @override
  ConsumerState<_JoinTournamentButton> createState() => _JoinTournamentButtonState();
}

class _JoinTournamentButtonState extends ConsumerState<_JoinTournamentButton> {
  bool _isLoading = false;
  List<String> _joinedCategoryIds = [];

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  @override
  void didUpdateWidget(_JoinTournamentButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUser != widget.currentUser) {
      _checkRegistration();
    }
  }

  Future<void> _checkRegistration() async {
    if (widget.currentUser == null) {
      if (mounted) setState(() => _joinedCategoryIds = []);
      return;
    }

    final participants = await ref
        .read(tournamentRepositoryProvider)
        .getParticipantsForUser(widget.tournament.id, widget.currentUser!.id);
    
    if (mounted) {
      setState(() => _joinedCategoryIds = participants.map((p) => p.categoryId).toList());
    }
  }

  Future<void> _showCategorySelectionDialog() async {
    if (widget.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to join')),
      );
      return;
    }

    final categories = await ref.read(tournamentRepositoryProvider).getCategories(widget.tournament.id);
    
    if (categories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No categories available to join.')),
        );
      }
      return;
    }

    // Local state for the dialog
    final selectedCategories = Set<String>.from(_joinedCategoryIds);
    final isEditing = _joinedCategoryIds.isNotEmpty;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Participation' : 'Select Categories'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: categories.map((category) {
                  return CheckboxListTile(
                    title: Text(category.name),
                    subtitle: Text(category.type),
                    value: selectedCategories.contains(category.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedCategories.add(category.id);
                        } else {
                          selectedCategories.remove(category.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              if (isEditing)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Leave Tournament?'),
                        content: const Text('Are you sure you want to leave the tournament completely? This will remove you from all categories.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Leave'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      Navigator.pop(context); // Close selection dialog
                      _handleLeaveTournament();
                    }
                  },
                  child: const Text('Leave Participation'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleUpdateParticipation(selectedCategories);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleUpdateParticipation(Set<String> selectedCategories) async {
    setState(() => _isLoading = true);
    final userId = widget.currentUser!.id;
    final tournamentId = widget.tournament.id;
    final repo = ref.read(tournamentRepositoryProvider);

    try {
      // Determine additions and removals
      final toAdd = selectedCategories.difference(_joinedCategoryIds.toSet());
      final toRemove = _joinedCategoryIds.toSet().difference(selectedCategories);

      // Execute changes
      for (final categoryId in toAdd) {
        await repo.joinTournament(tournamentId, userId, categoryId);
      }

      for (final categoryId in toRemove) {
        await repo.leaveTournament(tournamentId, userId, categoryId);
      }

      await _checkRegistration();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participation updated successfully')),
        );
        ref.invalidate(tournamentDetailProvider(tournamentId));
        ref.invalidate(participantsProvider(tournamentId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating participation: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLeaveTournament() async {
    setState(() => _isLoading = true);
    final userId = widget.currentUser!.id;
    final tournamentId = widget.tournament.id;
    final repo = ref.read(tournamentRepositoryProvider);

    try {
      for (final categoryId in _joinedCategoryIds) {
        await repo.leaveTournament(tournamentId, userId, categoryId);
      }

      await _checkRegistration();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have left the tournament')),
        );
        ref.invalidate(tournamentDetailProvider(tournamentId));
        ref.invalidate(participantsProvider(tournamentId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error leaving tournament: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isJoined = _joinedCategoryIds.isNotEmpty;
    final categoriesAsync = ref.watch(tournamentCategoriesProvider(widget.tournament.id));

    return SizedBox(
      width: double.infinity,
      child: categoriesAsync.when(
        data: (categories) {
          final isDisabled = categories.isEmpty;
          return FilledButton(
            onPressed: (_isLoading || isDisabled) ? null : _showCategorySelectionDialog,
            style: isJoined ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary) : null,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isDisabled 
                    ? 'No Categories Available' 
                    : (isJoined ? 'Edit Participation' : 'Join Tournament')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _ManualBracketOrderingDialog extends StatefulWidget {
  final String categoryName;
  final List<Participant> participants;

  const _ManualBracketOrderingDialog({
    required this.categoryName,
    required this.participants,
  });

  @override
  State<_ManualBracketOrderingDialog> createState() => _ManualBracketOrderingDialogState();
}

class _ManualBracketOrderingDialogState extends State<_ManualBracketOrderingDialog> {
  late List<Participant> _items;

  @override
  void initState() {
    super.initState();
    // Start with a random shuffle as requested
    _items = List.from(widget.participants)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Order Players - ${widget.categoryName}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Drag to reorder. Players are paired from top to bottom (1 vs 2, 3 vs 4, etc.)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _items.removeAt(oldIndex);
                    _items.insert(newIndex, item);
                  });
                },
                children: [
                  for (int i = 0; i < _items.length; i++)
                    ListTile(
                      key: ValueKey(_items[i].id),
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundImage: _items[i].avatarUrl != null 
                            ? NetworkImage(_items[i].avatarUrl!) 
                            : null,
                        child: _items[i].avatarUrl == null 
                            ? Text(_items[i].name[0].toUpperCase(), style: const TextStyle(fontSize: 10)) 
                            : null,
                      ),
                      title: Text(_items[i].name),
                      trailing: const Icon(Icons.drag_handle),
                      // Add visual separation for pairs
                      tileColor: (i ~/ 2) % 2 == 0 
                          ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                          : null,
                      shape: i % 2 == 1 
                          ? const Border(bottom: BorderSide(color: Colors.grey, width: 0.5))
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _items),
          child: const Text('Confirm Order'),
        ),
      ],
    );
  }
}
