import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/home/presentation/widgets/live_tournament_card.dart';
import 'package:tennis_tournament/features/tournaments/application/tournament_filter_preferences.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/core/analytics/analytics_service.dart';
import 'package:tennis_tournament/features/tutorial/domain/tutorial_keys.dart';
import 'package:tennis_tournament/features/tutorial/presentation/tutorial_controller.dart';
import 'package:tennis_tournament/features/tutorial/data/tutorial_repository.dart';
import 'package:tennis_tournament/features/tutorial/data/tutorial_steps_data.dart';

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
  bool _filterParticipating = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logViewTournamentList();
      _maybeStartTutorial();
    });
  }

  Future<void> _maybeStartTutorial() async {
    // Check if we were navigated here with startTutorial flag
    final extra = GoRouterState.of(context).extra;
    final shouldStart = extra is Map<String, dynamic> && extra['startTutorial'] == true;

    if (!shouldStart) {
      // Also auto-start if player tutorial was never completed
      final completed = await ref.read(tutorialRepositoryProvider).isPlayerTutorialCompleted();
      final welcomeSeen = await ref.read(tutorialRepositoryProvider).isWelcomeSeen();
      if (completed || !welcomeSeen) return;
    }

    // Small delay to let the screen fully render
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final loc = AppLocalizations.of(context)!;
    ref.read(tutorialControllerProvider).startPlayerTutorial(
      context: context,
      steps: getPlayerTutorialSteps(loc),
      source: shouldStart ? 'welcome_cta' : 'auto',
    );
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
        _filterParticipating = filters['participating'] ?? false;
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
      participating: _filterParticipating,
    );
  }

  void _onFilterChanged() {
    _currentPage = 0;
    _saveFilters();
  }

  int get _activeFilterCount =>
      (_filterMine ? 1 : 0) +
      (_filterParticipating ? 1 : 0) +
      (_filterSingle ? 1 : 0) +
      (_filterTeam ? 1 : 0) +
      (_filterOpen ? 1 : 0);

  void _showFilterSheet(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.filter, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          _filterMine = false;
                          _filterParticipating = false;
                          _filterSingle = false;
                          _filterTeam = false;
                          _filterOpen = false;
                        });
                        setState(() {});
                        _onFilterChanged();
                      },
                      child: Text(loc.clearAll),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(loc.mine),
                      selected: _filterMine,
                      onSelected: (v) {
                        setSheetState(() {
                          _filterMine = v;
                          if (v) _filterParticipating = false;
                        });
                        setState(() {});
                        _onFilterChanged();
                      },
                    ),
                    FilterChip(
                      label: Text(loc.participating),
                      selected: _filterParticipating,
                      onSelected: (v) {
                        setSheetState(() {
                          _filterParticipating = v;
                          if (v) _filterMine = false;
                        });
                        setState(() {});
                        _onFilterChanged();
                      },
                    ),
                    FilterChip(
                      label: Text(loc.single),
                      selected: _filterSingle,
                      onSelected: (v) {
                        setSheetState(() {
                          _filterSingle = v;
                          if (v) _filterTeam = false;
                        });
                        setState(() {});
                        _onFilterChanged();
                      },
                    ),
                    FilterChip(
                      label: Text(loc.team),
                      selected: _filterTeam,
                      onSelected: (v) {
                        setSheetState(() {
                          _filterTeam = v;
                          if (v) _filterSingle = false;
                        });
                        setState(() {});
                        _onFilterChanged();
                      },
                    ),
                    FilterChip(
                      label: Text(loc.open),
                      selected: _filterOpen,
                      onSelected: (v) {
                        setSheetState(() => _filterOpen = v);
                        setState(() {});
                        _onFilterChanged();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
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
      participating: _filterParticipating,
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
          // Search bar + filter button (single row)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: TutorialKeys.searchBar,
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
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: _activeFilterCount > 0,
                  label: Text('$_activeFilterCount'),
                  child: IconButton.outlined(
                    key: TutorialKeys.filterButton,
                    icon: const Icon(Icons.tune),
                    onPressed: () => _showFilterSheet(context, loc),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tournamentsAsync.when(
              data: (tournaments) {
                // Pagination logic
                final totalPages = tournaments.isEmpty ? 0 : (tournaments.length / pageSize).ceil();
                final startIndex = _currentPage * pageSize;
                final endIndex = tournaments.isEmpty ? 0 : (startIndex + pageSize).clamp(0, tournaments.length);
                final paginatedTournaments = tournaments.isEmpty ? <Tournament>[] : tournaments.sublist(startIndex, endIndex);

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(filteredTournamentsProvider(filterParams));
                        },
                        child: tournaments.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: 300,
                                    child: Center(child: Text(loc.noTournamentsFound)),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: paginatedTournaments.length,
                                itemBuilder: (context, index) {
                                  final tournament = paginatedTournaments[index];
                                  return GestureDetector(
                                    key: index == 0 ? TutorialKeys.firstTournamentCard : null,
                                    onTap: () => context.go('/tournaments/${tournament.id}'),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: LiveTournamentCard(tournament: tournament),
                                    ),
                                  );
                                },
                              ),
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
              error: (err, stack) => Center(child: Text(loc.errorOccurred(err.toString()))),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final loc = AppLocalizations.of(context)!;
          final userAsync = ref.watch(currentUserProvider);
          return userAsync.when(
            data: (user) {
              if (user == null) {
                return FloatingActionButton.extended(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  elevation: 1,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        icon: const Icon(Icons.lock_outline, size: 32),
                        title: Text(loc.guestCannotCreateTournamentTitle),
                        content: Text(loc.guestCannotCreateTournamentBody),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(loc.cancel),
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.go('/profile');
                            },
                            icon: const Icon(Icons.person_outlined, size: 18),
                            label: Text(loc.createAccount),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(loc.createTournament),
                );
              }
              
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
                      key: TutorialKeys.createTournamentFab,
                      onPressed: () => context.push('/admin/create-tournament'),
                      icon: const Icon(Icons.add),
                      label: Text(isPremium ? loc.createTournament : '${loc.createTournament} ($count/$limit)'),
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
            error: (_, _) => const SizedBox.shrink(),
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
  final bool participating;
  final String searchQuery;

  const TournamentFilterParams({
    this.mine = false,
    this.single = false,
    this.team = false,
    this.open = false,
    this.participating = false,
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
          participating == other.participating &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode => mine.hashCode ^ single.hashCode ^ team.hashCode ^ open.hashCode ^ participating.hashCode ^ searchQuery.hashCode;
}

final filteredTournamentsProvider = FutureProvider.family<List<Tournament>, TournamentFilterParams>((ref, params) async {
  List<Tournament> tournaments;
  final repo = ref.watch(tournamentRepositoryProvider);

  if (params.participating) {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return [];
    tournaments = await repo.getTournamentsParticipating(user.id);
  } else if (params.mine) {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return [];
    tournaments = await repo.getTournamentsForUser(user.id);
  } else {
    tournaments = await repo.getLiveTournaments();
  }
  
  // Apply additional filters
  return tournaments.where((t) {
    // Search filter - check name
    if (params.searchQuery.isNotEmpty) {
      if (!t.name.toLowerCase().contains(params.searchQuery)) {
        return false;
      }
    }
    
    // Single filter - check tournament format or name for singles
    if (params.single) {
      final isSingles = t.format == 'singles' ||
                        t.name.toLowerCase().contains('single') ||
                        t.name.toLowerCase().contains('simples');
      if (!isSingles) return false;
    }

    // Team filter - check tournament format for doubles/team
    if (params.team) {
      final isTeam = t.format == 'doubles' ||
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
