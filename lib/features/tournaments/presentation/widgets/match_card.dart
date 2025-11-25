import 'package:flutter/material.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';

class MatchCard extends StatelessWidget {
  final TennisMatch match;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.match,
    this.width = 220,
    this.height = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = match.status == 'Completed';
    final winnerName = match.winner;

    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPlayerRow(
              context,
              name: match.player1Name,
              avatarUrl: match.player1AvatarUrl,
              isWinner: isCompleted && winnerName == match.player1Name,
              isTop: true,
            ),
            const SizedBox(height: 2), // Small gap between players
            _buildPlayerRow(
              context,
              name: match.player2Name ?? 'Bye',
              avatarUrl: match.player2AvatarUrl,
              isWinner: isCompleted && winnerName == match.player2Name,
              isTop: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRow(
    BuildContext context, {
    required String name,
    required String? avatarUrl,
    required bool isWinner,
    required bool isTop,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isWinner
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.vertical(
            top: isTop ? const Radius.circular(8) : Radius.zero,
            bottom: !isTop ? const Radius.circular(8) : Radius.zero,
          ),
          border: isWinner
              ? Border.all(color: Colors.green, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              backgroundColor: colorScheme.primary,
              child: avatarUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                  color: isWinner ? Colors.green : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isWinner)
              const Icon(Icons.check, size: 16, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
