import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';

class MatchCalendarTab extends ConsumerWidget {
  final Tournament tournament;

  const MatchCalendarTab({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchListProvider(tournament.id));

    return matchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return const Center(child: Text('No matches scheduled yet.'));
        }

        // Group matches by date
        final groupedMatches = <DateTime, List<TennisMatch>>{};
        for (final match in matches) {
          final date = DateTime(match.time.year, match.time.month, match.time.day);
          if (!groupedMatches.containsKey(date)) {
            groupedMatches[date] = [];
          }
          groupedMatches[date]!.add(match);
        }

        // Sort dates
        final sortedDates = groupedMatches.keys.toList()..sort();

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dayMatches = groupedMatches[date]!..sort((a, b) => a.time.compareTo(b.time));

            return StickyHeader(
              header: Container(
                height: 50.0,
                color: Theme.of(context).colorScheme.surfaceContainer,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('EEEE, MMMM d, y').format(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              content: Column(
                children: dayMatches.map((match) => _MatchCard(match: match)).toList(),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _MatchCard extends ConsumerWidget {
  final TennisMatch match;

  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserId = currentUserAsync.value?.id;
    final isParticipant = currentUserId != null && 
        (match.player1Id == currentUserId || match.player2Id == currentUserId);

    // Highlight color/style
    final borderColor = isParticipant ? Theme.of(context).colorScheme.primary : null;
    final borderWidth = isParticipant ? 2.0 : 0.0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isParticipant 
          ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2) 
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          context.push('/matches/${match.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('HH:mm').format(match.time),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  _StatusChip(status: match.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PlayerInfo(
                      name: match.player1Name,
                      avatarUrl: match.player1AvatarUrl,
                      isWinner: match.winner == match.player1Name,
                      isMe: currentUserId != null && match.player1Id == currentUserId,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _PlayerInfo(
                      name: match.player2Name ?? 'TBD',
                      avatarUrl: match.player2AvatarUrl,
                      isWinner: match.winner != null && match.winner == match.player2Name,
                      isRightAligned: true,
                      isMe: currentUserId != null && match.player2Id == currentUserId,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      match.court.isNotEmpty ? match.court : 'Location TBD',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _PlayerInfo extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isWinner;
  final bool isRightAligned;
  final bool isMe;

  const _PlayerInfo({
    required this.name,
    this.avatarUrl,
    this.isWinner = false,
    this.isRightAligned = false,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: 20,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null ? Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(fontSize: 14)) : null,
    );

    final nameText = Text(
      name + (isMe ? ' (You)' : ''),
      style: TextStyle(
        fontWeight: isWinner || isMe ? FontWeight.bold : FontWeight.normal,
        color: isWinner 
            ? Theme.of(context).colorScheme.primary 
            : (isMe ? Theme.of(context).colorScheme.secondary : null),
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: isRightAligned ? TextAlign.right : TextAlign.left,
    );

    if (isRightAligned) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: nameText),
          const SizedBox(width: 8),
          avatar,
        ],
      );
    } else {
      return Row(
        children: [
          avatar,
          const SizedBox(width: 8),
          Expanded(child: nameText),
        ],
      );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Preparing':
        color = Colors.orange;
        break;
      case 'Scheduled':
        color = Colors.blue;
        break;
      case 'Confirmed':
        color = Colors.purple;
        break;
      case 'Started':
        color = Colors.green;
        break;
      case 'Finished':
      case 'Completed':
        color = Colors.grey;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Provider for fetching matches
final matchListProvider = StreamProvider.family<List<TennisMatch>, String>((ref, tournamentId) {
  return ref.watch(matchRepositoryProvider).watchMatchesForTournament(tournamentId);
});
