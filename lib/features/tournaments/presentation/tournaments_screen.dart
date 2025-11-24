import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/home/presentation/home_screen.dart';
import 'package:tennis_tournament/features/home/presentation/widgets/live_tournament_card.dart';

class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(liveTournamentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
      body: tournamentsAsync.when(
        data: (tournaments) => ListView.builder(
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
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
