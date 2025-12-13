import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/home/presentation/widgets/live_tournament_card.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';

import 'package:tennis_tournament/l10n/app_localizations.dart';

class TournamentsScreen extends ConsumerStatefulWidget {
  const TournamentsScreen({super.key});

  @override
  ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends ConsumerState<TournamentsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Open', 'Men\'s Singles', 'Women\'s Singles', 'Doubles'];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // We need to update the provider to accept a category, or just filter locally if the list is small.
    // ...
    
    final tournamentsAsync = ref.watch(filteredTournamentsProvider(_selectedCategory));

    return Scaffold(
      appBar: AppBar(title: Text(loc.tournaments)),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
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
                  return const Center(child: Text('No tournaments found'));
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
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

final filteredTournamentsProvider = FutureProvider.family<List<Tournament>, String>((ref, category) {
  return ref.watch(tournamentRepositoryProvider).getLiveTournaments(category: category);
});
