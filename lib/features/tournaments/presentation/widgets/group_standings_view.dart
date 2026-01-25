import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/tournaments/application/open_tennis_service.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/group_standing.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/core/sharing/widgets/share_preview_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tennis_tournament/l10n/app_localizations.dart';

/// Stream provider for real-time group standings updates
final groupStandingsStreamProvider = StreamProvider.family<Map<String, List<GroupStanding>>, (String, String)>((ref, params) {
  final (tournamentId, categoryId) = params;
  
  return FirebaseFirestore.instance
      .collection('tournaments')
      .doc(tournamentId)
      .collection('standings')
      .where('categoryId', isEqualTo: categoryId)
      .snapshots()
      .map((snapshot) {
        final standings = snapshot.docs
            .map((doc) => GroupStanding.fromJson(doc.data()))
            .toList();

        // Group by groupId
        final grouped = <String, List<GroupStanding>>{};
        for (final s in standings) {
          grouped.putIfAbsent(s.groupId, () => []);
          grouped[s.groupId]!.add(s);
        }

        // Sort each group by points (descending), then by wins
        for (final group in grouped.values) {
          group.sort((a, b) {
            final pointsCompare = b.points.compareTo(a.points);
            if (pointsCompare != 0) return pointsCompare;
            return b.wins.compareTo(a.wins);
          });
        }

        return grouped;
      });
});

/// Widget to display Open Tennis mode group standings and matches
class GroupStandingsView extends ConsumerWidget {
  final String tournamentId;
  final String categoryId;
  final Tournament tournament;

  const GroupStandingsView({
    super.key,
    required this.tournamentId,
    required this.categoryId,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final standingsAsync = ref.watch(groupStandingsStreamProvider((tournamentId, categoryId)));
    final matchesStream = ref.watch(matchRepositoryProvider).watchMatchesForTournament(tournamentId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with info
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.group, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    loc.openTennisMode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                loc.pointsPerWinLabel(tournament.pointsPerWin),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        
        // Playoff bracket generation button (shows when all group matches complete)
        StreamBuilder<List<TennisMatch>>(
          stream: matchesStream,
          builder: (context, matchSnapshot) {
            final allMatches = matchSnapshot.data ?? [];
            final categoryMatches = allMatches.where((m) => m.categoryId == categoryId).toList();
            final groupMatches = categoryMatches.where((m) => m.round.startsWith('Group')).toList();
            final playoffMatches = categoryMatches.where((m) => !m.round.startsWith('Group')).toList();
            
            final allGroupMatchesCompleted = groupMatches.isNotEmpty &&
                groupMatches.every((m) => m.status == 'Completed' || m.status == 'Finished');
            final hasPlayoffBracket = playoffMatches.isNotEmpty;
            
            if (allGroupMatchesCompleted && !hasPlayoffBracket) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: FilledButton.icon(
                  onPressed: () => _generatePlayoffBracket(context, ref),
                  icon: const Icon(Icons.emoji_events),
                  label: Text(loc.generatePlayoffBracket),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              );
            }
            
            if (hasPlayoffBracket) {
              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.playoffBracketGenerated,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
        
        // Group standings
        Expanded(
          child: standingsAsync.when(
            data: (groupedStandings) {
              if (groupedStandings.isEmpty) {
                return Center(
                  child: Text(loc.noStandingsYet),
                );
              }

              return StreamBuilder<List<TennisMatch>>(
                stream: matchesStream,
                builder: (context, snapshot) {
                  final allMatches = snapshot.data ?? [];
                  final categoryMatches = allMatches
                      .where((m) => m.categoryId == categoryId)
                      .toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedStandings.length,
                    itemBuilder: (context, index) {
                      final groupId = groupedStandings.keys.elementAt(index);
                      final standings = groupedStandings[groupId]!;
                      final groupMatches = categoryMatches
                          .where((m) => m.round == 'Group $groupId')
                          .toList();

                      // Calculate if all matches completed for this group
                      final allGroupMatchesComplete = groupMatches.isNotEmpty &&
                          groupMatches.every((m) => m.status == 'Completed' || m.status == 'Finished');
                      
                      return _GroupCard(
                        groupId: groupId,
                        standings: standings,
                        matches: groupMatches,
                        tournament: tournament,
                        allMatchesCompleted: allGroupMatchesComplete,
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(loc.errorOccurred(e.toString()))),
          ),
        ),
      ],
    );
  }

  Future<void> _generatePlayoffBracket(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final loc = AppLocalizations.of(context)!;
    
    try {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(loc.generatingPlayoffBracket)),
      );
      
      final openTennisService = ref.read(openTennisServiceProvider);
      final categories = await ref.read(tournamentRepositoryProvider).getCategories(tournamentId);
      final category = categories.firstWhere((c) => c.id == categoryId);
      
      final playoffMatches = await openTennisService.generatePlayoffBracket(
        tournament,
        category,
      );
      
      // Create matches in Firestore
      await ref.read(matchRepositoryProvider).createMatches(playoffMatches);
      
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(loc.playoffBracketCreated(playoffMatches.length))),
      );
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(loc.errorGeneratingPlayoff(e.toString()))),
      );
    }
  }
}

class _GroupCard extends StatelessWidget {
  final String groupId;
  final List<GroupStanding> standings;
  final List<TennisMatch> matches;
  final Tournament tournament;
  final bool allMatchesCompleted;

  const _GroupCard({
    required this.groupId,
    required this.standings,
    required this.matches,
    required this.tournament,
    required this.allMatchesCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final groupLeader = standings.isNotEmpty ? standings.first : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header with share button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        loc.groupLabel(groupId),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (allMatchesCompleted && groupLeader != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                groupLeader.participantName,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Share button
                IconButton(
                  icon: const Icon(Icons.share, size: 20),
                  onPressed: () => _shareGroup(context),
                  tooltip: loc.shareGroupLabel(groupId),
                ),
              ],
            ),
          ),
          
          // Standings table
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.standings,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2.5),
                    1: FixedColumnWidth(36),
                    2: FixedColumnWidth(36),
                    3: FixedColumnWidth(36),
                    4: FixedColumnWidth(45),
                  },
                  children: [
                    TableRow(
                      children: [
                        Text(loc.player, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(loc.winsShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(loc.lossesShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(loc.playedShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(loc.pointsShort, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    ...standings.asMap().entries.map((entry) {
                      final standing = entry.value;
                      final rank = entry.key + 1;
                      final isWinner = rank == 1 && allMatchesCompleted;
                      final avatarUrl = standing.participantAvatarUrls.isNotEmpty 
                          ? standing.participantAvatarUrls.first 
                          : null;
                      
                      return TableRow(
                        decoration: BoxDecoration(
                          color: isWinner ? Colors.amber.withOpacity(0.15) : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                // Rank badge or trophy for winner
                                if (isWinner)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.amber.shade400, Colors.orange.shade600],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.emoji_events, size: 14, color: Colors.white),
                                  )
                                else
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: rank == 1 
                                          ? Colors.amber.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$rank',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                // Player avatar
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                  child: avatarUrl == null 
                                      ? Text(
                                          standing.participantName.isNotEmpty 
                                              ? standing.participantName[0].toUpperCase() 
                                              : '?',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    standing.participantName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isWinner || rank == 1 ? FontWeight.bold : FontWeight.normal,
                                      color: isWinner ? Colors.amber.shade800 : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text('${standing.wins}', style: TextStyle(fontSize: 13, fontWeight: isWinner ? FontWeight.bold : FontWeight.normal)),
                          Text('${standing.losses}', style: TextStyle(fontSize: 13, fontWeight: isWinner ? FontWeight.bold : FontWeight.normal)),
                          Text('${standing.matchesPlayed}', style: TextStyle(fontSize: 13, fontWeight: isWinner ? FontWeight.bold : FontWeight.normal)),
                          Text(
                            '${standing.points}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isWinner ? Colors.amber.shade800 : null,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          
          // Matches
          if (matches.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.matches,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...matches.map((match) => _MatchTile(match: match)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _shareGroup(BuildContext context) {
    // Build share widget with all players and avatars
    final shareWidget = Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament name
          Text(
            tournament.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          // Group header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Group $groupId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Standings list with all players
          ...standings.asMap().entries.map((entry) {
            final standing = entry.value;
            final rank = entry.key + 1;
            final isWinner = rank == 1 && allMatchesCompleted;
            final avatarUrl = standing.participantAvatarUrls.isNotEmpty 
                ? standing.participantAvatarUrls.first 
                : null;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isWinner 
                    ? Colors.amber.withOpacity(0.15) 
                    : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: isWinner 
                    ? Border.all(color: Colors.amber.shade400, width: 2) 
                    : null,
              ),
              child: Row(
                children: [
                  // Rank badge or trophy
                  if (isWinner)
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade600],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events, size: 16, color: Colors.white),
                    )
                  else
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$rank',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(width: 12),
                  // Avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null 
                        ? Text(
                            standing.participantName.isNotEmpty 
                                ? standing.participantName[0].toUpperCase() 
                                : '?',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Player name
                  Expanded(
                    child: Text(
                      standing.participantName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                        color: isWinner ? Colors.amber.shade800 : Colors.black87,
                      ),
                    ),
                  ),
                  // Stats
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${standing.wins}W ${standing.losses}L',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Points
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isWinner ? Colors.amber.shade100 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${standing.points}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isWinner ? Colors.amber.shade800 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          // Footer
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_tennis, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  'entresets.com',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Use SharePreviewScreen pattern with background options, copy, and share
    SharePreviewScreen.show(
      context: context,
      shareWidget: shareWidget,
      shareSubject: '${tournament.name} - Group $groupId Standings',
    );
  }
}

class _MatchTile extends StatelessWidget {
  final TennisMatch match;

  const _MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final isCompleted = match.status == 'Completed' || match.status == 'Finished';
    final hasWinner = match.winner != null && match.winner!.isNotEmpty;
    final isP1Winner = match.winner == match.player1Name;
    final isP2Winner = match.winner == match.player2Name;
    
    // Get avatar URLs
    final p1Avatar = match.player1AvatarUrls.isNotEmpty ? match.player1AvatarUrls.first : null;
    final p2Avatar = match.player2AvatarUrls.isNotEmpty ? match.player2AvatarUrls.first : null;
    
    return InkWell(
      onTap: () => context.push('/matches/${match.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: hasWinner 
              ? Colors.amber.withOpacity(0.05) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            // Player 1
            Expanded(
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isP1Winner 
                        ? Colors.amber.shade100 
                        : Colors.grey.shade200,
                    backgroundImage: p1Avatar != null ? NetworkImage(p1Avatar) : null,
                    child: p1Avatar == null 
                        ? Text(
                            match.player1Name.isNotEmpty 
                                ? match.player1Name[0].toUpperCase() 
                                : '?',
                            style: TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.bold,
                              color: isP1Winner ? Colors.amber.shade800 : Colors.grey.shade600,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  // Winner trophy
                  if (isP1Winner) ...[
                    Icon(Icons.emoji_events, size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                  ],
                  // Name
                  Expanded(
                    child: Text(
                      match.player1Name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isP1Winner ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        color: isP1Winner ? Colors.amber.shade800 : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Score/Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.green.withOpacity(0.15) 
                    : Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isCompleted ? (match.score ?? 'W') : match.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ),
            // Player 2
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Name
                  Expanded(
                    child: Text(
                      match.player2Name ?? 'TBD',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isP2Winner ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        color: isP2Winner ? Colors.amber.shade800 : null,
                      ),
                    ),
                  ),
                  // Winner trophy
                  if (isP2Winner) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.emoji_events, size: 14, color: Colors.amber.shade600),
                  ],
                  const SizedBox(width: 8),
                  // Avatar
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isP2Winner 
                        ? Colors.amber.shade100 
                        : Colors.grey.shade200,
                    backgroundImage: p2Avatar != null ? NetworkImage(p2Avatar) : null,
                    child: p2Avatar == null 
                        ? Text(
                            (match.player2Name ?? '?').isNotEmpty 
                                ? (match.player2Name ?? '?')[0].toUpperCase() 
                                : '?',
                            style: TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.bold,
                              color: isP2Winner ? Colors.amber.shade800 : Colors.grey.shade600,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
