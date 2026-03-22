import 'package:flutter/material.dart';
import 'package:tennis_tournament/features/tournaments/domain/match_rule_presets.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class MatchRulesEditor extends StatefulWidget {
  final Map<String, dynamic> initialRules;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const MatchRulesEditor({
    super.key,
    required this.initialRules,
    required this.onChanged,
  });

  @override
  State<MatchRulesEditor> createState() => _MatchRulesEditorState();
}

class _MatchRulesEditorState extends State<MatchRulesEditor> {
  late Map<String, dynamic> _rules;
  MatchRulePreset _selectedPreset = MatchRulePreset.standardAmateur;
  final _ballTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rules = Map<String, dynamic>.from(
      widget.initialRules.isEmpty ? {...kDefaultMatchRules} : widget.initialRules,
    );
    _ballTypeController.text = _rules['ballType'] as String? ?? '';
    _selectedPreset = _detectPreset();
  }

  @override
  void dispose() {
    _ballTypeController.dispose();
    super.dispose();
  }

  MatchRulePreset _detectPreset() {
    if (_matchesPreset(kQuickMatchPreset)) return MatchRulePreset.quickMatch;
    if (_matchesPreset(kStandardAmateurPreset)) return MatchRulePreset.standardAmateur;
    if (_matchesPreset(kFullMatchPreset)) return MatchRulePreset.fullMatch;
    return MatchRulePreset.custom;
  }

  bool _matchesPreset(Map<String, dynamic> preset) {
    for (final key in preset.keys) {
      if (_rules[key] != preset[key]) return false;
    }
    return true;
  }

  void _applyPreset(MatchRulePreset preset) {
    final Map<String, dynamic> presetMap;
    switch (preset) {
      case MatchRulePreset.quickMatch:
        presetMap = kQuickMatchPreset;
      case MatchRulePreset.standardAmateur:
        presetMap = kStandardAmateurPreset;
      case MatchRulePreset.fullMatch:
        presetMap = kFullMatchPreset;
      case MatchRulePreset.custom:
        return;
    }
    setState(() {
      _rules = {...kDefaultMatchRules, ..._rules, ...presetMap};
      _selectedPreset = preset;
    });
    _notify();
  }

  void _updateRule(String key, dynamic value) {
    setState(() {
      _rules[key] = value;
      _selectedPreset = _detectPreset();
    });
    _notify();
  }

  void _notify() {
    widget.onChanged(Map<String, dynamic>.from(_rules));
  }

  String _presetLabel(AppLocalizations loc, MatchRulePreset preset) {
    return switch (preset) {
      MatchRulePreset.quickMatch => loc.presetQuickMatch,
      MatchRulePreset.standardAmateur => loc.presetStandardAmateur,
      MatchRulePreset.fullMatch => loc.presetFullMatch,
      MatchRulePreset.custom => loc.presetCustom,
    };
  }

  // Helpers
  int _intRule(String key) => (_rules[key] as int?) ?? (kDefaultMatchRules[key] as int);
  bool _boolRule(String key) => (_rules[key] as bool?) ?? (kDefaultMatchRules[key] as bool);
  String _stringRule(String key) => (_rules[key] as String?) ?? (kDefaultMatchRules[key] as String);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset chips
        Text(loc.matchRulesPreset, style: theme.textTheme.labelMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final preset in MatchRulePreset.values)
              ChoiceChip(
                label: Text(_presetLabel(loc, preset)),
                selected: _selectedPreset == preset,
                onSelected: preset == MatchRulePreset.custom
                    ? null
                    : (_) => _applyPreset(preset),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Scoring
        _ExpansionSection(
          icon: Icons.scoreboard_outlined,
          title: loc.scoringFormat,
          children: [
            _DropdownRow<int>(
              label: loc.setsToWin,
              value: _intRule('setsToWin'),
              items: const [1, 2, 3],
              onChanged: (v) => _updateRule('setsToWin', v),
            ),
            _DropdownRow<int>(
              label: loc.gamesPerSet,
              value: _intRule('gamesPerSet'),
              items: const [4, 6, 8],
              onChanged: (v) => _updateRule('gamesPerSet', v),
            ),
            _SwitchRow(
              label: loc.advantage,
              value: _boolRule('advantage'),
              onChanged: (v) => _updateRule('advantage', v),
            ),
            _SwitchRow(
              label: loc.tiebreakAtSetEnd,
              value: _boolRule('tiebreak'),
              onChanged: (v) => _updateRule('tiebreak', v),
            ),
            if (_boolRule('tiebreak'))
              _DropdownRow<int>(
                label: loc.tiebreakPoints,
                value: _intRule('tiebreakPoints'),
                items: const [7, 10],
                onChanged: (v) => _updateRule('tiebreakPoints', v),
              ),
            _SwitchRow(
              label: loc.finalSetMatchTiebreak,
              value: _boolRule('finalSetMatchTiebreak'),
              onChanged: (v) => _updateRule('finalSetMatchTiebreak', v),
            ),
            if (_boolRule('finalSetMatchTiebreak'))
              _DropdownRow<int>(
                label: loc.matchTiebreakPoints,
                value: _intRule('matchTiebreakPoints'),
                items: const [10, 15],
                onChanged: (v) => _updateRule('matchTiebreakPoints', v),
              ),
          ],
        ),

        // Time
        _ExpansionSection(
          icon: Icons.timer_outlined,
          title: loc.timeRules,
          children: [
            _DropdownRow<int>(
              label: loc.matchDurationLimit,
              value: _intRule('matchDurationMinutes'),
              items: const [0, 60, 90, 120],
              itemLabels: {
                0: loc.noLimit,
                60: loc.matchDurationMinutesValue(60),
                90: loc.matchDurationMinutesValue(90),
                120: loc.matchDurationMinutesValue(120),
              },
              onChanged: (v) => _updateRule('matchDurationMinutes', v),
            ),
            _DropdownRow<int>(
              label: loc.warmupTime,
              value: _intRule('warmupMinutes'),
              items: const [0, 3, 5],
              itemLabels: {
                0: loc.matchDurationMinutesValue(0),
                3: loc.matchDurationMinutesValue(3),
                5: loc.matchDurationMinutesValue(5),
              },
              onChanged: (v) => _updateRule('warmupMinutes', v),
            ),
            _DropdownRow<int>(
              label: loc.restBetweenSets,
              value: _intRule('restBetweenSetsMinutes'),
              items: const [0, 1, 2, 3],
              itemLabels: {
                0: loc.matchDurationMinutesValue(0),
                1: loc.matchDurationMinutesValue(1),
                2: loc.matchDurationMinutesValue(2),
                3: loc.matchDurationMinutesValue(3),
              },
              onChanged: (v) => _updateRule('restBetweenSetsMinutes', v),
            ),
            _DropdownRow<int>(
              label: loc.changeoverTime,
              value: _intRule('changeoverSeconds'),
              items: const [60, 90],
              itemLabels: {
                60: loc.changeoverSecondsValue(60),
                90: loc.changeoverSecondsValue(90),
              },
              onChanged: (v) => _updateRule('changeoverSeconds', v),
            ),
          ],
        ),

        // Court & Conduct
        _ExpansionSection(
          icon: Icons.sports_tennis_outlined,
          title: loc.courtAndConduct,
          children: [
            _SwitchRow(
              label: loc.selfRefereeing,
              value: _boolRule('selfRefereeing'),
              onChanged: (v) => _updateRule('selfRefereeing', v),
            ),
            _SwitchRow(
              label: loc.letServeReplayed,
              value: _boolRule('letServeReplayed'),
              onChanged: (v) => _updateRule('letServeReplayed', v),
            ),
            _DropdownRow<String>(
              label: loc.codeOfConduct,
              value: _stringRule('codeOfConduct'),
              items: const ['relaxed', 'enforce'],
              itemLabels: {
                'relaxed': loc.conductRelaxed,
                'enforce': loc.conductEnforce,
              },
              onChanged: (v) => _updateRule('codeOfConduct', v),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: _ballTypeController,
                decoration: InputDecoration(
                  labelText: loc.ballType,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => _updateRule('ballType', v),
              ),
            ),
          ],
        ),

        // Walkover & No-Show
        _ExpansionSection(
          icon: Icons.timer_off_outlined,
          title: loc.walkoverAndNoShow,
          children: [
            _DropdownRow<int>(
              label: loc.confirmationDeadline,
              value: _intRule('confirmationDeadlineHours'),
              items: const [1, 2, 6, 12, 24],
              itemLabels: {
                1: loc.confirmationHoursBefore(1),
                2: loc.confirmationHoursBefore(2),
                6: loc.confirmationHoursBefore(6),
                12: loc.confirmationHoursBefore(12),
                24: loc.confirmationHoursBefore(24),
              },
              onChanged: (v) => _updateRule('confirmationDeadlineHours', v),
            ),
            _DropdownRow<int>(
              label: loc.noShowGracePeriod,
              value: _intRule('noShowGraceMinutes'),
              items: const [5, 10, 15],
              itemLabels: {
                5: loc.matchDurationMinutesValue(5),
                10: loc.matchDurationMinutesValue(10),
                15: loc.matchDurationMinutesValue(15),
              },
              onChanged: (v) => _updateRule('noShowGraceMinutes', v),
            ),
            _DropdownRow<String>(
              label: loc.noShowResult,
              value: _stringRule('noShowResult'),
              items: const ['walkover', 'reschedule'],
              itemLabels: {
                'walkover': loc.noShowWalkover,
                'reschedule': loc.noShowReschedule,
              },
              onChanged: (v) => _updateRule('noShowResult', v),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Reusable row widgets ─────────────────────────────────────────────────────

class _ExpansionSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _ExpansionSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 8, bottom: 8),
        children: children,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final Map<T, String>? itemLabels;
  final ValueChanged<T> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    this.itemLabels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          const SizedBox(width: 12),
          DropdownButton<T>(
            value: value,
            isDense: true,
            underline: const SizedBox.shrink(),
            items: items
                .map((item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        itemLabels?[item] ?? item.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
