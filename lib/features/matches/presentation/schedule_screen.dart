import 'package:flutter/material.dart';
import 'package:tennis_tournament/core/utils/mock_data.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Schedule')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.mySchedule.length,
        itemBuilder: (context, index) {
          final daySchedule = MockData.mySchedule[index];
          final matches = daySchedule['matches'] as List;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  daySchedule['date'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...matches.map((match) => _MatchCard(match: match)),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;

  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  match['time'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  match['status'],
                  style: TextStyle(
                    fontSize: 12,
                    color: match['status'] == 'Scheduled' ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'vs ${match['opponent']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          match['tournament'],
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        match['court'],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
