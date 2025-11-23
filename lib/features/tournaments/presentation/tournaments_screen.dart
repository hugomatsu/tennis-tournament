import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/core/utils/mock_data.dart';
import 'package:tennis_tournament/features/home/presentation/widgets/live_tournament_card.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.liveTournaments.length,
        itemBuilder: (context, index) {
          final tournament = MockData.liveTournaments[index];
          return GestureDetector(
            onTap: () => context.go('/tournaments/${tournament['id']}'),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LiveTournamentCard(tournament: tournament),
            ),
          );
        },
      ),
    );
  }
}
