import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class LiveTournamentCard extends ConsumerWidget {
  final Tournament tournament;

  const LiveTournamentCard({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserProvider);
    final ownerAsync = ref.watch(playerProvider(tournament.ownerId ?? ''));
    
    final currentUserId = userAsync.asData?.value?.id;
    final isHostedByMe = currentUserId != null && (tournament.ownerId == currentUserId || tournament.adminIds.contains(currentUserId));

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: isHostedByMe 
            ? RoundedRectangleBorder(
                side: const BorderSide(color: Colors.amber, width: 2),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
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
                              'assets/images/default-tournament.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/default-tournament.png',
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
                  if (isHostedByMe)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              loc.yours,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                  // Owner Info
                  ownerAsync.when(
                    data: (owner) => Row(
                      children: [
                        CircleAvatar(
                           radius: 8,
                           backgroundImage: NetworkImage(owner.avatarUrl), 
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            loc.hostedBy(owner.name),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox(height: 16), // Placeholder height
                    error: (_,__) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        '${tournament.playersCount}',
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
