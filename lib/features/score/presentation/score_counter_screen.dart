import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/score/application/score_controller.dart';
import 'package:tennis_tournament/features/score/domain/score_state.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

const _colorA = Color(0xFF1565C0); // blue — left player
const _colorB = Color(0xFFC62828); // red  — right player

class ScoreCounterScreen extends ConsumerStatefulWidget {
  const ScoreCounterScreen({super.key});

  @override
  ConsumerState<ScoreCounterScreen> createState() => _ScoreCounterScreenState();
}

class _ScoreCounterScreenState extends ConsumerState<ScoreCounterScreen> {
  Timer? _timer;
  bool _fullscreen = false;
  bool _matchStarted = false;
  bool _sidesSwapped = false;

  // Setup-screen controllers
  final _ctrlA = TextEditingController();
  final _ctrlB = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrlA.dispose();
    _ctrlB.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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

  void _startMatch() {
    final nameA = _ctrlA.text.trim();
    final nameB = _ctrlB.text.trim();
    final loc = AppLocalizations.of(context)!;
    ref.read(scoreControllerProvider.notifier).updatePlayerNames(
      nameA.isEmpty ? loc.playerLeftHint : nameA,
      nameB.isEmpty ? loc.playerRightHint : nameB,
    );
    setState(() {
      _matchStarted = true;
      _sidesSwapped = false;
    });
    _startTimer();
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

  void _showLongPressMenu(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            TextField(
              controller: ctrlA,
              decoration: InputDecoration(
                labelText: loc.playerLeftHint,
                prefixIcon: const Icon(Icons.circle, color: _colorA, size: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrlB,
              decoration: InputDecoration(
                labelText: loc.playerRightHint,
                prefixIcon: const Icon(Icons.circle, color: _colorB, size: 14),
              ),
            ),
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
              setState(() => _sidesSwapped = false);
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
              setState(() {
                _matchStarted = false;
                _sidesSwapped = false;
                _ctrlA.clear();
                _ctrlB.clear();
              });
              _startTimer();
            },
            child: Text(loc.newMatch),
          ),
        ],
      ),
    );
  }

  void _showScoreLog(BuildContext context, ScoreState state) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 20),
                  const SizedBox(width: 8),
                  Text(loc.scoreLog,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: state.log.isEmpty
                  ? Center(child: Text(loc.noPointsYet, style: TextStyle(color: Colors.grey.shade500)))
                  : ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      children: _buildLogWidgets(state, loc),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLogWidgets(ScoreState state, AppLocalizations loc) {
    final widgets = <Widget>[];
    int currentSet = -1;
    int currentGame = -1;

    for (final entry in state.log) {
      // Set header
      if (entry.setIndex != currentSet) {
        if (currentSet >= 0) widgets.add(const SizedBox(height: 4));
        currentSet = entry.setIndex;
        currentGame = -1;
        widgets.add(_LogSetHeader(setNumber: currentSet + 1, loc: loc));
      }
      // Game header
      if (entry.gameInSet != currentGame) {
        currentGame = entry.gameInSet;
        widgets.add(_LogGameHeader(gameNumber: currentGame + 1, loc: loc));
      }

      // Event rows: game/set/match endings get a highlighted row
      if (entry.event == 'game' || entry.event == 'set' || entry.event == 'match') {
        final name = entry.isPlayerA ? state.playerAName : state.playerBName;
        final color = entry.isPlayerA ? _colorA : _colorB;
        final label = entry.event == 'match'
            ? loc.matchWonBy(name)
            : entry.event == 'set'
                ? loc.setWonBy(name)
                : loc.gameWonBy(name);
        widgets.add(_LogEventRow(label: label, color: color));
      } else {
        widgets.add(_LogPointRow(
          entry: entry,
          elapsed: _formatTime(entry.elapsedSeconds),
        ));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scoreControllerProvider);
    final loc = AppLocalizations.of(context)!;

    // Show winner dialog once match ends
    if (_matchStarted && state.isMatchOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && state.isMatchOver) {
          _showWinnerDialog(context, ref, state.matchWinner!, state.resultString);
        }
      });
    }

    final bg = _fullscreen ? Colors.black : Theme.of(context).scaffoldBackgroundColor;
    final canUndo = state.log.isNotEmpty;

    AppBar? appBar;
    if (!_fullscreen) {
      if (_matchStarted) {
        appBar = AppBar(
          automaticallyImplyLeading: false,
          title: Text(loc.score),
          actions: [
            IconButton(
              icon: Icon(Icons.undo, color: canUndo ? null : Colors.grey.shade400),
              onPressed: canUndo
                  ? () => ref.read(scoreControllerProvider.notifier).undo()
                  : null,
              tooltip: loc.undo,
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () => setState(() => _sidesSwapped = !_sidesSwapped),
              tooltip: loc.swapSides,
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showScoreLog(context, state),
              tooltip: loc.scoreLog,
            ),
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
        );
      } else {
        appBar = AppBar(
          automaticallyImplyLeading: false,
          title: Text(loc.score),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSetupDialog(context, ref),
              tooltip: loc.matchSettings,
            ),
          ],
        );
      }
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: appBar,
      body: _matchStarted ? GestureDetector(
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
              _SetsRow(state: state, fullscreen: _fullscreen, swapped: _sidesSwapped),

              const SizedBox(height: 8),

              // ── Main score panels ────────────────────────────────────────
              Expanded(
                child: Row(
                  children: _sidesSwapped
                      ? [
                          // Right side shows B (red) on left when swapped
                          Expanded(
                            child: _ScorePanel(
                              playerName: state.playerBName,
                              pointLabel: state.pointLabelB,
                              games: state.currentGamesB,
                              isServing: state.server == 1,
                              color: _colorB,
                              fullscreen: _fullscreen,
                              onTap: () => ref.read(scoreControllerProvider.notifier).scorePoint(false),
                              onLongPress: () => _showLongPressMenu(context, ref),
                            ),
                          ),
                          Expanded(
                            child: _ScorePanel(
                              playerName: state.playerAName,
                              pointLabel: state.pointLabelA,
                              games: state.currentGamesA,
                              isServing: state.server == 0,
                              color: _colorA,
                              fullscreen: _fullscreen,
                              onTap: () => ref.read(scoreControllerProvider.notifier).scorePoint(true),
                              onLongPress: () => _showLongPressMenu(context, ref),
                            ),
                          ),
                        ]
                      : [
                          // Normal: A (blue) on left, B (red) on right
                          Expanded(
                            child: _ScorePanel(
                              playerName: state.playerAName,
                              pointLabel: state.pointLabelA,
                              games: state.currentGamesA,
                              isServing: state.server == 0,
                              color: _colorA,
                              fullscreen: _fullscreen,
                              onTap: () => ref.read(scoreControllerProvider.notifier).scorePoint(true),
                              onLongPress: () => _showLongPressMenu(context, ref),
                            ),
                          ),
                          Expanded(
                            child: _ScorePanel(
                              playerName: state.playerBName,
                              pointLabel: state.pointLabelB,
                              games: state.currentGamesB,
                              isServing: state.server == 1,
                              color: _colorB,
                              fullscreen: _fullscreen,
                              onTap: () => ref.read(scoreControllerProvider.notifier).scorePoint(false),
                              onLongPress: () => _showLongPressMenu(context, ref),
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
      ) : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // ── App icon + title ─────────────────────────────────────────
              Icon(
                Icons.sports_tennis,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                loc.score,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              // ── How it works card ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          loc.scoreCounterHowItWorks,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _HintRow(icon: Icons.touch_app_outlined, text: loc.scoreCounterFeatureTap),
                    const SizedBox(height: 6),
                    _HintRow(icon: Icons.pan_tool_outlined, text: loc.scoreCounterFeatureLongPress),
                    const SizedBox(height: 6),
                    _HintRow(icon: Icons.more_horiz, text: loc.scoreCounterFeatureToolbar),
                    const SizedBox(height: 6),
                    _HintRow(icon: Icons.fullscreen, text: loc.scoreCounterFeatureFullscreen),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _ctrlA,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: loc.playerLeftHint,
                  prefixIcon: const Icon(Icons.circle, color: _colorA, size: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _colorA, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ctrlB,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: loc.playerRightHint,
                  prefixIcon: const Icon(Icons.circle, color: _colorB, size: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _colorB, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.tapToStartHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _startMatch,
                icon: const Icon(Icons.sports_tennis),
                label: Text(loc.startMatch, style: const TextStyle(fontSize: 18)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
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
  final bool swapped;

  const _SetsRow({required this.state, required this.fullscreen, this.swapped = false});

  @override
  Widget build(BuildContext context) {
    final textColor = fullscreen ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final setCount = state.gamesA.length;

    final setsLeft = swapped ? state.setsB : state.setsA;
    final setsRight = swapped ? state.setsA : state.setsB;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$setsLeft',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(setCount, (i) {
                final ga = i < state.gamesA.length ? state.gamesA[i] : 0;
                final gb = i < state.gamesB.length ? state.gamesB[i] : 0;
                final topVal = swapped ? gb : ga;
                final botVal = swapped ? ga : gb;
                final isCurrent = i == state.currentSetIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Text(
                        '$topVal',
                        style: TextStyle(
                          fontSize: isCurrent ? 22 : 16,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? textColor : textColor.withValues(alpha: 0.6),
                        ),
                      ),
                      Container(height: 1, width: 20, color: textColor.withValues(alpha: 0.3)),
                      Text(
                        '$botVal',
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
          SizedBox(
            width: 32,
            child: Text(
              '$setsRight',
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

// ── Score log widgets ─────────────────────────────────────────────────────────

class _LogSetHeader extends StatelessWidget {
  final int setNumber;
  final AppLocalizations loc;

  const _LogSetHeader({required this.setNumber, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        loc.setLabel(setNumber),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _LogGameHeader extends StatelessWidget {
  final int gameNumber;
  final AppLocalizations loc;

  const _LogGameHeader({required this.gameNumber, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 6, bottom: 2),
      child: Text(
        loc.gameLabel(gameNumber),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LogPointRow extends StatelessWidget {
  final ScoreLogEntry entry;
  final String elapsed;

  const _LogPointRow({required this.entry, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final color = entry.isPlayerA ? _colorA : _colorB;
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Row(
        children: [
          // Left dot (A)
          SizedBox(width: 16, child: entry.isPlayerA ? dot : null),
          const SizedBox(width: 4),
          // Score
          Expanded(
            child: Text(
              '${entry.pointLabelA.trim()}  —  ${entry.pointLabelB.trim()}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontFeatures: [FontFeature.tabularFigures()]),
            ),
          ),
          const SizedBox(width: 4),
          // Right dot (B)
          SizedBox(width: 16, child: entry.isPlayerA ? null : dot),
          const SizedBox(width: 8),
          // Time
          Text(
            elapsed,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500,
                fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HintRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _LogEventRow extends StatelessWidget {
  final String label;
  final Color color;

  const _LogEventRow({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
