import 'package:flutter/material.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';

class LiveTournamentCard extends StatelessWidget {
  final Tournament tournament;

  const LiveTournamentCard({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  tournament.imageUrl.isNotEmpty
                      ? Image.network(
                          tournament.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/tournament_placeholder.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/tournament_placeholder.png',
                          fit: BoxFit.cover,
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      tournament.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        '${tournament.playersCount} Players',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tournament.location,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
