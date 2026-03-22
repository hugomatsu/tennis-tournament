import 'package:flutter/material.dart';
import 'package:tennis_tournament/features/tournaments/domain/match_rule_presets.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class MatchRulesCard extends StatelessWidget {
  final Map<String, dynamic> rules;

  const MatchRulesCard({super.key, required this.rules});

  int _int(String key) => (rules[key] as int?) ?? (kDefaultMatchRules[key] as int);
  bool _bool(String key) => (rules[key] as bool?) ?? (kDefaultMatchRules[key] as bool);
  String _string(String key) => (rules[key] as String?) ?? (kDefaultMatchRules[key] as String);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Build scoring line
    final scoringParts = <String>[
      loc.rulesScoringSummary(_int('setsToWin'), _int('gamesPerSet')),
      _bool('advantage') ? loc.rulesAdvantage : loc.rulesNoAdvantage,
      if (_bool('tiebreak')) loc.rulesTiebreakTo(_int('tiebreakPoints')),
    ];
    final scoringExtra = _bool('finalSetMatchTiebreak')
        ? loc.rulesFinalSetTiebreak(_int('matchTiebreakPoints'))
        : null;

    // Build time line
    final timeParts = <String>[
      if (_int('matchDurationMinutes') > 0)
        loc.rulesMatchLimit(_int('matchDurationMinutes')),
      if (_int('warmupMinutes') > 0)
        loc.rulesWarmup(_int('warmupMinutes')),
      if (_int('restBetweenSetsMinutes') > 0)
        loc.rulesRestBetweenSets(_int('restBetweenSetsMinutes')),
    ];

    // Build court line
    final courtParts = <String>[
      if (_bool('selfRefereeing')) loc.rulesSelfRefereeing,
      if (_bool('letServeReplayed')) loc.rulesLetReplayed,
    ];

    // Build no-show line
    final noShowParts = <String>[
      loc.rulesConfirmBefore(_int('confirmationDeadlineHours')),
      loc.rulesGracePeriod(_int('noShowGraceMinutes')),
      _string('noShowResult') == 'walkover'
          ? loc.rulesWalkoverOnNoShow
          : loc.rulesRescheduleOnNoShow,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                loc.matchRules,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RuleLine(
            icon: Icons.scoreboard_outlined,
            label: loc.scoringFormat,
            value: scoringParts.join(' · '),
            extra: scoringExtra,
          ),
          if (timeParts.isNotEmpty)
            _RuleLine(
              icon: Icons.timer_outlined,
              label: loc.timeRules,
              value: timeParts.join(' · '),
            ),
          if (courtParts.isNotEmpty)
            _RuleLine(
              icon: Icons.sports_tennis_outlined,
              label: loc.courtAndConduct,
              value: courtParts.join(' · '),
            ),
          _RuleLine(
            icon: Icons.timer_off_outlined,
            label: loc.walkoverAndNoShow,
            value: noShowParts.join(' · '),
          ),
        ],
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? extra;

  const _RuleLine({
    required this.icon,
    required this.label,
    required this.value,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
                if (extra != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      extra!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
