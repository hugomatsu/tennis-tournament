import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/score/application/score_controller.dart';
import 'package:tennis_tournament/features/score/domain/score_state.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class ScoreCounterScreen extends ConsumerStatefulWidget {
  const ScoreCounterScreen({super.key});

  @override
  ConsumerState<ScoreCounterScreen> createState() => _ScoreCounterScreenState();
}

class _ScoreCounterScreenState extends ConsumerState<ScoreCounterScreen> {
  Timer? _timer;
  bool _fullscreen = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(scoreControllerProvider.notifier).tick();
    });
  }

  void _enterFullscreen() {
    setState(() => _fullscreen = true);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullscreen() {
    setState(() => _fullscreen = false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showLongPressMenu(BuildContext context, WidgetRef ref, bool isA) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.undo),
              title: Text(loc.undo),
              onTap: () {
                Navigator.pop(context);
                ref.read(scoreControllerProvider.notifier).undo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(loc.editPlayers),
              onTap: () {
                Navigator.pop(context);
                _showEditPlayersDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(loc.resetMatch),
              onTap: () {
                Navigator.pop(context);
                _showResetConfirm(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(loc.matchSettings),
              onTap: () {
                Navigator.pop(context);
                _showSetupDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPlayersDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(scoreControllerProvider);
    final ctrlA = TextEditingController(text: state.playerAName);
    final ctrlB = TextEditingController(text: state.playerBName);
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.editPlayers),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ctrlA, decoration: const InputDecoration(labelText: 'Jogador A')),
            const SizedBox(height: 12),
            TextField(controller: ctrlB, decoration: const InputDecoration(labelText: 'Jogador B')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          FilledButton(
            onPressed: () {
              ref.read(scoreControllerProvider.notifier).updatePlayerNames(
                ctrlA.text.trim().isEmpty ? state.playerAName : ctrlA.text.trim(),
                ctrlB.text.trim().isEmpty ? state.playerBName : ctrlB.text.trim(),
              );
              Navigator.pop(context);
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  void _showResetConfirm(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.resetMatch),
        content: Text(loc.resetMatchConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(scoreControllerProvider.notifier).reset();
              _startTimer();
            },
            child: Text(loc.resetMatch),
          ),
        ],
      ),
    );
  }

  void _showSetupDialog(BuildContext context, WidgetRef ref) {
    final s = ref.read(scoreControllerProvider);
    var setsToWin = s.setsToWin;
    var gamesPerSet = s.gamesPerSet;
    var hasAdvantage = s.hasAdvantage;
    var finalSetTiebreak = s.finalSetTiebreak;
    var tiebreakPoints = s.tiebreakPoints;
    var server = s.server;
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(loc.matchSettings),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.setsToWin, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [1, 2, 3].map((v) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$v'),
                      selected: setsToWin == v,
                      onSelected: (_) => setSt(() => setsToWin = v),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                Text(loc.gamesPerSet, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [4, 6, 8].map((v) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$v'),
                      selected: gamesPerSet == v,
                      onSelected: (_) => setSt(() => gamesPerSet = v),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(loc.advantage),
                  value: hasAdvantage,
                  onChanged: (v) => setSt(() => hasAdvantage = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(loc.finalSetTiebreak),
                  value: finalSetTiebreak,
                  onChanged: (v) => setSt(() => finalSetTiebreak = v),
                ),
                if (finalSetTiebreak) ...[
                  Text(loc.tiebreakPoints, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [7, 10].map((v) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$v'),
                        selected: tiebreakPoints == v,
                        onSelected: (_) => setSt(() => tiebreakPoints = v),
                      ),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Text(loc.whoServes, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(s.playerAName),
                      selected: server == 0,
                      onSelected: (_) => setSt(() => server = 0),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(s.playerBName),
                      selected: server == 1,
                      onSelected: (_) => setSt(() => server = 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(scoreControllerProvider.notifier).setup(
                  playerAName: s.playerAName,
                  playerBName: s.playerBName,
                  setsToWin: setsToWin,
                  gamesPerSet: gamesPerSet,
                  hasAdvantage: hasAdvantage,
                  finalSetTiebreak: finalSetTiebreak,
                  tiebreakPoints: tiebreakPoints,
                  server: server,
                );
                _startTimer();
              },
              child: Text(loc.apply),
            ),
          ],
        ),
      ),
    );
  }

  void _showWinnerDialog(BuildContext context, WidgetRef ref, String winner, String result) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('🏆 ${loc.matchWinner}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(winner, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(result, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(loc.copyResult),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '$winner — $result'));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.resultCopied)),
              );
            },
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(scoreControllerProvider.notifier).reset();
              _startTimer();
            },
            child: Text(loc.newMatch),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scoreControllerProvider);
    final loc = AppLocalizations.of(context)!;

    // Show winner dialog once
    if (state.isMatchOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && state.isMatchOver) {
          _showWinnerDialog(context, ref, state.matchWinner!, state.resultString);
        }
      });
    }

    final bg = _fullscreen ? Colors.black : Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: _fullscreen
          ? null
          : AppBar(
              title: Text(loc.score),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _showResetConfirm(context, ref),
                  tooltip: loc.resetMatch,
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _enterFullscreen,
                  tooltip: loc.fullscreen,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showSetupDialog(context, ref),
                ),
              ],
            ),
      body: GestureDetector(
        onTap: _fullscreen ? _exitFullscreen : null,
        child: SafeArea(
          child: Column(
            children: [
              if (_fullscreen)
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.fullscreen_exit, color: Colors.white.withValues(alpha: 0.6)),
                      onPressed: _exitFullscreen,
                    ),
                  ),
                ),

              // ── Timer ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _formatTime(state.elapsedSeconds),
                  style: TextStyle(
                    fontSize: 16,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: _fullscreen ? Colors.white54 : Colors.grey,
                  ),
                ),
              ),

              // ── Sets scoreboard ──────────────────────────────────────────
              _SetsRow(state: state, fullscreen: _fullscreen),

              const SizedBox(height: 8),

              // ── Main score panels ────────────────────────────────────────
              Expanded(
                child: Row(
                  children: [
                    // Player A panel
                    Expanded(
                      child: _ScorePanel(
                        playerName: state.playerAName,
                        pointLabel: state.pointLabelA,
                        games: state.currentGamesA,
                        isServing: state.server == 0,
                        color: const Color(0xFF1565C0),
                        fullscreen: _fullscreen,
                        onTap: () => ref.read(scoreControllerProvider.notifier).scorePoint(true),
                        onLongPress: () => _showLongPressMenu(context, ref, true),
                      ),
                    ),
                    // Player B panel
                    Expanded(
                      child: _ScorePanel(
                        playerName: state.playerBName,
                        pointLabel: state.pointLabelB,
                        games: state.currentGamesB,
                        isServing: state.server == 1,
                        color: const Color(0xFFC62828),
                        fullscreen: _fullscreen,
                        onTap: () => ref.read(scoreControllerProvider.notifier).scorePoint(false),
                        onLongPress: () => _showLongPressMenu(context, ref, false),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Status line ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _StatusLine(state: state, fullscreen: _fullscreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sets scoreboard row ──────────────────────────────────────────────────────

class _SetsRow extends StatelessWidget {
  final ScoreState state;
  final bool fullscreen;

  const _SetsRow({required this.state, required this.fullscreen});

  @override
  Widget build(BuildContext context) {
    final textColor = fullscreen ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final setCount = state.gamesA.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Left: sets won A
          SizedBox(
            width: 32,
            child: Text(
              '${state.setsA}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          // Set columns
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(setCount, (i) {
                final ga = i < state.gamesA.length ? state.gamesA[i] : 0;
                final gb = i < state.gamesB.length ? state.gamesB[i] : 0;
                final isCurrent = i == state.currentSetIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Text(
                        '$ga',
                        style: TextStyle(
                          fontSize: isCurrent ? 22 : 16,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? textColor : textColor.withValues(alpha: 0.6),
                        ),
                      ),
                      Container(height: 1, width: 20, color: textColor.withValues(alpha: 0.3)),
                      Text(
                        '$gb',
                        style: TextStyle(
                          fontSize: isCurrent ? 22 : 16,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? textColor : textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          // Right: sets won B
          SizedBox(
            width: 32,
            child: Text(
              '${state.setsB}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Score panel (one side) ───────────────────────────────────────────────────

class _ScorePanel extends StatelessWidget {
  final String playerName;
  final String pointLabel;
  final int games;
  final bool isServing;
  final Color color;
  final bool fullscreen;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ScorePanel({
    required this.playerName,
    required this.pointLabel,
    required this.games,
    required this.isServing,
    required this.color,
    required this.fullscreen,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: fullscreen ? 0.85 : 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: fullscreen ? 0.0 : 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Player name + serve dot
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isServing)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: fullscreen ? Colors.yellowAccent : Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                Flexible(
                  child: Text(
                    playerName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fullscreen ? Colors.white70 : color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Point display
            Text(
              pointLabel,
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: fullscreen ? Colors.white : color,
                height: 1,
              ),
            ),
            const SizedBox(height: 12),
            // Games in current set
            Text(
              '$games',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: fullscreen
                    ? Colors.white.withValues(alpha: 0.7)
                    : color.withValues(alpha: 0.7),
              ),
            ),
            Text(
              'games',
              style: TextStyle(
                fontSize: 12,
                color: fullscreen
                    ? Colors.white.withValues(alpha: 0.5)
                    : color.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status line ───────────────────────────────────────────────────────────────

class _StatusLine extends StatelessWidget {
  final ScoreState state;
  final bool fullscreen;

  const _StatusLine({required this.state, required this.fullscreen});

  @override
  Widget build(BuildContext context) {
    final textColor = fullscreen ? Colors.white54 : Colors.grey;

    String label = '';
    if (state.isTiebreak) {
      final target = state.tiebreakPoints;
      label = 'Tiebreak — primeiro a $target${state.isFinalSet ? " (match tiebreak)" : ""}';
    } else if (state.pointsA == 3 && state.pointsB == 3 && state.hasAdvantage) {
      label = 'Deuce';
    } else if (state.pointsA == 4) {
      label = 'Vantagem — ${state.playerAName}';
    } else if (state.pointsB == 4) {
      label = 'Vantagem — ${state.playerBName}';
    }

    if (state.completedSets.isNotEmpty && label.isEmpty) {
      label = state.resultString;
    }

    return Text(
      label,
      style: TextStyle(fontSize: 13, color: textColor),
      textAlign: TextAlign.center,
    );
  }
}
