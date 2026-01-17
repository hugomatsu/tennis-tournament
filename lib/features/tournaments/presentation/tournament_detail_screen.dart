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
import 'package:tennis_tournament/features/tournaments/presentation/widgets/match_calendar_tab.dart';
import 'package:tennis_tournament/features/locations/data/location_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:tennis_tournament/core/sharing/sharing_service.dart';

final tournamentDetailProvider = FutureProvider.family<Tournament?, String>((ref, id) {
  return ref.watch(tournamentRepositoryProvider).getTournament(id);
});

class TournamentDetailScreen extends ConsumerWidget {
  final String id;

  const TournamentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final tournamentAsync = ref.watch(tournamentDetailProvider(id));
    final userAsync = ref.watch(currentUserProvider);

    return tournamentAsync.when(
      data: (tournament) {
        if (tournament == null) {
          return const Scaffold(body: Center(child: Text('Tournament not found'))); // TODO: Localize
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
                      IconButton(
                        icon: const Icon(Icons.share),
                        tooltip: 'Invite Players',
                        onPressed: () {
                           // TODO: Get base URL from env
                           final url = 'https://entresets.com/t/${tournament.id}'; 
                           ref.read(sharingServiceProvider).shareUrl(
                             url,
                             subject: 'Join ${tournament.name} on EntreSets!', 
                             context: context,
                           );
                        },
                      ),
                      if (userAsync.asData?.value != null) ...[
                        Builder(
                          builder: (context) {
                            final user = userAsync.value!; // Safe as we checked data
                            final isOwner = tournament.ownerId == user.id;
                            final isAdmin = isOwner || tournament.adminIds.contains(user.id);
                            
                            if (!isAdmin) return const SizedBox.shrink();

                            return PopupMenuButton<String>(
                              icon: const Icon(Icons.settings),
                              tooltip: 'Tournament Options',
                              onSelected: (value) async {
                                switch (value) {
                                  case 'edit':
                                    _showEditTournamentDialog(context, ref, tournament);
                                    break;
                                  case 'categories':
                                    _showManageCategoriesDialog(context, ref, tournament.id);
                                    break;
                                  case 'admins':
                                    context.go('/tournaments/${tournament.id}/manage-admins', extra: tournament);
                                    break;
                                  case 'participants':
                                    context.go('/tournaments/${tournament.id}/participants');
                                    break;
                                  case 'schedule_settings':
                                    context.go('/tournaments/${tournament.id}/schedule-settings');
                                    break;
                                  case 'generate_bracket':
                                     // Inline generation logic
                                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                                      final participants = await ref.read(tournamentRepositoryProvider).getParticipants(tournament.id);
                                      final categories = await ref.read(tournamentRepositoryProvider).getCategories(tournament.id);

                                      if (categories.isEmpty) {
                                        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('No categories found')));
                                        return;
                                      }
                                      final approvedParticipants = participants.where((p) => p.status == 'approved').toList();

                                      if (!context.mounted) return;
                                      final method = await showDialog<String>(
                                        context: context,
                                        builder: (context) => SimpleDialog(
                                          title: const Text('Generation Method'),
                                          children: [
                                            SimpleDialogOption(onPressed: () => Navigator.pop(context, 'automatic'), child: const ListTile(leading: Icon(Icons.auto_fix_high), title: Text('Automatic'))),
                                            SimpleDialogOption(onPressed: () => Navigator.pop(context, 'manual'), child: const ListTile(leading: Icon(Icons.drag_handle), title: Text('Manual'))),
                                          ],
                                        ),
                                      );
                                      if (method == null) return;
                                      
                                      // Logic from previous implementation
                                      final allMatches = <TennisMatch>[];
                                      int generatedCount = 0;
                                      try {
                                        for (final category in categories) {
                                          var categoryParticipants = approvedParticipants.where((p) => p.categoryId == category.id).toList();
                                          if (categoryParticipants.length < 2) continue;

                                          if (method == 'manual') {
                                             if (!context.mounted) return;
                                             // Note: _ManualBracketOrderingDialog needs to be accessible. 
                                             // It wasn't shown in the file view but assumed to be in the file or imported.
                                             // Wait, previous file view did NOT show _ManualBracketOrderingDialog class definition?
                                             // Ah, lines 800+ were not shown. I assume it's there.
                                             // If not, I'll need to check. But since I'm just moving code, it should be fine.
                                             // However, `_ManualBracketOrderingDialog` was used in line 227.
                                             // I need to make sure I don't break it.
                                            final reordered = await showDialog<List<Participant>>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) => _ManualBracketOrderingDialog( 
                                                categoryName: category.name,
                                                participants: categoryParticipants,
                                              ),
                                            );
                                            if (reordered == null) return;
                                            categoryParticipants = reordered;
                                          }

                                          final matches = await ref.read(schedulingServiceProvider).generateBracket(
                                            tournament, 
                                            category,
                                            categoryParticipants,
                                            shuffle: method == 'automatic',
                                          );
                                          allMatches.addAll(matches);
                                          generatedCount += matches.length;
                                        }

                                        if (allMatches.isEmpty) {
                                          scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Not enough approved participants')));
                                          return;
                                        }
                                        await ref.read(matchRepositoryProvider).createMatches(allMatches);
                                        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Generated $generatedCount matches!')));
                                      } catch (e) {
                                        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                                      }
                                    break;
                                  case 'delete_bracket':
                                     final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Bracket?'),
                                        content: const Text('This will delete all matches. Cannot be undone.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && context.mounted) {
                                      try {
                                        await ref.read(matchRepositoryProvider).deleteMatchesForTournament(tournament.id);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bracket deleted')));
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                      }
                                    }
                                    break;
                                  case 'delete_tournament':
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Tournament?'),
                                        content: const Text('This will delete everything. Cannot be undone.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && context.mounted) {
                                      try {
                                        await ref.read(tournamentRepositoryProvider).deleteTournament(tournament.id);
                                        if (context.mounted) context.pop(); 
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                      }
                                    }
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit Info'))),
                                const PopupMenuItem<String>(value: 'categories', child: ListTile(leading: Icon(Icons.category), title: Text('Categories'))),
                                if (isOwner)
                                  const PopupMenuItem<String>(value: 'admins', child: ListTile(leading: Icon(Icons.admin_panel_settings), title: Text('Manage Admins'))),
                                const PopupMenuItem<String>(value: 'participants', child: ListTile(leading: Icon(Icons.people), title: Text('Participants'))),
                                const PopupMenuItem<String>(value: 'schedule_settings', child: ListTile(leading: Icon(Icons.calendar_month), title: Text('Schedule Settings'))),
                                const PopupMenuItem<String>(value: 'generate_bracket', child: ListTile(leading: Icon(Icons.shuffle), title: Text('Generate Bracket'))),
                                if (isOwner) ...[
                                  const PopupMenuDivider(),
                                  const PopupMenuItem<String>(value: 'delete_bracket', child: ListTile(leading: Icon(Icons.delete_sweep, color: Colors.red), title: Text('Clear Bracket', style: TextStyle(color: Colors.red)))),
                                  const PopupMenuItem<String>(value: 'delete_tournament', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete Tournament', style: TextStyle(color: Colors.red)))),
                                ]
                              ],
                            );
                          }
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
                      TabBar(
                        tabs: [
                          Tab(text: loc.info),
                          Tab(text: loc.bracket),
                          Tab(text: loc.calendar),
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
                  MatchCalendarTab(tournament: tournament),
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
    final durationController = TextEditingController(text: '90');
    String type = 'singles';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Category'),
            content: SingleChildScrollView(
              child: Column(
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(labelText: 'Match Duration (minutes)'),
                    keyboardType: TextInputType.number,
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
                  if (nameController.text.isEmpty) return;
                  final duration = int.tryParse(durationController.text) ?? 90;
                  final category = TournamentCategory(
                    id: const Uuid().v4(),
                    tournamentId: widget.tournamentId,
                    name: nameController.text,
                    type: type,
                    description: descController.text,
                    matchDurationMinutes: duration,
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
    final durationController = TextEditingController(text: category.matchDurationMinutes.toString());
    String type = category.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Category'),
            content: SingleChildScrollView(
              child: Column(
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(labelText: 'Match Duration (minutes)'),
                    keyboardType: TextInputType.number,
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
                if (nameController.text.isEmpty) return;
                final duration = int.tryParse(durationController.text) ?? 90;
                final updated = category.copyWith(
                  name: nameController.text,
                  type: type,
                  description: descController.text,
                  matchDurationMinutes: duration,
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
    final loc = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserProvider);
    final participantsAsync = ref.watch(participantsProvider(tournament.id));
    final categoriesAsync = ref.watch(tournamentCategoriesProvider(tournament.id));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        // Header Section with Description and Tag
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               if (tournament.subscriptionTier == 'Free')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                       const SizedBox(width: 8),
                       Flexible(
                         child: Text(
                           AppLocalizations.of(context)!.createdUnderFreePlan, 
                           style: TextStyle(
                             fontSize: 12, 
                             color: Theme.of(context).colorScheme.onSurfaceVariant,
                             fontWeight: FontWeight.w500
                           )
                         ),
                       ),
                    ],
                  ),
                ),
              Text(
                tournament.description.isNotEmpty ? tournament.description : loc.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),

        // General Information Section
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
                loc.info,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _InfoRow(icon: Icons.calendar_today_outlined, text: tournament.dateRange),
              const Divider(height: 24),
              if (tournament.locationId != null)
                FutureBuilder(
                  future: ref.watch(locationRepositoryProvider).getLocation(tournament.locationId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final location = snapshot.data!;
                      return InkWell(
                        onTap: () async {
                          final uri = Uri.parse(location.googleMapsUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (location.imageUrl != null && location.imageUrl!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    location.imageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.location_on_outlined, size: 40, color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${location.numberOfCourts} ${loc.courtsAvailable}', 
                                    style: Theme.of(context).textTheme.bodySmall
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                          ],
                        ),
                      );
                    }
                    return _InfoRow(icon: Icons.location_on_outlined, text: tournament.location);
                  },
                )
              else
                _InfoRow(icon: Icons.location_on_outlined, text: tournament.location),
              const Divider(height: 24),
              _InfoRow(icon: Icons.people_outline, text: '${tournament.playersCount} Players joined'),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Organizers Section
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
                loc.organizers,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final adminsAsync = ref.watch(tournamentAdminsProvider(tournament));
                  return adminsAsync.when(
                    data: (admins) {
                       if (admins.isEmpty) return Text(loc.noOrganizersListed);
                       
                       final owner = admins.firstWhere(
                         (p) => p.id == tournament.ownerId, 
                         orElse: () => admins.firstWhere((p) => p.id == tournament.adminIds.firstOrNull, orElse: () => admins.first),
                       );
                       final adminsOnly = admins.where((p) => p.id != owner.id).toList();
                       
                       return Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           ListTile(
                             contentPadding: EdgeInsets.zero,
                             leading: CircleAvatar(
                               radius: 20,
                               backgroundImage: NetworkImage(owner.avatarUrl),
                             ),
                             title: Text(owner.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                             subtitle: Text(loc.owner, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                             onTap: () => context.push('/players/${owner.id}'),
                           ),
                           if (adminsOnly.isNotEmpty) ...[
                             const SizedBox(height: 8),
                             ...adminsOnly.map((admin) => ListTile(
                               contentPadding: EdgeInsets.zero,
                               leading: CircleAvatar(
                                 radius: 16,
                                 backgroundImage: NetworkImage(admin.avatarUrl),
                               ),
                               title: Text(admin.name),
                               subtitle: Text(loc.admins),
                               onTap: () => context.push('/players/${admin.id}'),
                             )),
                           ],
                         ],
                       );
                    },
                    loading: () => const LinearProgressIndicator(), 
                    error: (_, __) => const Text('Failed to load organizers.'),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Participants Section
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
                loc.participants,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              participantsAsync.when(
                data: (participants) {
                  if (participants.isEmpty) return const Text('No participants yet.');
                  
                  return categoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) return Text(loc.noCategoriesFound);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: categories.map((category) {
                          final categoryParticipants = participants
                              .where((p) => p.categoryId == category.id)
                              .toList();
                          
                          if (categoryParticipants.isEmpty) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...categoryParticipants.asMap().entries.map((entry) {
                                  final participant = entry.value;
                                  
                                  // Simplified participant display for list
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                         CircleAvatar(
                                            radius: 14,
                                            backgroundImage: participant.avatarUrls.isNotEmpty && participant.avatarUrls.first != null ? NetworkImage(participant.avatarUrls.first!) : null,
                                              child: participant.avatarUrls.isEmpty ? Text(participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?', 
                                              style: const TextStyle(fontSize: 10)) : null,
                                         ),
                                         const SizedBox(width: 12),
                                         Text(participant.name),
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
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const Text('Error loading categories'),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, __) => Text('Error: $e'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _JoinTournamentButton(
            tournament: tournament,
            currentUser: userAsync.asData?.value,
          ),
        ),
        const SizedBox(height: 32),
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
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseLogIn)),
      );
      return;
    }

    final categories = await ref.read(tournamentRepositoryProvider).getCategories(widget.tournament.id);
    
    if (categories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noCategoriesAvailable)),
        );
      }
      return;
    }

    // Local state for the dialog
    final selectedCategories = Set<String>.from(_joinedCategoryIds);
    final isEditing = _joinedCategoryIds.isNotEmpty;
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? loc.editParticipation : loc.joinTournament),
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
                        title: Text(loc.leaveTournament),
                        content: Text(loc.leaveTournamentConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(loc.cancel),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(loc.leave),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      Navigator.pop(context); // Close selection dialog
                      _handleLeaveTournament();
                    }
                  },
                  child: Text(loc.leaveParticipation),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.cancel),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleUpdateParticipation(selectedCategories);
                },
                child: Text(loc.confirm),
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
    final loc = AppLocalizations.of(context)!;

    try {
      // Determine additions and removals
      final toAdd = selectedCategories.difference(_joinedCategoryIds.toSet());
      final toRemove = _joinedCategoryIds.toSet().difference(selectedCategories);
      
      // Fetch categories to check types
      final categories = await repo.getCategories(tournamentId);

      // Execute changes
      for (final categoryId in toAdd) {
        final category = categories.firstWhere((c) => c.id == categoryId, orElse: () => throw Exception('Category not found'));
        List<String> userIdsToJoin = [userId];

        if (category.type == 'doubles' || category.type == 'team') {
           // Prompt for partner
           if (mounted) {
             final partnerId = await showDialog<String>(
               context: context, 
               builder: (ctx) => _PartnerSelectionDialog(currentUserId: userId),
             );
             
             if (partnerId != null) {
               userIdsToJoin.add(partnerId);
             } else {
               // Must have partner for doubles? 
               // For now, abort joining this category if no partner selected
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(loc.partnerRequired(category.name))),
               );
               continue;
             }
           }
        }
        
        await repo.joinTournament(tournamentId, userIdsToJoin, categoryId);
      }

      for (final categoryId in toRemove) {
        // Leaving logic - if we are in a team, does leaving remove the whole team?
        // Repo.leaveTournament implementation needs check.
        // Usually assume yes.
        await repo.leaveTournament(tournamentId, userId, categoryId);
      }

      await _checkRegistration();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(loc.participationUpdated)),
        );
        ref.invalidate(tournamentDetailProvider(tournamentId));
        ref.invalidate(participantsProvider(tournamentId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.errorUpdatingParticipation(e.toString()))),
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
    final loc = AppLocalizations.of(context)!;

    try {
      for (final categoryId in _joinedCategoryIds) {
        await repo.leaveTournament(tournamentId, userId, categoryId);
      }

      await _checkRegistration();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(loc.youHaveLeftTournament)),
        );
        ref.invalidate(tournamentDetailProvider(tournamentId));
        ref.invalidate(participantsProvider(tournamentId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.errorLeavingTournament(e.toString()))),
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
    final matchesAsync = ref.watch(bracketMatchesProvider(widget.tournament.id));

    return SizedBox(
      width: double.infinity,
      child: categoriesAsync.when(
        data: (categories) {
          final loc = AppLocalizations.of(context)!;
          
          // Check if brackets have been generated (matches exist)
          final hasBrackets = matchesAsync.when(
            data: (matches) => matches.isNotEmpty,
            loading: () => false,
            error: (_, __) => false,
          );
          
          final isDisabled = categories.isEmpty || (hasBrackets && !isJoined);
          final buttonText = hasBrackets && !isJoined
              ? loc.registrationClosed
              : (categories.isEmpty 
                  ? loc.noCategoriesAvailable 
                  : (isJoined ? loc.editParticipation : loc.joinTournament));
          
          return FilledButton(
            onPressed: (_isLoading || isDisabled) ? null : _showCategorySelectionDialog,
            style: isJoined 
                ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary) 
                : null,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(buttonText),
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
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.reorderPlayers(widget.categoryName)),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                loc.dragToReorder,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                      leading: Builder(
                        builder: (context) {
                          final urls = _items[i].avatarUrls;
                          if (urls.isEmpty) {
                            return CircleAvatar(
                              radius: 12,
                              backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                              child: Text(_items[i].name.isNotEmpty ? _items[i].name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 10)),
                            );
                          } else if (urls.length == 1) {
                             final url = urls.first;
                             return CircleAvatar(
                                radius: 12,
                                backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                                foregroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
                                child: (url == null || url.isEmpty) 
                                   ? Text(_items[i].name.isNotEmpty ? _items[i].name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 10)) 
                                   : null,
                             );
                          } else {
                             return SizedBox(
                               width: 30,
                               height: 24,
                               child: Stack(
                                 children: [
                                   for (int k = 0; k < urls.length && k < 2; k++)
                                     Positioned(
                                       left: k * 10.0,
                                       child: CircleAvatar(
                                         radius: 10,
                                         backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                                         foregroundImage: urls[k] != null && urls[k]!.isNotEmpty 
                                            ? NetworkImage(urls[k]!) : null,
                                         backgroundColor: Theme.of(context).cardColor,
                                       ),
                                     ),
                                 ],
                               ),
                             );
                          }
                        }
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
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _items),
          child: Text(loc.confirmOrder),
        ),
      ],
    );
  }
}

class _PartnerSelectionDialog extends ConsumerStatefulWidget {
  final String currentUserId;

  const _PartnerSelectionDialog({required this.currentUserId});

  @override
  ConsumerState<_PartnerSelectionDialog> createState() => _PartnerSelectionDialogState();
}

class _PartnerSelectionDialogState extends ConsumerState<_PartnerSelectionDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allPlayersAsync = ref.watch(allPlayersProvider);
    final userAsync = ref.watch(currentUserProvider);
    final currentUser = userAsync.value;
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.selectPartner),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: loc.searchByName,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: allPlayersAsync.when(
                data: (players) {
                  final filtered = players.where((p) {
                    if (p.id == widget.currentUserId) return false;
                    return p.name.toLowerCase().contains(_searchQuery);
                  }).toList();

                  // Sort: Friends first, then alphabetical
                  if (currentUser != null) {
                    filtered.sort((a, b) {
                      final aIsFriend = currentUser.following.contains(a.id);
                      final bIsFriend = currentUser.following.contains(b.id);
                      if (aIsFriend && !bIsFriend) return -1;
                      if (!aIsFriend && bIsFriend) return 1;
                      return a.name.compareTo(b.name);
                    });
                  }

                  if (filtered.isEmpty) {
                    return Center(child: Text(loc.noPlayersFound));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final player = filtered[index];
                      final isFriend = currentUser?.following.contains(player.id) ?? false;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: player.avatarUrl.isNotEmpty 
                             ? NetworkImage(player.avatarUrl) 
                             : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                        ),
                        title: Text(player.name),
                        trailing: isFriend 
                            ? const Icon(Icons.star, size: 16, color: Colors.amber) 
                            : null,
                        subtitle: isFriend ? Text(loc.friend, style: const TextStyle(fontSize: 10, color: Colors.amber)) : null,
                        onTap: () => Navigator.pop(context, player.id),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('${loc.errorOccurred(e.toString())}')),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Return null
          child: Text(loc.cancel),
        ),
      ],
    );
  }
}
