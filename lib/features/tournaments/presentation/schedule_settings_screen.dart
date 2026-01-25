import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournament_detail_screen.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class ScheduleSettingsScreen extends ConsumerStatefulWidget {
  final String tournamentId;

  const ScheduleSettingsScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<ScheduleSettingsScreen> createState() => _ScheduleSettingsScreenState();
}

class _ScheduleSettingsScreenState extends ConsumerState<ScheduleSettingsScreen> {
  // Local state to hold the edits before saving
  List<DailySchedule> _schedules = [];
  bool _initialized = false;
  bool _isLoading = false;
  bool _isCalendarView = true;
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final tournamentAsync = ref.watch(tournamentDetailProvider(widget.tournamentId));

    return tournamentAsync.when(
      data: (tournament) {
        if (tournament == null) return Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.tournamentNotFound)));
        
        if (!_initialized) {
          _initializeSchedules(tournament);
          // Set focused month to start of tournament if available
          if (_schedules.isNotEmpty) {
             final first = DateTime.tryParse(_schedules.first.date);
             if (first != null) {
               _focusedMonth = DateTime(first.year, first.month);
             }
          }
          _initialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.scheduleSettings),
            actions: [
              IconButton( 
                icon: const Icon(Icons.save),
                onPressed: _isLoading ? null : () => _saveSettings(tournament),
              ),
            ],
          ),
          floatingActionButton: _isCalendarView ? null : FloatingActionButton.extended(
            onPressed: _addNewDay,
            label: Text(AppLocalizations.of(context)!.addDate),
            icon: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Configure available times.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(value: false, icon: const Icon(Icons.list), label: Text(AppLocalizations.of(context)!.list)),
                        ButtonSegment(value: true, icon: const Icon(Icons.calendar_month), label: Text(AppLocalizations.of(context)!.calendar)),
                      ],
                      selected: {_isCalendarView},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() {
                          _isCalendarView = newSelection.first;
                        });
                      },
                      showSelectedIcon: false,
                    ),
                  ],
                ),
              ),
              if (!_isCalendarView)
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                   child: FilledButton.tonal(
                      onPressed: () => _showBulkEditDialog(),
                      child: Text(AppLocalizations.of(context)!.bulkApply),
                    ),
                 ),
              const Divider(),
              Expanded(
                child: _isCalendarView ? _buildCalendarView() : _buildListView(),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.errorOccurred(err.toString())))),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: _schedules.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final schedule = _schedules[index];
        final date = DateTime.parse(schedule.date);
        return ListTile(
          title: Text(DateFormat('EEEE, MMM d, y').format(date)),
          subtitle: Text('${schedule.startTime} - ${schedule.endTime} • ${schedule.courtCount} Courts'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editDaySchedule(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteDaySchedule(index),
              ),
            ],
          ),
          onTap: () => _editDaySchedule(index),
        );
      },
    );
  }

  Widget _buildCalendarView() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
    
    // Header for Month Navigation
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
              }),
            ),
            Text(
              DateFormat('MMMM y').format(_focusedMonth),
              style: Theme.of(context).textTheme.titleLarge,
            ),
             IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
              }),
            ),
          ],
        ),
        // Weekday Headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold)),
              )).toList(),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
            ),
            itemCount: daysInMonth + (firstWeekday - 1),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) return const SizedBox.shrink();
              
              final day = index - (firstWeekday - 1) + 1;
              final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              
              // Check if we have a schedule
              final scheduleIndex = _schedules.indexWhere((s) => s.date == dateStr);
              final hasSchedule = scheduleIndex != -1;
              
              return InkWell(
                onTap: () {
                   if (hasSchedule) {
                     _editDaySchedule(scheduleIndex);
                   } else {
                     _addSpecificDay(date);
                   }
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: hasSchedule ? Theme.of(context).colorScheme.primaryContainer : null,
                    border: Border.all(
                      color: DateUtils.isSameDay(date, DateTime.now()) 
                          ? Theme.of(context).colorScheme.primary 
                          : Colors.grey.withValues(alpha: 0.2), // Updated to withValues per lint
                      width: DateUtils.isSameDay(date, DateTime.now()) ? 2.0 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: hasSchedule || DateUtils.isSameDay(date, DateTime.now()) ? FontWeight.bold : FontWeight.normal,
                          color: hasSchedule ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                        ),
                      ),
                      if (hasSchedule) ...[
                         const SizedBox(height: 2),
                         Text(
                           '${_schedules[scheduleIndex].startTime}\n${_schedules[scheduleIndex].endTime}',
                           style: TextStyle(fontSize: 9, height: 1.1, color: Theme.of(context).colorScheme.onPrimaryContainer),
                           textAlign: TextAlign.center,
                         ),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addSpecificDay(DateTime date) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      setState(() {
        _schedules.add(DailySchedule(
          date: dateStr,
          startTime: '09:00',
          endTime: '18:00',
          courtCount: 1,
        ));
        _schedules.sort((a, b) => a.date.compareTo(b.date));
      });
      // Optionally show edit dialog immediately
      // _editDaySchedule(_schedules.indexWhere((s) => s.date == dateStr));
  }

  void _initializeSchedules(Tournament tournament) {
    if (tournament.scheduleRules.isNotEmpty) {
      _schedules = List.from(tournament.scheduleRules);
      return;
    }

    // Try to parse date range
    try {
      final parts = tournament.dateRange.split(' - ');
      if (parts.length == 2) {
        final dateFormat = DateFormat('MMMM d, y');
        final start = dateFormat.parse(parts[0]);
        final end = dateFormat.parse(parts[1]);

        final days = end.difference(start).inDays + 1;
        _schedules = List.generate(days, (index) {
          final date = start.add(Duration(days: index));
          return DailySchedule(
            date: DateFormat('yyyy-MM-dd').format(date),
            startTime: '09:00',
            endTime: '18:00',
            courtCount: 1, // Default to 1 court
          );
        });
      }
    } catch (e) {
      // Fallback if parsing fails or invalid format
      debugPrint('Error parsing dates: $e');
    }
  }

  Future<void> _editDaySchedule(int index) async {
    final schedule = _schedules[index];
    final startTimeController = TextEditingController(text: schedule.startTime);
    final endTimeController = TextEditingController(text: schedule.endTime);
    final courtsController = TextEditingController(text: schedule.courtCount.toString());

    final result = await showDialog<DailySchedule>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${schedule.date}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(labelText: 'Start Time (HH:mm)'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(labelText: 'End Time (HH:mm)'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: courtsController,
              decoration: const InputDecoration(labelText: 'Number of Courts'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
             style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
             onPressed: () {
               _deleteDaySchedule(index);
               Navigator.pop(context);
             },
             child: Text(AppLocalizations.of(context)!.delete),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, schedule.copyWith(
                startTime: startTimeController.text,
                endTime: endTimeController.text,
                courtCount: int.tryParse(courtsController.text) ?? 1,
              ));
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _schedules[index] = result;
      });
    }
  }

  Future<void> _showBulkEditDialog() async {
    final startTimeController = TextEditingController(text: '09:00');
    final endTimeController = TextEditingController(text: '18:00');
    final courtsController = TextEditingController(text: '1');

    final apply = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bulkApplySettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.applySettingsToAllDays),
            const SizedBox(height: 16),
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(labelText: 'Start Time (HH:mm)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(labelText: 'End Time (HH:mm)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: courtsController,
              decoration: const InputDecoration(labelText: 'Number of Courts'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.applyAll),
          ),
        ],
      ),
    );

    if (apply == true) {
      setState(() {
        _schedules = _schedules.map((s) => s.copyWith(
          startTime: startTimeController.text,
          endTime: endTimeController.text,
          courtCount: int.tryParse(courtsController.text) ?? 1,
        )).toList();
      });
    }
  }

  Future<void> _addNewDay() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(picked);
      // Check if already exists
      if (_schedules.any((s) => s.date == dateStr)) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.dateAlreadyExists)));
        }
        return;
      }

      setState(() {
        _schedules.add(DailySchedule(
          date: dateStr,
          startTime: '09:00',
          endTime: '18:00',
          courtCount: 1,
        ));
        // Sort by date
        _schedules.sort((a, b) => a.date.compareTo(b.date));
      });
    }
  }

  void _deleteDaySchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  Future<void> _saveSettings(Tournament tournament) async {
    setState(() => _isLoading = true);
    try {
      final updated = tournament.copyWith(scheduleRules: _schedules);
      await ref.read(tournamentRepositoryProvider).updateTournament(updated);
      ref.invalidate(tournamentDetailProvider(tournament.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.scheduleSettingsSaved)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
