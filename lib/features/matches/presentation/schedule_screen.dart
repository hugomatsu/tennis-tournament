import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/matches/presentation/widgets/match_list_calendar.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The provider below should already filter for "My Schedule" logic 
    // (participating + followed matches)
    final scheduleAsync = ref.watch(scheduleProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.mySchedule),
        centerTitle: false,
      ),
      body: scheduleAsync.when(
        data: (matches) {
          return MatchListCalendar(matches: matches);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

// Ensure this provider captures "Participating OR Followed" matches
final scheduleProvider = StreamProvider<List<TennisMatch>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      // Extract followed match IDs from the user profile
      final followedIds = user.followedMatchIds;
      // Pass them to the repository
      return ref.watch(matchRepositoryProvider).watchUpcomingMatches(followedIds);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

