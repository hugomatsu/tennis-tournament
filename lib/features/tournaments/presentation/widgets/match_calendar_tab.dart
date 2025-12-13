import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:tennis_tournament/features/matches/presentation/widgets/match_list_calendar.dart';

class MatchCalendarTab extends ConsumerWidget {
  final Tournament tournament;

  const MatchCalendarTab({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchListProvider(tournament.id));
    final loc = AppLocalizations.of(context)!;

    return matchesAsync.when(
      data: (matches) {
        return MatchListCalendar(
          matches: matches,
          emptyState: Center(child: Text(loc.noMatchesScheduled)),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}


// Provider for fetching matches
final matchListProvider = StreamProvider.family<List<TennisMatch>, String>((ref, tournamentId) {
  return ref.watch(matchRepositoryProvider).watchMatchesForTournament(tournamentId);
});
