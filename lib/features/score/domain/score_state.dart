/// Immutable snapshot of the match score at any point in time.
/// One instance is pushed onto the history stack so undo is trivial.
class ScoreState {
  final String playerAName;
  final String playerBName;

  // Current-game points: 0 1 2 3 = 0 15 30 40
  final int pointsA;
  final int pointsB;

  // Games won in each set: parallel lists indexed by set number
  final List<int> gamesA; // e.g. [6, 3]
  final List<int> gamesB;

  // Sets won
  final int setsA;
  final int setsB;

  // Tiebreak
  final bool isTiebreak;

  // Who is serving (0 = A, 1 = B)
  final int server;

  // Match settings (carried through so undo restores them)
  final int setsToWin;    // e.g. 2 → best-of-3
  final int gamesPerSet;  // e.g. 6
  final bool hasAdvantage;
  final bool finalSetTiebreak; // replace final set with 10-pt tiebreak
  final int tiebreakPoints; // 7 or 10

  // Elapsed seconds (updated externally by the timer)
  final int elapsedSeconds;

  // True once a player has won the match
  final bool isMatchOver;
  final String? matchWinner; // name of winner

  // Completed set scores for the result string, e.g. ["6-3","4-6","10-8"]
  final List<String> completedSets;

  const ScoreState({
    required this.playerAName,
    required this.playerBName,
    this.pointsA = 0,
    this.pointsB = 0,
    required this.gamesA,
    required this.gamesB,
    this.setsA = 0,
    this.setsB = 0,
    this.isTiebreak = false,
    this.server = 0,
    this.setsToWin = 2,
    this.gamesPerSet = 6,
    this.hasAdvantage = true,
    this.finalSetTiebreak = true,
    this.tiebreakPoints = 10,
    this.elapsedSeconds = 0,
    this.isMatchOver = false,
    this.matchWinner,
    required this.completedSets,
  });

  ScoreState copyWith({
    String? playerAName,
    String? playerBName,
    int? pointsA,
    int? pointsB,
    List<int>? gamesA,
    List<int>? gamesB,
    int? setsA,
    int? setsB,
    bool? isTiebreak,
    int? server,
    int? setsToWin,
    int? gamesPerSet,
    bool? hasAdvantage,
    bool? finalSetTiebreak,
    int? tiebreakPoints,
    int? elapsedSeconds,
    bool? isMatchOver,
    String? matchWinner,
    List<String>? completedSets,
  }) {
    return ScoreState(
      playerAName: playerAName ?? this.playerAName,
      playerBName: playerBName ?? this.playerBName,
      pointsA: pointsA ?? this.pointsA,
      pointsB: pointsB ?? this.pointsB,
      gamesA: gamesA ?? this.gamesA,
      gamesB: gamesB ?? this.gamesB,
      setsA: setsA ?? this.setsA,
      setsB: setsB ?? this.setsB,
      isTiebreak: isTiebreak ?? this.isTiebreak,
      server: server ?? this.server,
      setsToWin: setsToWin ?? this.setsToWin,
      gamesPerSet: gamesPerSet ?? this.gamesPerSet,
      hasAdvantage: hasAdvantage ?? this.hasAdvantage,
      finalSetTiebreak: finalSetTiebreak ?? this.finalSetTiebreak,
      tiebreakPoints: tiebreakPoints ?? this.tiebreakPoints,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isMatchOver: isMatchOver ?? this.isMatchOver,
      matchWinner: matchWinner ?? this.matchWinner,
      completedSets: completedSets ?? this.completedSets,
    );
  }

  // ── Display helpers ──────────────────────────────────────────────────────

  static const _pointLabels = ['0', '15', '30', '40'];

  String get pointLabelA {
    if (isTiebreak) return '$pointsA';
    if (pointsA == 3 && pointsB == 3) return hasAdvantage ? 'Deuce' : '40';
    if (pointsA == 4) return 'Ad';
    if (pointsB == 4) return '  ';
    return _pointLabels[pointsA.clamp(0, 3)];
  }

  String get pointLabelB {
    if (isTiebreak) return '$pointsB';
    if (pointsA == 3 && pointsB == 3) return hasAdvantage ? 'Deuce' : '40';
    if (pointsB == 4) return 'Ad';
    if (pointsA == 4) return '  ';
    return _pointLabels[pointsB.clamp(0, 3)];
  }

  int get currentSetIndex => setsA + setsB;

  int get currentGamesA => gamesA.length > currentSetIndex ? gamesA[currentSetIndex] : 0;
  int get currentGamesB => gamesB.length > currentSetIndex ? gamesB[currentSetIndex] : 0;

  String get resultString => completedSets.join(', ');

  bool get isFinalSet => (setsA + setsB) == (setsToWin * 2 - 1);
}
