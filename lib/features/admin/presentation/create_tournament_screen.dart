import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/locations/presentation/location_picker.dart';
import 'package:tennis_tournament/features/media/presentation/media_library_picker.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournaments_screen.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:tennis_tournament/core/analytics/analytics_service.dart';

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends ConsumerState<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLocationId;
  String _tournamentType = 'mataMata';
  int _maxPlayersPerGroup = 4;
  int _pointsPerWin = 3;
  bool _isLoading = false;
  final Map<int, ({TimeOfDay start, TimeOfDay end})> _weekdayTimes = {};

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // ── Pickers ───────────────────────────────────────────────────────────────

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

  // ── Schedule helpers ───────────────────────────────────────────────────────

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

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) return;

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
        groupCount: _maxPlayersPerGroup, // stores maxPlayersPerGroup
        pointsPerWin: _pointsPerWin,
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createTournament)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section 1: Basic info ──────────────────────────────────
              _SectionCard(
                icon: Icons.emoji_events_outlined,
                title: l10n.tournamentName,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.tournamentName,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.emoji_events),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? l10n.enterName : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: l10n.location,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    onTap: _showLocationPicker,
                    validator: (value) =>
                        value == null || value.isEmpty ? l10n.pleaseSelectLocation : null,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _selectDateRange(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.dateRange,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.date_range),
                      ),
                      child: Text(
                        _startDate != null && _endDate != null
                            ? '${dateFormat.format(_startDate!)} – ${dateFormat.format(_endDate!)}'
                            : l10n.selectDates,
                        style: TextStyle(
                          color: _startDate != null
                              ? theme.textTheme.bodyLarge?.color
                              : theme.hintColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Section 2: Schedule ────────────────────────────────────
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

              // ── Section 3: Format ──────────────────────────────────────
              _SectionCard(
                icon: Icons.sports_tennis_outlined,
                title: l10n.tournamentMode,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _tournamentType,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.sports_tennis),
                      helperText: _tournamentType == 'mataMata'
                          ? l10n.mataMataDescription
                          : l10n.openTennisDescription,
                      helperMaxLines: 2,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'mataMata',
                        child: Text(l10n.mataMataElimination),
                      ),
                      DropdownMenuItem(
                        value: 'openTennis',
                        child: Text(l10n.openTennisGroups),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _tournamentType = value ?? 'mataMata'),
                  ),
                  if (_tournamentType == 'openTennis') ...[
                    const SizedBox(height: 12),
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
                          Icon(Icons.info_outline,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.openTennisExplanation,
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
                      onChanged: (v) =>
                          _maxPlayersPerGroup = int.tryParse(v) ?? 4,
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
                  ],
                ],
              ),

              // ── Section 4: Presentation ────────────────────────────────
              _SectionCard(
                icon: Icons.image_outlined,
                title: l10n.description,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
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
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 6,
                    minLines: 3,
                  ),
                ],
              ),

              // ── Submit ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _createTournament,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.createTournament),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
