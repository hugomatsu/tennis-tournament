import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/home/presentation/widgets/live_tournament_card.dart';
import 'package:tennis_tournament/features/tournaments/application/tournament_filter_preferences.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';

import 'package:tennis_tournament/l10n/app_localizations.dart';

class TournamentsScreen extends ConsumerStatefulWidget {
  const TournamentsScreen({super.key});

  @override
  ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends ConsumerState<TournamentsScreen> {
  // Filter state
  bool _filterMine = false;
  bool _filterSingle = false;
  bool _filterTeam = false;
  bool _filterOpen = false;
  bool _filtersLoaded = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  
  // Pagination state
  int _currentPage = 0;
  static const int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    final filters = await TournamentFilterPreferences.loadFilters();
    if (mounted) {
      setState(() {
        _filterMine = filters['mine'] ?? false;
        _filterSingle = filters['single'] ?? false;
        _filterTeam = filters['team'] ?? false;
        _filterOpen = filters['open'] ?? false;
        _filtersLoaded = true;
      });
    }
  }

  Future<void> _saveFilters() async {
    await TournamentFilterPreferences.saveFilters(
      mine: _filterMine,
      single: _filterSingle,
      team: _filterTeam,
      open: _filterOpen,
    );
  }

  void _onFilterChanged() {
    _currentPage = 0; // Reset to first page when filters change
    _saveFilters();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    if (!_filtersLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.tournaments)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final filterParams = TournamentFilterParams(
      mine: _filterMine,
      single: _filterSingle,
      team: _filterTeam,
      open: _filterOpen,
      searchQuery: _searchQuery,
    );
    
    final tournamentsAsync = ref.watch(filteredTournamentsProvider(filterParams));

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tournaments),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.push('/help'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.searchTournament,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _currentPage = 0;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                  _currentPage = 0;
                });
              },
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Mine filter
                FilterChip(
                  label: Text(loc.mine),
                  selected: _filterMine,
                  onSelected: (selected) {
                    setState(() => _filterMine = selected);
                    _onFilterChanged();
                  },
                ),
                // Single/Team toggle group
                FilterChip(
                  label: Text(loc.single),
                  selected: _filterSingle,
                  onSelected: (selected) {
                    setState(() {
                      _filterSingle = selected;
                      if (selected) _filterTeam = false; // Mutually exclusive
                    });
                    _onFilterChanged();
                  },
                ),
                FilterChip(
                  label: Text(loc.team),
                  selected: _filterTeam,
                  onSelected: (selected) {
                    setState(() {
                      _filterTeam = selected;
                      if (selected) _filterSingle = false; // Mutually exclusive
                    });
                    _onFilterChanged();
                  },
                ),
                // Open filter
                FilterChip(
                  label: Text(loc.open),
                  selected: _filterOpen,
                  onSelected: (selected) {
                    setState(() => _filterOpen = selected);
                    _onFilterChanged();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: tournamentsAsync.when(
              data: (tournaments) {
                if (tournaments.isEmpty) {
                  return Center(child: Text(loc.noTournamentsFound));
                }
                
                // Pagination logic
                final totalPages = (tournaments.length / pageSize).ceil();
                final startIndex = _currentPage * pageSize;
                final endIndex = (startIndex + pageSize).clamp(0, tournaments.length);
                final paginatedTournaments = tournaments.sublist(startIndex, endIndex);
                
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: paginatedTournaments.length,
                        itemBuilder: (context, index) {
                          final tournament = paginatedTournaments[index];
                          return GestureDetector(
                            onTap: () => context.go('/tournaments/${tournament.id}'),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: LiveTournamentCard(tournament: tournament),
                            ),
                          );
                        },
                      ),
                    ),
                    // Pagination controls
                    if (totalPages > 1)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: _currentPage > 0
                                  ? () => setState(() => _currentPage--)
                                  : null,
                              icon: const Icon(Icons.arrow_back),
                              label: Text(loc.previous),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                loc.pageOf(_currentPage + 1, totalPages),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _currentPage < totalPages - 1
                                  ? () => setState(() => _currentPage++)
                                  : null,
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(loc.next),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('${loc.errorOccurred(err.toString())}')),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final userAsync = ref.watch(currentUserProvider);
          return userAsync.when(
            data: (user) {
              if (user == null) return const SizedBox.shrink();
              
              return FutureBuilder<int>(
                future: ref.read(tournamentRepositoryProvider).getUserTournamentCount(user.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const FloatingActionButton(onPressed: null, child: Icon(Icons.add));
                  
                  final count = snapshot.data!;
                  final isPremium = user.isPremium;
                  final limit = 2;
                  final canCreate = isPremium || count < limit;
                  
                  if (canCreate) {
                     return FloatingActionButton.extended(
                      onPressed: () => context.go('/admin/create-tournament'),
                      icon: const Icon(Icons.add),
                      label: Text(isPremium ? loc.createTournament : '${loc.createTournament} (${count}/$limit)'),
                    );
                  } else {
                     return Column(
                       mainAxisSize: MainAxisSize.min,
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                         FloatingActionButton.extended(
                           heroTag: 'premium_fab',
                           backgroundColor: Colors.amber,
                           foregroundColor: Colors.black,
                           onPressed: () => context.push('/subscription'),
                           icon: const Icon(Icons.star),
                           label: Text(loc.upgradeToPremium),
                         ),
                         const SizedBox(height: 16),
                         FloatingActionButton.extended(
                           heroTag: 'create_fab',
                           backgroundColor: Colors.grey,
                           onPressed: null,
                           icon: const Icon(Icons.block),
                           label: Text(loc.limitReached),
                         ),
                       ],
                     );
                  }
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_,__) => const SizedBox.shrink(),
          );
        }, 
      ),
    );
  }
}

class TournamentFilterParams {
  final bool mine;
  final bool single;
  final bool team;
  final bool open;
  final String searchQuery;

  const TournamentFilterParams({
    this.mine = false,
    this.single = false,
    this.team = false,
    this.open = false,
    this.searchQuery = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentFilterParams &&
          runtimeType == other.runtimeType &&
          mine == other.mine &&
          single == other.single &&
          team == other.team &&
          open == other.open &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode => mine.hashCode ^ single.hashCode ^ team.hashCode ^ open.hashCode ^ searchQuery.hashCode;
}

final filteredTournamentsProvider = FutureProvider.family<List<Tournament>, TournamentFilterParams>((ref, params) async {
  List<Tournament> tournaments;
  
  if (params.mine) {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return [];
    tournaments = await ref.watch(tournamentRepositoryProvider).getTournamentsForUser(user.id);
  } else {
    tournaments = await ref.watch(tournamentRepositoryProvider).getLiveTournaments();
  }
  
  // Apply additional filters
  return tournaments.where((t) {
    // Search filter - check name
    if (params.searchQuery.isNotEmpty) {
      if (!t.name.toLowerCase().contains(params.searchQuery)) {
        return false;
      }
    }
    
    // Single filter - check tournament type or name for singles
    if (params.single) {
      // Check tournamentType field first, then fall back to name
      final isSingles = t.tournamentType == 'singles' ||
                        t.name.toLowerCase().contains('single') || 
                        t.name.toLowerCase().contains('simples');
      if (!isSingles) return false;
    }
    
    // Team filter - check tournament type for doubles/team
    if (params.team) {
      final isTeam = t.tournamentType == 'doubles' ||
                     t.name.toLowerCase().contains('double') || 
                     t.name.toLowerCase().contains('dupla') ||
                     t.name.toLowerCase().contains('duplas') ||
                     t.name.toLowerCase().contains('team');
      if (!isTeam) return false;
    }
    
    // Open filter - check if registration is open
    if (params.open) {
      final isOpen = t.status == 'Registration Open' || t.status == 'Open';
      if (!isOpen) return false;
    }
    
    return true;
  }).toList();
});
