import 'dart:math' show min, max;

import 'package:flutter/material.dart';
import 'package:tennis_tournament/core/sharing/widgets/share_button.dart';
import 'package:tennis_tournament/core/analytics/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/match_card.dart';

import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/tournaments/application/tournament_providers.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/painters/bracket_painter.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/group_standings_view.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

final bracketMatchesProvider = StreamProvider.family<List<TennisMatch>, String>((ref, tournamentId) {
  return ref.watch(matchRepositoryProvider).watchMatchesForTournament(tournamentId);
});

// Top-level helper so both the interactive view and the share widget can use it.
double _calculateY(int round, int index, double cardHeight, double margin) {
  final slotHeight = cardHeight + margin;
  final slotsPerMatch = 1 << (round - 1); // 2^(r-1)
  final blockTop = index * slotsPerMatch * slotHeight;
  final blockHeight = slotsPerMatch * slotHeight;
  final center = blockTop + blockHeight / 2;
  return center - cardHeight / 2;
}

class BracketView extends ConsumerWidget {
  final Tournament tournament;

  const BracketView({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(tournamentCategoriesProvider(tournament.id));

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noCategoriesCreateFirst));
        }

        final sortedCategories = [...categories]..sort((a, b) => a.name.compareTo(b.name));

        return DefaultTabController(
          length: sortedCategories.length,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  isScrollable: true,
                  tabs: sortedCategories.map((c) => Tab(text: c.name)).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: sortedCategories.map((c) {
                    // For Open Tennis and Americano modes, show group standings view
                    if (tournament.tournamentType == 'openTennis' || tournament.tournamentType == 'americano') {
                      return _OpenTennisTabContent(
                        tournament: tournament,
                        categoryId: c.id,
                      );
                    }
                    // For Mata-Mata mode, show traditional bracket
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
      error: (err, stack) => Center(child: Text(AppLocalizations.of(context)!.errorOccurred(err.toString()))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// For Open Tennis mode: shows Groups and Playoff as sub-tabs.
/// Groups tab is always visible. Playoff tab appears once playoff matches exist.
class _OpenTennisTabContent extends ConsumerWidget {
  final Tournament tournament;
  final String categoryId;

  const _OpenTennisTabContent({
    required this.tournament,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final matchesAsync = ref.watch(bracketMatchesProvider(tournament.id));

    return matchesAsync.when(
      data: (allMatches) {
        final categoryMatches = allMatches.where((m) => m.categoryId == categoryId).toList();
        final isAmericano = tournament.tournamentType == 'americano';

        // For Americano: Bracket tab appears as soon as Deciders are generated,
        // because Deciders ARE round 1 of the bracket tree.
        // For Open Tennis: tab appears when Playoff R* matches exist.
        final hasPlayoffMatches = isAmericano
            ? categoryMatches.any((m) => m.round.startsWith('Decider') || m.round.startsWith('Playoff'))
            : categoryMatches.any((m) => m.round.startsWith('Playoff'));

        final tabCount = hasPlayoffMatches ? 2 : 1;

        return DefaultTabController(
          length: tabCount,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: TabBar(
                  isScrollable: false,
                  tabs: [
                    Tab(text: loc.groups),
                    if (hasPlayoffMatches)
                      Tab(text: loc.bracket),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    GroupStandingsView(
                      tournamentId: tournament.id,
                      categoryId: categoryId,
                      tournament: tournament,
                    ),
                    if (hasPlayoffMatches)
                      _SingleBracketView(
                        tournamentId: tournament.id,
                        tournamentName: tournament.name,
                        categoryId: categoryId,
                        playoffOnly: true,
                        isAmericano: isAmericano,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.errorOccurred(e.toString()))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SingleBracketView extends ConsumerStatefulWidget {
  final String tournamentId;
  final String tournamentName;
  final String categoryId;
  final bool playoffOnly;
  final bool isAmericano;

  const _SingleBracketView({
    required this.tournamentId,
    required this.tournamentName,
    required this.categoryId,
    this.playoffOnly = false,
    this.isAmericano = false,
  });

  @override
  ConsumerState<_SingleBracketView> createState() => _SingleBracketViewState();
}

class _SingleBracketViewState extends ConsumerState<_SingleBracketView> {
  final _transformController = TransformationController();
  bool _initialTransformSet = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  // ── Transform helpers ──────────────────────────────────────────────────────

  void _fitAll(Size viewport, double totalWidth, double totalHeight) {
    const padding = 40.0;
    final scaleX = (viewport.width - padding * 2) / totalWidth;
    final scaleY = (viewport.height - padding * 2) / totalHeight;
    final scale = min(scaleX, scaleY).clamp(0.1, 3.0);
    final scaledW = totalWidth * scale;
    final scaledH = totalHeight * scale;
    final tx = (viewport.width - scaledW) / 2;
    final ty = (viewport.height - scaledH) / 2;
    _transformController.value = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, tx)
      ..setEntry(1, 3, ty);
  }

  void _centerOngoing(
    Size viewport,
    List<TennisMatch> matches,
    double totalWidth,
    double totalHeight,
    double cardWidth,
    double cardHeight,
    double gap,
    double margin,
    double breathingPad,
  ) {
    // Priority: Started → Confirmed/Scheduled → any non-Finished → fit all
    var targets = matches.where((m) => m.status == 'Started').toList();
    if (targets.isEmpty) {
      targets = matches.where((m) => m.status == 'Confirmed' || m.status == 'Scheduled').toList();
    }
    if (targets.isEmpty) {
      targets = matches.where((m) => m.status != 'Finished').toList();
    }
    if (targets.isEmpty) {
      _fitAll(viewport, totalWidth, totalHeight);
      return;
    }

    // Bounding box of ongoing cards (in canvas coordinates, including breathingPad offset)
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final m in targets) {
      final round = int.tryParse(m.round) ?? 1;
      final x = (round - 1) * (cardWidth + gap) + breathingPad;
      final y = _calculateY(round, m.matchIndex, cardHeight, margin) + breathingPad;
      minX = min(minX, x);
      minY = min(minY, y);
      maxX = max(maxX, x + cardWidth);
      maxY = max(maxY, y + cardHeight);
    }

    const focusPad = 80.0;
    final contentW = (maxX - minX) + focusPad * 2;
    final contentH = (maxY - minY) + focusPad * 2;
    final scaleX = viewport.width / contentW;
    final scaleY = viewport.height / contentH;
    final scale = min(scaleX, scaleY).clamp(0.3, 2.0);

    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final tx = viewport.width / 2 - centerX * scale;
    final ty = viewport.height / 2 - centerY * scale;

    _transformController.value = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, tx)
      ..setEntry(1, 3, ty);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(bracketMatchesProvider(widget.tournamentId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserId = currentUserAsync.asData?.value?.id;

    return matchesAsync.when(
      data: (allMatches) {
        var matches = allMatches.where((m) => m.categoryId == widget.categoryId).toList();

        // For playoff-only mode, filter to non-group matches and remap rounds to numeric
        if (widget.playoffOnly) {
          if (widget.isAmericano) {
            // Americano bracket: Deciders ARE round 1, Playoff R1 → round 2, etc.
            // Sort deciders by group name (A, B, C…) so their bracket positions are stable.
            final deciderList = matches
                .where((m) => m.round.startsWith('Decider'))
                .toList()
              ..sort((a, b) => a.round.compareTo(b.round));
            final playoffList = matches
                .where((m) => m.round.startsWith('Playoff'))
                .toList();

            final remapped = <TennisMatch>[];

            // Place each decider in round 1 with sequential matchIndex
            for (int i = 0; i < deciderList.length; i++) {
              remapped.add(deciderList[i].copyWith(round: '1', matchIndex: i));
            }

            // Shift playoff rounds: Playoff R1 → '2', Playoff R2 → '3', etc.
            for (final m in playoffList) {
              final n = int.tryParse(m.round.replaceFirst('Playoff R', '')) ?? 1;
              remapped.add(m.copyWith(round: '${n + 1}'));
            }

            // Connect each decider to the first playoff round via nextMatchId.
            // Decider at index i feeds into playoff match at index i÷2.
            final firstPlayoffRound = remapped
                .where((m) => m.round == '2')
                .toList()
              ..sort((a, b) => a.matchIndex.compareTo(b.matchIndex));

            matches = remapped.map((m) {
              if (m.round == '1' && firstPlayoffRound.isNotEmpty) {
                final nextIdx = m.matchIndex ~/ 2;
                if (nextIdx < firstPlayoffRound.length) {
                  return m.copyWith(nextMatchId: firstPlayoffRound[nextIdx].id);
                }
              }
              return m;
            }).toList();
          } else {
            // Open Tennis: filter out Group/Cross rounds, remap Playoff R1 → 1, etc.
            matches = matches
                .where((m) => m.round.startsWith('Playoff'))
                .map((m) {
                  final n = m.round.replaceFirst('Playoff R', '');
                  return m.copyWith(round: n);
                })
                .toList();
          }
        }

        if (matches.isEmpty) {
          final participantsAsync = ref.watch(participantsProvider(widget.tournamentId));
          return participantsAsync.when(
            data: (participants) {
              final categoryParticipants = participants
                  .where((p) => p.categoryId == widget.categoryId && p.status == 'approved')
                  .toList();

              if (categoryParticipants.isEmpty) {
                return Center(child: Text(AppLocalizations.of(context)!.noMatchesNoPlayers));
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.noMatchesGenerated),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.playersInCategory(categoryParticipants.length),
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
            error: (e, s) => Center(child: Text(AppLocalizations.of(context)!.errorLoadingPlayers(e.toString()))),
          );
        }

        // ── Layout maths ──────────────────────────────────────────────────
        final rounds = <int, List<TennisMatch>>{};
        for (var match in matches) {
          final r = int.tryParse(match.round) ?? 0;
          if (r > 0) rounds.putIfAbsent(r, () => []).add(match);
        }
        final sortedRounds = rounds.keys.toList()..sort();
        final maxRound = sortedRounds.isNotEmpty ? sortedRounds.last : 0;
        for (var r in sortedRounds) {
          rounds[r]!.sort((a, b) => a.matchIndex.compareTo(b.matchIndex));
        }

        const cardHeight = 100.0;
        const cardWidth = 220.0;
        const gap = 50.0;
        const margin = 20.0;
        const breathingPad = 48.0; // breathing room around bracket

        final totalSlots = 1 << (maxRound - 1);
        final totalHeight = totalSlots * (cardHeight + margin) + breathingPad * 2;
        final totalWidth = maxRound * (cardWidth + gap) + breathingPad * 2;

        // ── Share widget (static, no InteractiveViewer) ───────────────────
        final shareWidgetContent = Theme(
          data: ThemeData.light(),
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: totalWidth + 100,
                height: totalHeight + 150,
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Row(
                        children: [
                          Icon(Icons.sports_tennis, color: Colors.white.withValues(alpha: 0.1), size: 40),
                          const SizedBox(width: 8),
                          Text(
                            widget.tournamentName,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                  isFinal: int.parse(match.round) == maxRound &&
                                      matches.where((m) => m.round == match.round).length == 1,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.share, size: 16, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('tennis-tournment.web.app',
                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        // ── Interactive bracket ───────────────────────────────────────────
        return LayoutBuilder(
          builder: (context, constraints) {
            final viewport = Size(constraints.maxWidth, constraints.maxHeight);

            // Auto-zoom to ongoing matches on first render
            if (!_initialTransformSet && matches.isNotEmpty) {
              _initialTransformSet = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _centerOngoing(
                  viewport, matches,
                  totalWidth, totalHeight,
                  cardWidth, cardHeight,
                  gap, margin, breathingPad,
                );
              });
            }

            return Stack(
              children: [
                // ── Zoomable / pannable bracket ──────────────────────────
                InteractiveViewer(
                  transformationController: _transformController,
                  constrained: false,
                  minScale: 0.1,
                  maxScale: 3.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: Container(
                    color: Theme.of(context).cardColor,
                    width: totalWidth,
                    height: totalHeight,
                    child: Padding(
                      padding: const EdgeInsets.all(breathingPad),
                      child: Stack(
                        children: [
                          // Connection lines
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
                          // Match cards
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
                                      onTap: () => context.push('/matches/${match.id}'),
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

                // ── Share button ─────────────────────────────────────────
                Positioned(
                  top: 16,
                  right: 16,
                  child: Builder(
                    builder: (context) {
                      final loc = AppLocalizations.of(context)!;
                      return ShareButton(
                        shareSubject: loc.tournamentBracket,
                        shareUrl: 'https://tennis-tournment.web.app/t/${widget.tournamentId}',
                        label: loc.shareBracket,
                        onShare: () {
                          ref.read(analyticsServiceProvider).logShareBracket(
                            tournamentName: widget.tournamentName,
                          );
                        },
                        shareWidget: shareWidgetContent,
                      );
                    },
                  ),
                ),

                // ── Zoom controls ────────────────────────────────────────
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ZoomButton(
                        icon: Icons.fit_screen,
                        tooltip: 'Zoom out (fit all)',
                        onTap: () => _fitAll(viewport, totalWidth, totalHeight),
                      ),
                      const SizedBox(height: 8),
                      _ZoomButton(
                        icon: Icons.center_focus_strong,
                        tooltip: 'Center active matches',
                        onTap: () => _centerOngoing(
                          viewport, matches,
                          totalWidth, totalHeight,
                          cardWidth, cardHeight,
                          gap, margin, breathingPad,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text(AppLocalizations.of(context)!.errorOccurred(err.toString()))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ZoomButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
