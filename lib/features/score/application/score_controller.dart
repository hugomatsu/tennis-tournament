import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/score/domain/score_state.dart';

final scoreControllerProvider =
    NotifierProvider<ScoreController, ScoreState>(ScoreController.new);

class ScoreController extends Notifier<ScoreState> {
  final _history = <ScoreState>[];

  @override
  ScoreState build() => ScoreState(
        playerAName: 'Jogador A',
        playerBName: 'Jogador B',
        gamesA: [0],
        gamesB: [0],
        completedSets: [],
      );

  // ── Setup ────────────────────────────────────────────────────────────────

  void setup({
    required String playerAName,
    required String playerBName,
    required int setsToWin,
    required int gamesPerSet,
    required bool hasAdvantage,
    required bool finalSetTiebreak,
    required int tiebreakPoints,
    required int server,
  }) {
    _history.clear();
    state = ScoreState(
      playerAName: playerAName,
      playerBName: playerBName,
      gamesA: [0],
      gamesB: [0],
      completedSets: [],
      setsToWin: setsToWin,
      gamesPerSet: gamesPerSet,
      hasAdvantage: hasAdvantage,
      finalSetTiebreak: finalSetTiebreak,
      tiebreakPoints: tiebreakPoints,
      server: server,
    );
  }

  void updatePlayerNames(String a, String b) {
    state = state.copyWith(playerAName: a, playerBName: b);
  }

  // ── Timer ────────────────────────────────────────────────────────────────

  void tick() {
    if (!state.isMatchOver) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    }
  }

  // ── Scoring ──────────────────────────────────────────────────────────────

  void scorePoint(bool isA) {
    if (state.isMatchOver) return;
    _history.add(state);

    final prevSetIndex = state.currentSetIndex;
    final prevGamesInSet = (state.gamesA.isNotEmpty && prevSetIndex < state.gamesA.length
            ? state.gamesA[prevSetIndex]
            : 0) +
        (state.gamesB.isNotEmpty && prevSetIndex < state.gamesB.length
            ? state.gamesB[prevSetIndex]
            : 0);

    final newState = _applyPoint(state, isA);

    // Determine what kind of event this point triggered
    String event = 'point';
    if (newState.isMatchOver) {
      event = 'match';
    } else if (newState.setsA + newState.setsB > state.setsA + state.setsB) {
      event = 'set';
    } else if (!newState.isTiebreak &&
        newState.pointsA == 0 &&
        newState.pointsB == 0 &&
        newState.currentSetIndex == prevSetIndex) {
      event = 'game';
    }

    final entry = ScoreLogEntry(
      isPlayerA: isA,
      elapsedSeconds: state.elapsedSeconds,
      setIndex: prevSetIndex,
      gameInSet: prevGamesInSet,
      pointLabelA: newState.pointLabelA,
      pointLabelB: newState.pointLabelB,
      event: event,
    );

    state = newState.copyWith(log: [...newState.log, entry]);
  }

  void undo() {
    if (_history.isEmpty) return;
    state = _history.removeLast();
  }

  void reset() {
    _history.clear();
    state = ScoreState(
      playerAName: state.playerAName,
      playerBName: state.playerBName,
      gamesA: [0],
      gamesB: [0],
      completedSets: [],
      setsToWin: state.setsToWin,
      gamesPerSet: state.gamesPerSet,
      hasAdvantage: state.hasAdvantage,
      finalSetTiebreak: state.finalSetTiebreak,
      tiebreakPoints: state.tiebreakPoints,
      server: state.server,
    );
  }

  // ── Internal logic ───────────────────────────────────────────────────────

  ScoreState _applyPoint(ScoreState s, bool isA) {
    if (s.isTiebreak) return _applyTiebreakPoint(s, isA);

    int pA = s.pointsA;
    int pB = s.pointsB;

    if (isA) {
      pA++;
    } else {
      pB++;
    }

    // Deuce / advantage logic
    if (s.hasAdvantage) {
      // After deuce (3-3), one player reaches 4 = advantage
      if (pA == 4 && pB == 4) {
        // Both at advantage → back to deuce
        return s.copyWith(pointsA: 3, pointsB: 3);
      }
      if (pA >= 4 || pB >= 4) {
        // Winner of game
        if ((pA == 4 && pB <= 3) || (pA == 4 && pB == 3) || (pA > 4)) {
          return _winGame(s, true);
        }
        if ((pB == 4 && pA <= 3) || (pB == 4 && pA == 3) || (pB > 4)) {
          return _winGame(s, false);
        }
      }
      if (pA == 3 && pB == 3) {
        return s.copyWith(pointsA: pA, pointsB: pB);
      }
    } else {
      // No-Ad: first to 4 points wins at 3-3
      if (pA >= 4 || pB >= 4) {
        return _winGame(s, pA > pB);
      }
    }

    return s.copyWith(pointsA: pA, pointsB: pB);
  }

  ScoreState _applyTiebreakPoint(ScoreState s, bool isA) {
    final pA = s.pointsA + (isA ? 1 : 0);
    final pB = s.pointsB + (isA ? 0 : 1);
    final target = s.tiebreakPoints;

    // Switch server every 2 points (first point then every 2)
    final totalPoints = pA + pB;
    int nextServer = s.server;
    if (totalPoints > 0 && (totalPoints == 1 || (totalPoints - 1) % 2 == 0)) {
      nextServer = 1 - s.server;
    }

    if (pA >= target && pA - pB >= 2) return _winTiebreak(s, true);
    if (pB >= target && pB - pA >= 2) return _winTiebreak(s, false);

    return s.copyWith(pointsA: pA, pointsB: pB, server: nextServer);
  }

  ScoreState _winGame(ScoreState s, bool isA) {
    final gamesA = List<int>.from(s.gamesA);
    final gamesB = List<int>.from(s.gamesB);
    final idx = s.currentSetIndex;

    while (gamesA.length <= idx) { gamesA.add(0); }
    while (gamesB.length <= idx) { gamesB.add(0); }

    if (isA) {
      gamesA[idx]++;
    } else {
      gamesB[idx]++;
    }

    final ga = gamesA[idx];
    final gb = gamesB[idx];
    final nextServer = 1 - s.server;

    // Check for tiebreak condition
    if (ga == s.gamesPerSet && gb == s.gamesPerSet) {
      return s.copyWith(
        pointsA: 0,
        pointsB: 0,
        gamesA: gamesA,
        gamesB: gamesB,
        isTiebreak: true,
        server: nextServer,
      );
    }

    // Check for set win
    final minGames = s.gamesPerSet;
    final setWinA = ga >= minGames && ga - gb >= 2;
    final setWinB = gb >= minGames && gb - ga >= 2;

    if (setWinA || setWinB) {
      return _winSet(s, isA, gamesA, gamesB, nextServer);
    }

    return s.copyWith(
      pointsA: 0,
      pointsB: 0,
      gamesA: gamesA,
      gamesB: gamesB,
      server: nextServer,
    );
  }

  ScoreState _winTiebreak(ScoreState s, bool isA) {
    final gamesA = List<int>.from(s.gamesA);
    final gamesB = List<int>.from(s.gamesB);
    final idx = s.currentSetIndex;

    while (gamesA.length <= idx) { gamesA.add(0); }
    while (gamesB.length <= idx) { gamesB.add(0); }

    if (isA) {
      gamesA[idx]++;
    } else {
      gamesB[idx]++;
    }

    // Server switches after tiebreak
    return _winSet(s, isA, gamesA, gamesB, 1 - s.server);
  }

  ScoreState _winSet(ScoreState s, bool isA, List<int> gamesA, List<int> gamesB, int nextServer) {
    final idx = s.currentSetIndex;
    final ga = gamesA.length > idx ? gamesA[idx] : 0;
    final gb = gamesB.length > idx ? gamesB[idx] : 0;

    final completedSets = List<String>.from(s.completedSets);
    completedSets.add(isA ? '$ga-$gb' : '$ga-$gb');

    final setsA = s.setsA + (isA ? 1 : 0);
    final setsB = s.setsB + (isA ? 0 : 1);

    // Check for match win
    if (setsA >= s.setsToWin) {
      return s.copyWith(
        pointsA: 0, pointsB: 0,
        gamesA: gamesA, gamesB: gamesB,
        setsA: setsA, setsB: setsB,
        isTiebreak: false,
        server: nextServer,
        isMatchOver: true,
        matchWinner: s.playerAName,
        completedSets: completedSets,
      );
    }
    if (setsB >= s.setsToWin) {
      return s.copyWith(
        pointsA: 0, pointsB: 0,
        gamesA: gamesA, gamesB: gamesB,
        setsA: setsA, setsB: setsB,
        isTiebreak: false,
        server: nextServer,
        isMatchOver: true,
        matchWinner: s.playerBName,
        completedSets: completedSets,
      );
    }

    // Start new set
    gamesA.add(0);
    gamesB.add(0);

    return s.copyWith(
      pointsA: 0, pointsB: 0,
      gamesA: gamesA, gamesB: gamesB,
      setsA: setsA, setsB: setsB,
      isTiebreak: false,
      server: nextServer,
      completedSets: completedSets,
    );
  }
}
