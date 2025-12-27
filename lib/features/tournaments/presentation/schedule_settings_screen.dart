import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournament_detail_screen.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';

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

  @override
  Widget build(BuildContext context) {
    final tournamentAsync = ref.watch(tournamentDetailProvider(widget.tournamentId));

    return tournamentAsync.when(
      data: (tournament) {
        if (tournament == null) return const Scaffold(body: Center(child: Text('Tournament not found')));
        
        if (!_initialized) {
          _initializeSchedules(tournament);
          _initialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Schedule Settings'),
            actions: [
              IconButton( 
                icon: const Icon(Icons.save),
                onPressed: _isLoading ? null : () => _saveSettings(tournament),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Configure available times for each day of the tournament.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () => _showBulkEditDialog(),
                      child: const Text('Bulk Apply'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _schedules.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final schedule = _schedules[index];
                    final date = DateTime.parse(schedule.date);
                    return ListTile(
                      title: Text(DateFormat('EEEE, MMM d, y').format(date)),
                      subtitle: Text('${schedule.startTime} - ${schedule.endTime} • ${schedule.courtCount} Courts'),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _editDaySchedule(index),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, schedule.copyWith(
                startTime: startTimeController.text,
                endTime: endTimeController.text,
                courtCount: int.tryParse(courtsController.text) ?? 1,
              ));
            },
            child: const Text('Save'),
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
        title: const Text('Bulk Apply Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apply these settings to ALL days:'),
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
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply All'),
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

  Future<void> _saveSettings(Tournament tournament) async {
    setState(() => _isLoading = true);
    try {
      final updated = tournament.copyWith(scheduleRules: _schedules);
      await ref.read(tournamentRepositoryProvider).updateTournament(updated);
      ref.invalidate(tournamentDetailProvider(tournament.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule settings saved')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
