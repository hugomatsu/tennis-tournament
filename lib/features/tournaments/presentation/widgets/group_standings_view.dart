import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/tournaments/application/americano_service.dart';
import 'package:tennis_tournament/features/tournaments/application/open_tennis_service.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/group_standing.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/core/sharing/widgets/share_preview_screen.dart';
import 'package:tennis_tournament/core/theme/tournament_type_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tennis_tournament/l10n/app_localizations.dart';

String _randomScore() {
  const scores = [
    '6-2, 6-1', '6-3, 6-2', '6-4, 6-3', '6-4, 7-5', '7-5, 6-3',
    '6-3, 6-4', '7-6, 6-4', '6-1, 6-3', '6-2, 7-5', '6-4, 6-2',
    '6-4, 4-6, 10-7', '7-5, 5-7, 10-8', '6-3, 3-6, 10-6',
    '6-2, 4-6, 10-5', '7-6, 6-7, 10-8',
  ];
  return scores[Random().nextInt(scores.length)];
}

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

        // Sort each group by points (descending), then wins, then name (alpha)
        for (final group in grouped.values) {
          group.sort((a, b) {
            final pointsCompare = b.points.compareTo(a.points);
            if (pointsCompare != 0) return pointsCompare;
            final winsCompare = b.wins.compareTo(a.wins);
            if (winsCompare != 0) return winsCompare;
            return a.participantName.compareTo(b.participantName);
          });
        }

        return grouped;
      });
});

/// Widget to display Open Tennis mode group standings and matches
class GroupStandingsView extends ConsumerStatefulWidget {
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
  ConsumerState<GroupStandingsView> createState() => _GroupStandingsViewState();
}

class _GroupStandingsViewState extends ConsumerState<GroupStandingsView> {
  String get tournamentId => widget.tournamentId;
  String get categoryId => widget.categoryId;
  Tournament get tournament => widget.tournament;

  void _showPlayerMatchesSheet(BuildContext context, String playerName, List<TennisMatch> allMatches) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PlayerMatchesSheet(
        playerName: playerName,
        matches: allMatches,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final standingsAsync = ref.watch(groupStandingsStreamProvider((tournamentId, categoryId)));
    final matchesStream = ref.watch(matchRepositoryProvider).watchMatchesForTournament(tournamentId);
    final currentUser = ref.watch(currentUserProvider).value;
    final currentUserId = currentUser?.id;
    final isAdmin = currentUser != null &&
        (tournament.ownerId == currentUser.id || tournament.adminIds.contains(currentUser.id));
    final isAmericano = tournament.tournamentType == 'americano';
    final advancePositions = isAmericano ? 2 : tournament.advanceCount;

    // Build info header widget (will be placed inside the scrollable list)
    final typeTheme = TournamentTypeTheme.of(tournament.tournamentType);
    final infoHeader = Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: typeTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(typeTheme.icon, color: typeTheme.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAmericano ? loc.americanoMode : loc.openTennisMode,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: typeTheme.color,
                  ),
                ),
              ),
              if (isAdmin)
                StreamBuilder<List<TennisMatch>>(
                  stream: matchesStream,
                  builder: (context, snap) {
                    final pending = (snap.data ?? [])
                        .where((m) =>
                            m.categoryId == categoryId &&
                            m.status != 'Completed' &&
                            m.status != 'Finished' &&
                            m.player1Name.isNotEmpty &&
                            (m.player2Name?.isNotEmpty ?? false))
                        .toList();
                    if (pending.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.casino_outlined),
                      tooltip: loc.fillRandomResults,
                      color: isAmericano ? Colors.purple : Colors.blue,
                      onPressed: () => _fillRandomResults(context, ref, pending, loc),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          if ((tournament.matchRules['scoringMode'] as String? ?? 'flat') == 'variable')
            Text(
              loc.variableScoringTable(
                (tournament.matchRules['pointsWin2_0'] as int?) ?? 4,
                (tournament.matchRules['pointsWin2_1'] as int?) ?? 3,
                (tournament.matchRules['pointsWinWO'] as int?) ?? 2,
                (tournament.matchRules['pointsLoss1_2'] as int?) ?? 1,
              ),
              style: const TextStyle(fontSize: 13),
            )
          else
            Text(
              loc.pointsPerWinLabel(tournament.pointsPerWin),
              style: const TextStyle(fontSize: 14),
            ),
        ],
      ),
    );

    // Build progress widget (will be placed inside the scrollable list)
    final progressWidget = StreamBuilder<List<TennisMatch>>(
          stream: matchesStream,
          builder: (context, matchSnapshot) {
            final allMatches = matchSnapshot.data ?? [];
            final categoryMatches = allMatches.where((m) => m.categoryId == categoryId).toList();

            if (tournament.tournamentType == 'americano') {
              final americanoMatches = categoryMatches.where((m) => m.round == 'Americano').toList();
              final deciderMatches = categoryMatches.where((m) => m.round.startsWith('Decider')).toList();
              final allAmericanoComplete = americanoMatches.isNotEmpty &&
                  americanoMatches.every((m) => m.status == 'Completed' || m.status == 'Finished');

              if (allAmericanoComplete && deciderMatches.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FilledButton.icon(
                    onPressed: () => _generateGroupDeciders(context, ref),
                    icon: const Icon(Icons.sports_tennis),
                    label: Text(loc.generateGroupDeciders),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                );
              }

              if (deciderMatches.isNotEmpty) {
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
                      Expanded(child: Text(loc.playoffBracketGenerated, style: const TextStyle(color: Colors.green))),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            }

            // openTennis logic
            final groupMatches = categoryMatches.where((m) => m.round.startsWith('Group') || m.round.startsWith('Cross')).toList();
            final playoffMatches = categoryMatches.where((m) => !m.round.startsWith('Group') && !m.round.startsWith('Cross')).toList();

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
        );

    // Single scrollable list: info header + progress + group standings
    return standingsAsync.when(
      data: (groupedStandings) {
        if (groupedStandings.isEmpty) {
          return ListView(
            children: [
              infoHeader,
              progressWidget,
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: Text(loc.noStandingsYet)),
              ),
            ],
          );
        }

        return StreamBuilder<List<TennisMatch>>(
          stream: matchesStream,
          builder: (context, snapshot) {
            final allMatches = snapshot.data ?? [];
            final categoryMatches = allMatches
                .where((m) => m.categoryId == categoryId)
                .toList();

            // Collect cross-group matches separately
            final crossMatches = categoryMatches
                .where((m) => m.round.startsWith('Cross'))
                .toList();
            final hasCrossMatches = crossMatches.isNotEmpty;

            final americanoMatches = categoryMatches
                .where((m) => m.round == 'Americano')
                .toList();
            final deciderMatches = categoryMatches
                .where((m) => m.round.startsWith('Decider'))
                .toList();
            final isAmericanoMode = tournament.tournamentType == 'americano';
            final hasAmericanoMatches = americanoMatches.isNotEmpty;
            final hasDeciderMatches = deciderMatches.isNotEmpty;

            // Sort group keys alphabetically (A, B, C …)
            final sortedGroupKeys = groupedStandings.keys.toList()..sort();

            // 2 fixed items (info + progress) + groups + optional match sections
            final fixedCount = 2;
            final groupCount = sortedGroupKeys.length;
            final extraCount = (hasCrossMatches ? 1 : 0) +
                (hasAmericanoMatches ? 1 : 0) +
                (hasDeciderMatches ? 1 : 0);
            final totalItems = fixedCount + groupCount + extraCount;

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: totalItems,
              itemBuilder: (context, index) {
                // Item 0: info header
                if (index == 0) return infoHeader;
                // Item 1: progress widget
                if (index == 1) return progressWidget;

                // Remaining items: groups + extra cards
                final listIndex = index - fixedCount;
                int extraStart = groupCount;

                if (hasCrossMatches && listIndex == extraStart) {
                  final allCrossComplete = crossMatches.every(
                      (m) => m.status == 'Completed' || m.status == 'Finished');
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _CrossGroupCard(
                      matches: crossMatches,
                      tournament: tournament,
                      allMatchesCompleted: allCrossComplete,
                    ),
                  );
                }
                if (hasCrossMatches) extraStart++;

                if (hasAmericanoMatches && listIndex == extraStart) {
                  final allComplete = americanoMatches.every(
                      (m) => m.status == 'Completed' || m.status == 'Finished');
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _AmericanoMatchesCard(
                      matches: americanoMatches,
                      allMatchesCompleted: allComplete,
                    ),
                  );
                }
                if (hasAmericanoMatches) extraStart++;

                if (hasDeciderMatches && listIndex == extraStart) {
                  final allComplete = deciderMatches.every(
                      (m) => m.status == 'Completed' || m.status == 'Finished');
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _DeciderMatchesCard(
                      matches: deciderMatches,
                      allMatchesCompleted: allComplete,
                    ),
                  );
                }

                final groupId = sortedGroupKeys[listIndex];
                final standings = groupedStandings[groupId]!;
                // For Americano, no intra-group matches — pass empty list
                final groupMatches = isAmericanoMode
                    ? <TennisMatch>[]
                    : categoryMatches
                        .where((m) => m.round == 'Group $groupId')
                        .toList();

                final allGroupMatchesComplete = isAmericanoMode
                    ? americanoMatches.isNotEmpty && americanoMatches.every((m) => m.status == 'Completed' || m.status == 'Finished')
                    : groupMatches.isNotEmpty && groupMatches.every((m) => m.status == 'Completed' || m.status == 'Finished');

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _GroupCard(
                    groupId: groupId,
                    standings: standings,
                    matches: groupMatches,
                    tournament: tournament,
                    allMatchesCompleted: allGroupMatchesComplete,
                    currentUserId: currentUserId,
                    advancePositions: advancePositions,
                    onPlayerTap: (name) => _showPlayerMatchesSheet(context, name, americanoMatches),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(loc.errorOccurred(e.toString()))),
    );
  }

  Future<void> _fillRandomResults(
    BuildContext context,
    WidgetRef ref,
    List<TennisMatch> pending,
    AppLocalizations loc,
  ) async {
    final repo = ref.read(matchRepositoryProvider);
    for (final match in pending) {
      final winner = Random().nextBool() ? match.player1Name : match.player2Name!;
      await repo.updateMatchScore(match.id, _randomScore(), winner);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.randomResultsFilled(pending.length))),
      );
    }
  }

  Future<void> _generateGroupDeciders(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final loc = AppLocalizations.of(context)!;
    try {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(loc.generatingPlayoffBracket)));
      final americanoService = ref.read(americanoServiceProvider);
      final categories = await ref.read(tournamentRepositoryProvider).getCategories(tournamentId);
      final category = categories.firstWhere((c) => c.id == categoryId);
      final deciderMatches = await americanoService.generateGroupDeciders(tournament, category);
      await ref.read(matchRepositoryProvider).createMatches(deciderMatches);
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(loc.groupDecidersGenerated(deciderMatches.length))));
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(loc.errorGeneratingDeciders(e.toString()))));
    }
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
  final String? currentUserId;
  final int advancePositions;
  final void Function(String)? onPlayerTap;

  const _GroupCard({
    required this.groupId,
    required this.standings,
    required this.matches,
    required this.tournament,
    required this.allMatchesCompleted,
    this.currentUserId,
    this.advancePositions = 1,
    this.onPlayerTap,
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
                        Text(loc.winsShort, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(loc.lossesShort, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(loc.playedShort, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(loc.pointsShort, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    ...standings.asMap().entries.map((entry) {
                      final standing = entry.value;
                      final rank = entry.key + 1;
                      final isWinner = rank == 1 && allMatchesCompleted;
                      final isAdvancing = rank <= advancePositions && !allMatchesCompleted;
                      final isCurrentUser = currentUserId != null &&
                          standing.participantUserIds.contains(currentUserId);
                      final avatarUrl = standing.participantAvatarUrls.isNotEmpty
                          ? standing.participantAvatarUrls.first
                          : null;

                      Color? rowColor;
                      if (isWinner) {
                        rowColor = Colors.amber.withValues(alpha: 0.15);
                      } else if (isCurrentUser) {
                        rowColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.10);
                      } else if (isAdvancing) {
                        rowColor = Colors.green.withValues(alpha: 0.08);
                      }

                      return TableRow(
                        decoration: BoxDecoration(
                          color: rowColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onPlayerTap?.call(standing.participantName),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isWinner
                                          ? Colors.amber.withValues(alpha: 0.5)
                                          : isAdvancing
                                              ? Colors.green.withValues(alpha: 0.35)
                                              : rank == 1
                                                  ? Colors.amber.withValues(alpha: 0.3)
                                                  : Colors.grey.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$rank',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isWinner ? Colors.amber.shade900 : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: isWinner
                                        ? BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.amber.shade400, width: 2),
                                          )
                                        : null,
                                    child: CircleAvatar(
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
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
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
                                        if (isCurrentUser) ...[
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!.youSuffix2,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text('${standing.wins}', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: isWinner ? FontWeight.bold : FontWeight.normal)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text('${standing.losses}', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: isWinner ? FontWeight.bold : FontWeight.normal)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text('${standing.matchesPlayed}', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: isWinner ? FontWeight.bold : FontWeight.normal)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              '${standing.points}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isWinner ? Colors.amber.shade800 : null,
                              ),
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
                  Text(loc.matches, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...matches.map((match) => _MatchTile(match: match, groupId: groupId)),
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
                  'tennis-tournment.web.app',
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

class _CrossGroupCard extends StatelessWidget {
  final List<TennisMatch> matches;
  final Tournament tournament;
  final bool allMatchesCompleted;

  const _CrossGroupCard({
    required this.matches,
    required this.tournament,
    required this.allMatchesCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: Colors.deepPurple.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  loc.crossGroupMatches,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${matches.length} ${loc.matches.toLowerCase()}',
                  style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade400),
                ),
              ],
            ),
          ),
          // Matches
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: matches.asMap().entries.map((e) {
                // Extract group letters from round 'Cross A-B'
                final roundLabel = e.value.round.replaceFirst('Cross ', '');
                return _CrossMatchTile(match: e.value, roundLabel: roundLabel, matchNumber: e.key + 1);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmericanoMatchesCard extends StatelessWidget {
  final List<TennisMatch> matches;
  final bool allMatchesCompleted;

  const _AmericanoMatchesCard({
    required this.matches,
    required this.allMatchesCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz,
                    color: allMatchesCompleted ? Colors.green : Colors.purple,
                    size: 18),
                const SizedBox(width: 8),
                Text(
                  loc.americanoMatchesPhase,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: allMatchesCompleted ? Colors.green : Colors.purple,
                  ),
                ),
                const Spacer(),
                Text(
                  '${matches.where((m) => m.status == 'Completed' || m.status == 'Finished').length}/${matches.length}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: matches.asMap().entries.map((e) =>
                _CrossMatchTile(match: e.value, roundLabel: '', matchNumber: e.key + 1),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeciderMatchesCard extends StatelessWidget {
  final List<TennisMatch> matches;
  final bool allMatchesCompleted;

  const _DeciderMatchesCard({
    required this.matches,
    required this.allMatchesCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.sports_tennis,
                    color: allMatchesCompleted ? Colors.green : Colors.orange,
                    size: 18),
                const SizedBox(width: 8),
                Text(
                  loc.deciderPhase,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: allMatchesCompleted ? Colors.green : Colors.orange,
                  ),
                ),
                const Spacer(),
                Text(
                  '${matches.where((m) => m.status == 'Completed' || m.status == 'Finished').length}/${matches.length}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: matches.asMap().entries.map((e) =>
                _CrossMatchTile(match: e.value, roundLabel: '', matchNumber: e.key + 1),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrossMatchTile extends StatelessWidget {
  final TennisMatch match;
  final String roundLabel;
  final int? matchNumber;

  const _CrossMatchTile({required this.match, required this.roundLabel, this.matchNumber});

  @override
  Widget build(BuildContext context) {
    final isCompleted = match.status == 'Completed' || match.status == 'Finished';
    final hasWinner = match.winner != null && match.winner!.isNotEmpty;
    final isP1Winner = match.winner == match.player1Name;
    final isP2Winner = match.winner == match.player2Name;
    final p1Avatar = match.player1AvatarUrls.isNotEmpty ? match.player1AvatarUrls.first : null;
    final p2Avatar = match.player2AvatarUrls.isNotEmpty ? match.player2AvatarUrls.first : null;

    return InkWell(
      onTap: () => context.push('/matches/${match.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: hasWinner ? Colors.amber.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            // Match number + Round badge
            if (matchNumber != null)
              Container(
                width: 28,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 6),
                child: Text(
                  '#$matchNumber',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                ),
              ),
            if (roundLabel.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  roundLabel,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade600),
                ),
              ),
            // Player 1
            Expanded(
              child: Row(
                children: [
                  Container(
                    decoration: isP1Winner
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber.shade400, width: 2),
                          )
                        : null,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: p1Avatar != null ? NetworkImage(p1Avatar) : null,
                      child: p1Avatar == null
                          ? Text(
                              match.player1Name.isNotEmpty ? match.player1Name[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
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
            // Score/Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isCompleted
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: (match.score ?? 'W').split(', ').map((set) => Text(
                        set,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                          height: 1.3,
                        ),
                      )).toList(),
                    )
                  : Text(
                      match.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
            ),
            // Player 2
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                  const SizedBox(width: 6),
                  Container(
                    decoration: isP2Winner
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber.shade400, width: 2),
                          )
                        : null,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: p2Avatar != null ? NetworkImage(p2Avatar) : null,
                      child: p2Avatar == null
                          ? Text(
                              (match.player2Name ?? '?').isNotEmpty ? (match.player2Name ?? '?')[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                            )
                          : null,
                    ),
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

class _MatchTile extends StatelessWidget {
  final TennisMatch match;
  final String groupId;

  const _MatchTile({required this.match, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final isCompleted = match.status == 'Completed' || match.status == 'Finished';
    final hasWinner = match.winner != null && match.winner!.isNotEmpty;
    final isP1Winner = match.winner == match.player1Name;
    final isP2Winner = match.winner == match.player2Name;
    final isCrossMatch = match.round.startsWith('Cross');

    // For cross matches like 'Cross A-B', determine which player is the outsider
    // by checking which group letter doesn't match this groupId.
    bool isP1Outsider = false;
    bool isP2Outsider = false;
    if (isCrossMatch) {
      final parts = match.round.replaceFirst('Cross ', '').split('-');
      if (parts.length == 2) {
        isP1Outsider = parts[0] != groupId;
        isP2Outsider = parts[1] != groupId;
      }
    }

    // Get avatar URLs
    final p1Avatar = match.player1AvatarUrls.isNotEmpty ? match.player1AvatarUrls.first : null;
    final p2Avatar = match.player2AvatarUrls.isNotEmpty ? match.player2AvatarUrls.first : null;

    return InkWell(
      onTap: () => context.push('/matches/${match.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isCrossMatch
              ? Colors.deepPurple.withOpacity(0.06)
              : hasWinner
                  ? Colors.amber.withOpacity(0.05)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCrossMatch
                ? Colors.deepPurple.withOpacity(0.25)
                : Colors.grey.withOpacity(0.15),
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
                  // Outsider icon
                  if (isP1Outsider) ...[
                    Icon(Icons.swap_horiz, size: 14, color: Colors.deepPurple.shade400),
                    const SizedBox(width: 2),
                  ],
                  // Name
                  Expanded(
                    child: Text(
                      match.player1Name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isP1Winner ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        color: isP1Outsider
                            ? Colors.deepPurple
                            : isP1Winner
                                ? Colors.amber.shade800
                                : null,
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
                        color: isP2Outsider
                            ? Colors.deepPurple
                            : isP2Winner
                                ? Colors.amber.shade800
                                : null,
                      ),
                    ),
                  ),
                  // Outsider icon
                  if (isP2Outsider) ...[
                    const SizedBox(width: 2),
                    Icon(Icons.swap_horiz, size: 14, color: Colors.deepPurple.shade400),
                  ],
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

// ---------------------------------------------------------------------------
// Player Matches Sheet
// ---------------------------------------------------------------------------

class _PlayerMatchesSheet extends ConsumerWidget {
  final String playerName;
  final List<TennisMatch> matches;

  const _PlayerMatchesSheet({
    required this.playerName,
    required this.matches,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final currentUser = ref.watch(currentUserProvider).value;

    final playerMatches = matches
        .where((m) => m.player1Name == playerName || m.player2Name == playerName)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playerName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              loc.playerMatchesTitle(playerName),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                ],
              ),
            ),
            // Matches list
            Expanded(
              child: playerMatches.isEmpty
                  ? Center(child: Text(loc.noMatchesForPlayer, style: TextStyle(color: Colors.grey.shade500)))
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: playerMatches.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final match = playerMatches[index];
                        final isFollowing = currentUser != null &&
                            currentUser.followedMatchIds.contains(match.id);
                        final opponent = match.player1Name == playerName
                            ? (match.player2Name ?? 'TBD')
                            : match.player1Name;
                        final isCompleted = match.status == 'Completed' || match.status == 'Finished';
                        final dateStr = DateFormat.MMMd(locale).format(match.time);
                        final timeStr = DateFormat.Hm(locale).format(match.time);

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/matches/${match.id}');
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                // Date/time column
                                SizedBox(
                                  width: 48,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        dateStr,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        timeStr,
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Match info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'vs $opponent',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(width: 8),
                                          if (isCompleted && match.winner != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: match.winner == playerName
                                                    ? Colors.green.withValues(alpha: 0.15)
                                                    : Colors.red.withValues(alpha: 0.10),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                match.winner == playerName ? 'W' : 'L',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: match.winner == playerName
                                                      ? Colors.green.shade700
                                                      : Colors.red.shade700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.sports_tennis, size: 12, color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text(
                                            match.court.isNotEmpty ? match.court : match.round,
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                          ),
                                          if (isCompleted && match.score != null) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              match.score!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Follow button (only for upcoming matches)
                                if (!isCompleted && currentUser != null)
                                  IconButton(
                                    icon: Icon(
                                      isFollowing ? Icons.bookmark : Icons.bookmark_border,
                                      color: isFollowing
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey.shade400,
                                    ),
                                    tooltip: isFollowing ? loc.following : loc.follow,
                                    onPressed: () async {
                                      final newList = isFollowing
                                          ? currentUser.followedMatchIds.where((id) => id != match.id).toList()
                                          : [...currentUser.followedMatchIds, match.id];
                                      await ref.read(playerRepositoryProvider).updateUser(
                                        currentUser.copyWith(followedMatchIds: newList),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Hint
            Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.of(context).padding.bottom + 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    loc.followMatchHint,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
