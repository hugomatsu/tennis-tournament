import 'package:flutter/material.dart';
import 'package:tennis_tournament/core/sharing/widgets/share_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/match_card.dart';

import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/tournaments/application/tournament_providers.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/painters/bracket_painter.dart';

final bracketMatchesProvider = StreamProvider.family<List<TennisMatch>, String>((ref, tournamentId) {
  return ref.watch(matchRepositoryProvider).watchMatchesForTournament(tournamentId);
});

class BracketView extends ConsumerWidget {
  final Tournament tournament;

  const BracketView({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(tournamentCategoriesProvider(tournament.id));

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('No categories found. Please create a category.'));
        }

        return DefaultTabController(
          length: categories.length,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  isScrollable: true,
                  tabs: categories.map((c) => Tab(text: c.name)).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: categories.map((c) {
                    return _SingleBracketView(
                      tournamentId: tournament.id,
                      tournamentName: tournament.name,
                      categoryId: c.id,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading categories: $err')),
    );
  }
}

class _SingleBracketView extends ConsumerWidget {
  final String tournamentId;
  final String tournamentName;
  final String categoryId;

  const _SingleBracketView({
    required this.tournamentId,
    required this.tournamentName,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(bracketMatchesProvider(tournamentId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserId = currentUserAsync.asData?.value?.id;

    return matchesAsync.when(
      data: (allMatches) {
        // Filter matches by category
        final matches = allMatches.where((m) => m.categoryId == categoryId).toList();

        if (matches.isEmpty) {
      final participantsAsync = ref.watch(participantsProvider(tournamentId));
      return participantsAsync.when(
        data: (participants) {
          final categoryParticipants = participants
              .where((p) => p.categoryId == categoryId && p.status == 'approved')
              .toList();
          
          if (categoryParticipants.isEmpty) {
            return const Center(child: Text('No matches generated and no players in this category yet.'));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No matches generated yet.'),
                const SizedBox(height: 16),
                Text(
                  'Players in this category (${categoryParticipants.length}):',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: categoryParticipants.map((p) {
                    final url = p.avatarUrls.firstOrNull;
                    return Chip(
                    avatar: CircleAvatar(
                      backgroundImage: url != null ? NetworkImage(url) : null,
                      child: url == null ? Text(p.name.isNotEmpty ? p.name[0] : '?') : null,
                    ),
                    label: Text(p.name),
                  );
                  }).toList(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading players: $e')),
      );
    }

        // Group matches by round
        final rounds = <int, List<TennisMatch>>{};
        for (var match in matches) {
          final r = int.tryParse(match.round) ?? 0;
          if (r > 0) {
            rounds.putIfAbsent(r, () => []).add(match);
          }
        }

        // Sort rounds
        final sortedRounds = rounds.keys.toList()..sort();
        final maxRound = sortedRounds.isNotEmpty ? sortedRounds.last : 0;

        // Sort matches within rounds by index
        for (var r in sortedRounds) {
          rounds[r]!.sort((a, b) => a.matchIndex.compareTo(b.matchIndex));
        }

        const cardHeight = 100.0;
        const cardWidth = 220.0;
        const gap = 50.0; // Horizontal gap
        const margin = 20.0; // Vertical margin between slots in Round 1

        // Calculate total size
        final totalSlots = 1 << (maxRound - 1);
        final totalHeight = totalSlots * (cardHeight + margin) + 100; // Extra padding
        final totalWidth = maxRound * (cardWidth + gap) + 100;

        return Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container( // Wrap in Container for white background capture default
                  color: Theme.of(context).cardColor, 
                  width: totalWidth,
                  height: totalHeight,
                  child: Stack(
                    children: [
                      // 1. Painter for lines
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BracketPainter(
                            matches: matches,
                            cardHeight: cardHeight,
                            cardWidth: cardWidth,
                            gap: gap,
                            margin: margin,
                          ),
                        ),
                      ),
                      // 2. Matches
                      ...sortedRounds.map((r) {
                        final roundMatches = rounds[r]!;
                        final xOffset = (r - 1) * (cardWidth + gap);
                        
                        return Positioned(
                          left: xOffset,
                          top: 0,
                          bottom: 0,
                          width: cardWidth,
                          child: Stack(
                            children: roundMatches.map((match) {
                              final yOffset = _calculateY(r, match.matchIndex, cardHeight, margin);
                              final isFinal = r == maxRound && roundMatches.length == 1;

                              return Positioned(
                                top: yOffset,
                                left: 0,
                                child: MatchCard(
                                  match: match,
                                  width: cardWidth,
                                  height: cardHeight,
                                  isFinal: isFinal,
                                  currentUserId: currentUserId,
                                  onTap: () {
                                    context.push('/matches/${match.id}');
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
             Positioned(
              top: 16,
              right: 16,
              child: ShareButton(
                shareSubject: 'Tournament Bracket',
                shareUrl: 'https://entresets.com/t/$tournamentId', // TODO: Dynamic host
                label: 'Share Bracket',
                shareWidget: Theme(
                  data: ThemeData.light(),
                  child: Builder(
                    builder: (context) {
                      return Container(
                        width: totalWidth + 100,
                        height: totalHeight + 150,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                          ),
                        ),
                        child: Stack(
                          children: [
                             // Branding Header
                             Positioned(
                               top: 20,
                               left: 20,
                               child: Row(
                                 children: [
                                   Icon(Icons.sports_tennis, color: Colors.white.withOpacity(0.1), size: 40),
                                   const SizedBox(width: 8),
                                   Text(
                                     tournamentName,
                                     style: TextStyle(
                                       fontSize: 32,
                                       fontWeight: FontWeight.w900,
                                       color: Colors.white.withOpacity(0.1),
                                     ),
                                   ),
                                 ],
                               ),
                             ),

                            // Centered Bracket
                            Positioned(
                              left: 50,
                              top: 80,
                              child: SizedBox(
                                width: totalWidth,
                                height: totalHeight,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: BracketPainter(
                                          matches: matches,
                                          cardHeight: cardHeight,
                                          cardWidth: cardWidth,
                                          gap: gap,
                                          margin: margin,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ),
                                    for (var match in matches)
                                      Positioned(
                                        left: (int.parse(match.round) - 1) * (cardWidth + gap),
                                        top: _calculateY(int.parse(match.round), match.matchIndex, cardHeight, margin),
                                        child: MatchCard(
                                          match: match,
                                          width: cardWidth,
                                          height: cardHeight,
                                          isFinal: int.parse(match.round) == maxRound && matches.where((m) => m.round == match.round).length == 1,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Footer Branding
                            Positioned(
                                bottom: 20,
                                right: 30,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.share, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      const Text('tennis-tournament.web.app', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  double _calculateY(int round, int index, double cardHeight, double margin) {
    final slotHeight = cardHeight + margin;
    final slotsPerMatch = 1 << (round - 1); // 2^(r-1)
    
    final blockTop = index * slotsPerMatch * slotHeight;
    final blockHeight = slotsPerMatch * slotHeight;
    final center = blockTop + blockHeight / 2;
    
    return center - cardHeight / 2;
  }

}
