const Map<String, dynamic> kDefaultMatchRules = {
  'setsToWin': 2,
  'gamesPerSet': 6,
  'advantage': false,
  'tiebreak': true,
  'tiebreakPoints': 7,
  'finalSetMatchTiebreak': true,
  'matchTiebreakPoints': 10,
  'matchDurationMinutes': 90,
  'warmupMinutes': 5,
  'restBetweenSetsMinutes': 2,
  'changeoverSeconds': 90,
  'selfRefereeing': true,
  'letServeReplayed': true,
  'codeOfConduct': 'relaxed',
  'ballType': '',
  'confirmationDeadlineHours': 2,
  'noShowGraceMinutes': 15,
  'noShowResult': 'walkover',
  // Variable scoring & cross-group config
  'scoringMode': 'flat', // 'flat' (legacy) or 'variable'
  'matchFormat': 'roundRobin', // 'roundRobin' (legacy) or 'crossGroup'
  'matchesPerPlayer': 5, // only used when crossGroup
  'pointsWin2_0': 4,
  'pointsWin2_1': 3,
  'pointsWinWO': 2,
  'pointsLoss1_2': 1,
  'pointsLoss0_2': 0,
  'pointsLossWO': 0,
};

const Map<String, dynamic> kQuickMatchPreset = {
  'setsToWin': 1,
  'gamesPerSet': 6,
  'advantage': false,
  'tiebreak': true,
  'tiebreakPoints': 7,
  'finalSetMatchTiebreak': false,
  'matchTiebreakPoints': 10,
};

const Map<String, dynamic> kStandardAmateurPreset = {
  'setsToWin': 2,
  'gamesPerSet': 6,
  'advantage': false,
  'tiebreak': true,
  'tiebreakPoints': 7,
  'finalSetMatchTiebreak': true,
  'matchTiebreakPoints': 10,
};

const Map<String, dynamic> kFullMatchPreset = {
  'setsToWin': 3,
  'gamesPerSet': 6,
  'advantage': true,
  'tiebreak': true,
  'tiebreakPoints': 7,
  'finalSetMatchTiebreak': false,
  'matchTiebreakPoints': 10,
};

enum MatchRulePreset { quickMatch, standardAmateur, fullMatch, custom }
