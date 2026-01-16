import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/home/presentation/widgets/live_tournament_card.dart';
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
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Mine', 'Open', 'Men\'s Singles', 'Women\'s Singles', 'Doubles'];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // We need to update the provider to accept a category, or just filter locally if the list is small.
    // ...
    
    final tournamentsAsync = ref.watch(filteredTournamentsProvider(_selectedCategory));

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                String label = category;
                switch (category) {
                  case 'All': label = loc.all; break;
                  case 'Mine': label = loc.mine; break;
                  case 'Open': label = loc.open; break;
                  case 'Men\'s Singles': label = loc.mensSingles; break;
                  case 'Women\'s Singles': label = loc.womensSingles; break;
                  case 'Doubles': label = loc.doubles; break;
                }
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: tournamentsAsync.when(
              data: (tournaments) {
                if (tournaments.isEmpty) {
                  return Center(child: Text(loc.noTournamentsFound));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tournaments.length,
                  itemBuilder: (context, index) {
                    final tournament = tournaments[index];
                    return GestureDetector(
                      onTap: () => context.go('/tournaments/${tournament.id}'),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LiveTournamentCard(tournament: tournament),
                      ),
                    );
                  },
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
              
              // We need the tournament count. This implies we need a provider or to fetch it.
              // We'll use a FutureBuilder here for simplicity or create a provider if needed.
              // For better UX with FAB, let's use a provider so it doesn't flicker too much.
              // But we don't have a provider for count exposed yet.
              // Let's assume we can watch a future provider for count.
              
              return FutureBuilder<int>(
                future: ref.read(tournamentRepositoryProvider).getUserTournamentCount(user.id),
                builder: (context, snapshot) {
                  // Default to 0 if loading, or maybe show loading state on FAB?
                  // Be conservative: disable if loading.
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
                     // Limit reached
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
                           heroTag: 'create_fab', // Unique tag
                           backgroundColor: Colors.grey,
                           onPressed: null, // "turn the button gray and not interactable"
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

final filteredTournamentsProvider = FutureProvider.family<List<Tournament>, String>((ref, category) async {
  if (category == 'Mine') {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return [];
    return ref.watch(tournamentRepositoryProvider).getTournamentsForUser(user.id);
  }
  return ref.watch(tournamentRepositoryProvider).getLiveTournaments(category: category);
});
