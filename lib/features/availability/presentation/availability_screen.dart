import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  // Mock data for now, would be replaced by repository
  final Map<DateTime, List<String>> _availability = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Availability')),
      body: Column(
        children: [
          // Simple Calendar View
          CalendarDatePicker(
            initialDate: _focusedDay,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (date) {
              setState(() {
                _selectedDay = date;
                _focusedDay = date;
              });
            },
          ),
          const Divider(),
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Availability for ${DateFormat('MMM d').format(_selectedDay!)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSlotChip('Morning'),
                      _buildSlotChip('Afternoon'),
                      _buildSlotChip('Evening'),
                    ],
                  ),
                ],
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select a date to mark availability'),
            ),
        ],
      ),
    );
  }

  Widget _buildSlotChip(String slot) {
    final dateKey = DateUtils.dateOnly(_selectedDay!);
    final slots = _availability[dateKey] ?? [];
    final isSelected = slots.contains(slot);

    return FilterChip(
      label: Text(slot),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            if (_availability[dateKey] == null) {
              _availability[dateKey] = [];
            }
            _availability[dateKey]!.add(slot);
          } else {
            _availability[dateKey]?.remove(slot);
          }
        });
      },
    );
  }
}
