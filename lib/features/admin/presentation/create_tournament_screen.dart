import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/core/theme/tournament_type_theme.dart';
import 'package:tennis_tournament/features/locations/presentation/location_picker.dart';
import 'package:tennis_tournament/features/media/presentation/media_library_picker.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/match_rule_presets.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournaments_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/match_rules_editor.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:tennis_tournament/core/analytics/analytics_service.dart';

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends ConsumerState<CreateTournamentScreen> {
  // ── Form controllers ────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // ── Form state ──────────────────────────────────────────────────────────
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLocationId;
  String _tournamentType = 'mataMata';
  int _maxPlayersPerGroup = 4;
  int _pointsPerWin = 3;
  int _advanceCount = 2;
  int _courtCount = 2;
  bool _isLoading = false;
  bool _isPrivate = false;
  final Map<int, ({TimeOfDay start, TimeOfDay end})> _weekdayTimes = {};
  Map<String, dynamic> _matchRules = {...kDefaultMatchRules};

  // ── Step state ──────────────────────────────────────────────────────────
  int _currentStep = 0;
  bool _isForward = true;

  // ── Validation ──────────────────────────────────────────────────────────
  bool get _canAdvance => switch (_currentStep) {
        0 => _nameController.text.trim().isNotEmpty,
        _ => true,
      };

  // ── Navigation ──────────────────────────────────────────────────────────
  void _advance() {
    if (_currentStep < 3) {
      setState(() { _isForward = true; _currentStep++; });
    } else {
      _createTournament();
    }
  }

  void _goBack() {
    if (_currentStep > 0) setState(() { _isForward = false; _currentStep--; });
  }

  void _jumpToStep(int step) {
    if (step < _currentStep) setState(() { _isForward = false; _currentStep = step; });
  }

  // ── Pickers ─────────────────────────────────────────────────────────────

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            AppBar(
              title: Text(AppLocalizations.of(context)!.selectLocation),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: LocationPicker(
                onLocationSelected: (location) {
                  setState(() {
                    _locationController.text = location.name;
                    _selectedLocationId = location.id;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _showMediaLibrary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            AppBar(
              title: Text(AppLocalizations.of(context)!.selectImage),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: MediaLibraryPicker(
                onImageSelected: (asset) {
                  setState(() {
                    _imageUrlController.text = asset.url;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Schedule helpers ─────────────────────────────────────────────────────

  Widget _buildWeekdayRow(BuildContext context, int weekday, String label) {
    final isSelected = _weekdayTimes.containsKey(weekday);
    final range = _weekdayTimes[weekday];
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _weekdayTimes[weekday] = (
                      start: const TimeOfDay(hour: 9, minute: 0),
                      end: const TimeOfDay(hour: 18, minute: 0),
                    );
                  } else {
                    _weekdayTimes.remove(weekday);
                  }
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? null : Theme.of(context).hintColor,
              ),
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            _buildTimePicker(
              context,
              label: l10n.startTime,
              time: range!.start,
              onPicked: (picked) => setState(() {
                _weekdayTimes[weekday] = (start: picked, end: range.end);
              }),
            ),
            const SizedBox(width: 8),
            Text('–', style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(width: 8),
            _buildTimePicker(
              context,
              label: l10n.endTime,
              time: range.end,
              onPicked: (picked) => setState(() {
                _weekdayTimes[weekday] = (start: range.start, end: picked);
              }),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context, {
    required String label,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onPicked,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          helpText: label,
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          time.format(context),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> _createTournament() async {
    if (_nameController.text.trim().isEmpty) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectDateRange)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final playerRepo = ref.read(playerRepositoryProvider);
      final tournamentRepo = ref.read(tournamentRepositoryProvider);
      final l10n = AppLocalizations.of(context)!;

      final currentUser = await playerRepo.getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.pleaseLogIn)),
          );
        }
        return;
      }

      if (!currentUser.isPremium) {
        final count = await tournamentRepo.getUserTournamentCount(currentUser.id);
        if (count >= 2) {
          if (mounted) {
            _showUpsellDialog(context, l10n);
            setState(() => _isLoading = false);
            return;
          }
        }
      }

      final dateFormat = DateFormat('MMMM d, y');
      final dateRangeString =
          '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}';

      final tournament = Tournament(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        locationId: _selectedLocationId,
        ownerId: currentUser.id,
        adminIds: [currentUser.id],
        description: _descriptionController.text.trim(),
        dateRange: dateRangeString,
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : 'https://via.placeholder.com/400x200',
        status: 'Upcoming',
        playersCount: 0,
        subscriptionTier: currentUser.isPremium ? 'Premium' : 'Free',
        tournamentType: _tournamentType,
        groupCount: _maxPlayersPerGroup,
        pointsPerWin: _pointsPerWin,
        advanceCount: _advanceCount,
        matchRules: _matchRules,
        isPrivate: _isPrivate,
        defaultWeekdayTimes: _weekdayTimes.map(
          (key, range) {
            String fmt(TimeOfDay t) =>
                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
            return MapEntry(key.toString(), '${fmt(range.start)}-${fmt(range.end)}');
          },
        ),
      );

      await tournamentRepo.createTournament(tournament);

      ref.read(analyticsServiceProvider).logCreateTournament(
            tournamentType: _tournamentType,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tournamentCreated)),
        );
        ref.invalidate(filteredTournamentsProvider(const TournamentFilterParams(mine: true)));
        ref.invalidate(filteredTournamentsProvider(const TournamentFilterParams()));
        context.pushReplacement('/tournaments/${tournament.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorOccurred(e.toString())),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showUpsellDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.freeLimitReached),
        content: Text(l10n.freeLimitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/subscription');
            },
            child: Text(l10n.upgradeToPremium),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stepLabels = [
      l10n.stepVisao,
      l10n.stepLogistica,
      l10n.stepRegras,
      l10n.stepRevisao,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createTournament)),
      body: Column(
        children: [
          _StepperHeader(
            currentStep: _currentStep,
            labels: stepLabels,
            onStepTap: _jumpToStep,
          ),
          const Divider(height: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation) {
                final isIncoming = child.key == ValueKey(_currentStep);
                final enterOffset = _isForward
                    ? const Offset(1.0, 0)
                    : const Offset(-1.0, 0);
                final exitOffset = _isForward
                    ? const Offset(-0.35, 0)
                    : const Offset(0.35, 0);
                final slide = isIncoming
                    ? Tween<Offset>(begin: enterOffset, end: Offset.zero)
                    : Tween<Offset>(begin: exitOffset, end: Offset.zero);
                return SlideTransition(
                  position: slide.animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_currentStep),
                child: switch (_currentStep) {
                  0 => _buildStep0(l10n),
                  1 => _buildStep1(l10n),
                  2 => _buildStep2(l10n),
                  _ => _buildStep3(l10n),
                },
              ),
            ),
          ),
          const Divider(height: 1),
          _FooterNav(
            currentStep: _currentStep,
            canAdvance: _canAdvance,
            isLoading: _isLoading,
            isLastStep: _currentStep == 3,
            onBack: _goBack,
            onAdvance: _advance,
          ),
        ],
      ),
    );
  }

  // ── Step 0: Visão ────────────────────────────────────────────────────────

  Widget _buildStep0(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            icon: Icons.emoji_events_outlined,
            title: l10n.tournamentName,
            children: [
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.tournamentName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.emoji_events),
                ),
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.sports_tennis_outlined,
            title: l10n.tournamentMode,
            children: [
              _ModeCard(
                type: 'mataMata',
                label: l10n.mataMataElimination,
                tagline: l10n.mataMataDescription,
                explanation: l10n.mataMataExplanation,
                isSelected: _tournamentType == 'mataMata',
                onTap: () => setState(() => _tournamentType = 'mataMata'),
              ),
              const SizedBox(height: 8),
              _ModeCard(
                type: 'openTennis',
                label: l10n.openTennisGroups,
                tagline: l10n.openTennisDescription,
                explanation: l10n.openTennisExplanation,
                isSelected: _tournamentType == 'openTennis',
                onTap: () => setState(() => _tournamentType = 'openTennis'),
              ),
              const SizedBox(height: 8),
              _ModeCard(
                type: 'americano',
                label: l10n.americanoGroups,
                tagline: l10n.americanoDescription,
                explanation: l10n.americanoExplanation(5),
                isSelected: _tournamentType == 'americano',
                onTap: () => setState(() => _tournamentType = 'americano'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 1: Logística ────────────────────────────────────────────────────

  Widget _buildStep1(AppLocalizations l10n) {
    final dateFormat = DateFormat('MMM d, y');
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            icon: Icons.location_on_outlined,
            title: l10n.location,
            children: [
              InkWell(
                onTap: _showLocationPicker,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(
                    _locationController.text.isEmpty
                        ? l10n.selectLocation
                        : _locationController.text,
                    style: TextStyle(
                      color: _locationController.text.isEmpty
                          ? theme.hintColor
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.date_range_outlined,
            title: l10n.dateRange,
            children: [
              if (_startDate == null || _endDate == null)
                OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.calendar_month),
                  label: Text(l10n.selectPeriod),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                )
              else
                Row(
                  children: [
                    Chip(
                      avatar: const Icon(Icons.calendar_today, size: 16),
                      label: Text(dateFormat.format(_startDate!)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward, size: 16),
                    ),
                    Chip(
                      avatar: const Icon(Icons.calendar_today, size: 16),
                      label: Text(dateFormat.format(_endDate!)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _selectDateRange(context),
                      tooltip: l10n.edit,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.stadium_outlined,
            title: l10n.numberOfCourts,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.outlined(
                    onPressed: _courtCount > 1
                        ? () => setState(() => _courtCount--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$_courtCount',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton.outlined(
                    onPressed: () => setState(() => _courtCount++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.schedule_outlined,
            title: l10n.defaultSchedule,
            subtitle: l10n.selectWeekdayTimes,
            children: [
              _buildWeekdayRow(context, 1, l10n.mondayShort),
              _buildWeekdayRow(context, 2, l10n.tuesdayShort),
              _buildWeekdayRow(context, 3, l10n.wednesdayShort),
              _buildWeekdayRow(context, 4, l10n.thursdayShort),
              _buildWeekdayRow(context, 5, l10n.fridayShort),
              _buildWeekdayRow(context, 6, l10n.saturdayShort),
              _buildWeekdayRow(context, 7, l10n.sundayShort),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 2: Regras ───────────────────────────────────────────────────────

  Widget _buildStep2(AppLocalizations l10n) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_tournamentType == 'openTennis') ...[
            _SectionCard(
              icon: Icons.groups_outlined,
              title: l10n.tournamentMode,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.openTennisExplanation, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _maxPlayersPerGroup.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.numberOfGroups,
                    helperText: l10n.autoGroupsHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.group),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _maxPlayersPerGroup = int.tryParse(v) ?? 4,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _pointsPerWin.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.pointsPerWin,
                    helperText: l10n.pointsPerWinHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.emoji_events),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _pointsPerWin = int.tryParse(v) ?? 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _advanceCount.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.advanceFromGroup,
                    helperText: l10n.advanceFromGroupHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.arrow_upward),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _advanceCount = int.tryParse(v) ?? 1,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _matchRules['scoringMode'] as String? ?? 'flat',
                  decoration: InputDecoration(
                    labelText: l10n.scoringMode,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.scoreboard),
                  ),
                  items: [
                    DropdownMenuItem(value: 'flat', child: Text(l10n.flatScoring)),
                    DropdownMenuItem(value: 'variable', child: Text(l10n.variableScoring)),
                  ],
                  onChanged: (value) => setState(() { _matchRules['scoringMode'] = value ?? 'flat'; }),
                ),
                if (_matchRules['scoringMode'] == 'variable') ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PointsChip(label: l10n.pointsWin2_0Label, ruleKey: 'pointsWin2_0', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsWin2_0'] = v)),
                      _PointsChip(label: l10n.pointsWin2_1Label, ruleKey: 'pointsWin2_1', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsWin2_1'] = v)),
                      _PointsChip(label: l10n.pointsWinWOLabel, ruleKey: 'pointsWinWO', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsWinWO'] = v)),
                      _PointsChip(label: l10n.pointsLoss1_2Label, ruleKey: 'pointsLoss1_2', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsLoss1_2'] = v)),
                      _PointsChip(label: l10n.pointsLoss0_2Label, ruleKey: 'pointsLoss0_2', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsLoss0_2'] = v)),
                      _PointsChip(label: l10n.pointsLossWOLabel, ruleKey: 'pointsLossWO', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsLossWO'] = v)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _matchRules['matchFormat'] as String? ?? 'roundRobin',
                  decoration: InputDecoration(
                    labelText: l10n.matchFormatLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.swap_horiz),
                  ),
                  items: [
                    DropdownMenuItem(value: 'roundRobin', child: Text(l10n.roundRobinFormat)),
                    DropdownMenuItem(value: 'crossGroup', child: Text(l10n.crossGroupFormat)),
                  ],
                  onChanged: (value) => setState(() { _matchRules['matchFormat'] = value ?? 'roundRobin'; }),
                ),
                if (_matchRules['matchFormat'] == 'crossGroup') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: (_matchRules['matchesPerPlayer'] ?? 5).toString(),
                    decoration: InputDecoration(
                      labelText: l10n.matchesPerPlayer,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.repeat),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _matchRules['matchesPerPlayer'] = int.tryParse(v) ?? 5,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (_tournamentType == 'americano') ...[
            _SectionCard(
              icon: Icons.shuffle_outlined,
              title: l10n.tournamentMode,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.americanoExplanation(_matchRules['guaranteedMatches'] as int? ?? 5),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _maxPlayersPerGroup.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.numberOfGroups,
                    helperText: l10n.autoGroupsHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.group),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _maxPlayersPerGroup = int.tryParse(v) ?? 4,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: (_matchRules['guaranteedMatches'] as int? ?? 5).toString(),
                  decoration: InputDecoration(
                    labelText: l10n.guaranteedMatches,
                    helperText: l10n.guaranteedMatchesHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.repeat),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => _matchRules['guaranteedMatches'] = int.tryParse(v) ?? 5),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _pointsPerWin.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.pointsPerWin,
                    helperText: l10n.pointsPerWinHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.emoji_events),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _pointsPerWin = int.tryParse(v) ?? 3,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _matchRules['scoringMode'] as String? ?? 'flat',
                  decoration: InputDecoration(
                    labelText: l10n.scoringMode,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.scoreboard),
                  ),
                  items: [
                    DropdownMenuItem(value: 'flat', child: Text(l10n.flatScoring)),
                    DropdownMenuItem(value: 'variable', child: Text(l10n.variableScoring)),
                  ],
                  onChanged: (value) => setState(() { _matchRules['scoringMode'] = value ?? 'flat'; }),
                ),
                if (_matchRules['scoringMode'] == 'variable') ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PointsChip(label: l10n.pointsWin2_0Label, ruleKey: 'pointsWin2_0', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsWin2_0'] = v)),
                      _PointsChip(label: l10n.pointsWin2_1Label, ruleKey: 'pointsWin2_1', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsWin2_1'] = v)),
                      _PointsChip(label: l10n.pointsWinWOLabel, ruleKey: 'pointsWinWO', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsWinWO'] = v)),
                      _PointsChip(label: l10n.pointsLoss1_2Label, ruleKey: 'pointsLoss1_2', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsLoss1_2'] = v)),
                      _PointsChip(label: l10n.pointsLoss0_2Label, ruleKey: 'pointsLoss0_2', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsLoss0_2'] = v)),
                      _PointsChip(label: l10n.pointsLossWOLabel, ruleKey: 'pointsLossWO', rules: _matchRules, onChanged: (v) => setState(() => _matchRules['pointsLossWO'] = v)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _matchRules['opponentSelection'] as String? ?? 'random',
                  decoration: InputDecoration(
                    labelText: l10n.opponentSelectionLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.shuffle),
                  ),
                  items: [
                    DropdownMenuItem(value: 'random', child: Text(l10n.randomOpponents)),
                    DropdownMenuItem(value: 'ranked', child: Text(l10n.rankedOpponents)),
                  ],
                  onChanged: (value) => setState(() { _matchRules['opponentSelection'] = value ?? 'random'; }),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          _SectionCard(
            icon: Icons.rule_outlined,
            title: l10n.matchRules,
            children: [
              MatchRulesEditor(
                initialRules: _matchRules,
                onChanged: (rules) => setState(() => _matchRules = rules),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 3: Revisão ──────────────────────────────────────────────────────

  Widget _buildStep3(AppLocalizations l10n) {
    final dateFormat = DateFormat('MMM d, y');
    final theme = Theme.of(context);
    final typeTheme = TournamentTypeTheme.of(_tournamentType);

    final modeLabel = switch (_tournamentType) {
      'openTennis' => l10n.openTennisGroups,
      'americano' => l10n.americanoGroups,
      _ => l10n.mataMataElimination,
    };

    final rulesSummary = l10n.rulesScoringSummary(
      _matchRules['setsToWin'] as int? ?? 2,
      _matchRules['gamesPerSet'] as int? ?? 6,
    );

    final sortedDays = (_weekdayTimes.keys.toList()..sort());
    final scheduleText = _weekdayTimes.isEmpty ? '—' : '${sortedDays.length} dias/semana';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Identity review
          _ReviewSection(
            title: l10n.reviewIdentity,
            onEdit: () => _jumpToStep(0),
            l10n: l10n,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _nameController.text.trim().isEmpty ? '—' : _nameController.text.trim(),
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: typeTheme.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(typeTheme.icon, size: 16, color: typeTheme.color),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    modeLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(color: typeTheme.color, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Logistics review
          _ReviewSection(
            title: l10n.reviewLogistics,
            onEdit: () => _jumpToStep(1),
            l10n: l10n,
            children: [
              _ReviewRow(Icons.location_on_outlined, _locationController.text.isEmpty ? '—' : _locationController.text),
              const SizedBox(height: 4),
              _ReviewRow(
                Icons.date_range_outlined,
                _startDate == null
                    ? '—'
                    : '${dateFormat.format(_startDate!)} – ${dateFormat.format(_endDate!)}',
              ),
              const SizedBox(height: 4),
              _ReviewRow(Icons.stadium_outlined, '$_courtCount ${l10n.numberOfCourts.toLowerCase()}'),
              if (_weekdayTimes.isNotEmpty) ...[
                const SizedBox(height: 4),
                _ReviewRow(Icons.schedule_outlined, scheduleText),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Rules review
          _ReviewSection(
            title: l10n.matchRules,
            onEdit: () => _jumpToStep(2),
            l10n: l10n,
            children: [
              _ReviewRow(Icons.rule_outlined, rulesSummary),
            ],
          ),
          const SizedBox(height: 12),

          // Description & cover
          _SectionCard(
            icon: Icons.description_outlined,
            title: l10n.description,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                minLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: l10n.coverImageUrl,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.image),
                      ),
                      readOnly: true,
                      onTap: _showMediaLibrary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _showMediaLibrary,
                    icon: const Icon(Icons.photo_library),
                    tooltip: l10n.selectFromLibrary,
                  ),
                ],
              ),
              if (_imageUrlController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageUrlController.text,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Privacy
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(_isPrivate ? l10n.tournamentPrivate : l10n.tournamentPublic),
              subtitle: Text(_isPrivate ? l10n.tournamentPrivateDesc : l10n.tournamentPublicDesc),
              value: _isPrivate,
              onChanged: (val) => setState(() => _isPrivate = val),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stepper Header ─────────────────────────────────────────────────────────────

class _StepperHeader extends StatelessWidget {
  final int currentStep;
  final List<String> labels;
  final ValueChanged<int> onStepTap;

  const _StepperHeader({
    required this.currentStep,
    required this.labels,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < 4; i++) ...[
                _StepCircle(
                  number: i + 1,
                  isCompleted: i < currentStep,
                  isCurrent: i == currentStep,
                  primary: primary,
                  onTap: i < currentStep ? () => onStepTap(i) : null,
                ),
                if (i < 3)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      height: 2,
                      color: i < currentStep ? primary : Colors.grey.shade300,
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (int i = 0; i < 4; i++) ...[
                SizedBox(
                  width: 28,
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: i == currentStep ? FontWeight.bold : FontWeight.normal,
                      color: i <= currentStep ? primary : Colors.grey,
                    ),
                    overflow: TextOverflow.visible,
                    maxLines: 1,
                  ),
                ),
                if (i < 3) const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final bool isCompleted;
  final bool isCurrent;
  final Color primary;
  final VoidCallback? onTap;

  const _StepCircle({
    required this.number,
    required this.isCompleted,
    required this.isCurrent,
    required this.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = isCompleted || isCurrent;

    final innerCircle = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? primary : Colors.transparent,
        border: Border.all(
          color: filled ? primary : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? Colors.white : Colors.grey.shade400,
                ),
              ),
            ),
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: isCurrent ? 36 : 28,
        height: isCurrent ? 36 : 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isCurrent
              ? Border.all(color: primary.withValues(alpha: 0.3), width: 3)
              : null,
        ),
        child: Center(child: innerCircle),
      ),
    );
  }
}

// ── Footer Navigation ──────────────────────────────────────────────────────────

class _FooterNav extends StatelessWidget {
  final int currentStep;
  final bool canAdvance;
  final bool isLoading;
  final bool isLastStep;
  final VoidCallback onBack;
  final VoidCallback onAdvance;

  const _FooterNav({
    required this.currentStep,
    required this.canAdvance,
    required this.isLoading,
    required this.isLastStep,
    required this.onBack,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            if (currentStep > 0)
              OutlinedButton.icon(
                onPressed: isLoading ? null : onBack,
                icon: const Icon(Icons.chevron_left),
                label: Text(l10n.back),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            const Spacer(),
            FilledButton(
              onPressed: (canAdvance && !isLoading) ? onAdvance : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isLastStep ? l10n.createTournament : l10n.advance),
                        const SizedBox(width: 6),
                        Icon(isLastStep ? Icons.check : Icons.chevron_right, size: 18),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mode Card ──────────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final String type;
  final String label;
  final String tagline;
  final String explanation;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.type,
    required this.label,
    required this.tagline,
    required this.explanation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = TournamentTypeTheme.of(type);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? t.background : theme.cardTheme.color ?? theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? t.border : theme.dividerColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? t.color.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                t.icon,
                color: isSelected ? t.color : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? t.color : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tagline,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? t.color.withValues(alpha: 0.8)
                          : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    alignment: Alignment.topLeft,
                    child: isSelected
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(height: 1, color: t.border),
                                const SizedBox(height: 8),
                                Text(
                                  explanation,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    height: 1.5,
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? t.color : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Review Section ─────────────────────────────────────────────────────────────

class _ReviewSection extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final AppLocalizations l10n;
  final List<Widget> children;

  const _ReviewSection({
    required this.title,
    required this.onEdit,
    required this.l10n,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(l10n.edit),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ReviewRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

// ── Section Card ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(subtitle!, style: theme.textTheme.bodySmall),
            ),
          ],
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ── Points Chip ────────────────────────────────────────────────────────────────

class _PointsChip extends StatelessWidget {
  final String label;
  final String ruleKey;
  final Map<String, dynamic> rules;
  final ValueChanged<int> onChanged;

  const _PointsChip({
    required this.label,
    required this.ruleKey,
    required this.rules,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = (rules[ruleKey] as int?) ?? 0;
    return InputChip(
      label: Text('$label: $value'),
      labelStyle: theme.textTheme.bodySmall,
      onPressed: () async {
        final ctrl = TextEditingController(text: value.toString());
        final result = await showDialog<int>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(label),
            content: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(ctx)!.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text) ?? 0),
                child: Text(AppLocalizations.of(ctx)!.submit),
              ),
            ],
          ),
        );
        if (result != null) onChanged(result);
      },
    );
  }
}
