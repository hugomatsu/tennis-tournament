import 'package:flutter/material.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';

class MatchCard extends StatelessWidget {
  final TennisMatch match;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool isFinal;
  final String? currentUserId;

  const MatchCard({
    super.key,
    required this.match,
    this.width = 220,
    this.height = 100,
    this.onTap,
    this.isFinal = false,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = match.status == 'Completed';
    final winnerName = match.winner;
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height + (isFinal ? 24 : 0), // Extra space for crown
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (isFinal)
            Positioned(
              top: -20,
              child: Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 24,
              ),
            ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isFinal ? Border.all(color: Colors.amber, width: 2) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPlayerRow(
                    context,
                    id: match.player1Id,
                    name: match.player1Name,
                    avatarUrl: match.player1AvatarUrl,
                    isWinner: isCompleted && winnerName == match.player1Name,
                    isTop: true,
                  ),
                  const SizedBox(height: 2), // Small gap between players
                  _buildPlayerRow(
                    context,
                    id: match.player2Id ?? '',
                    name: match.player2Name ?? 'Bye',
                    avatarUrl: match.player2AvatarUrl,
                    isWinner: isCompleted && winnerName == match.player2Name,
                    isTop: false,
                  ),
                ],
              ),
            ),
          ),
          // Status/Score Overlay
          if (isCompleted && match.score != null)
            Positioned(
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  match.score!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else if (match.status == 'Scheduled')
            Positioned(
              right: 8,
              child: Tooltip(
                message: '${match.time.month}/${match.time.day} ${match.time.hour}:${match.time.minute.toString().padLeft(2, '0')}',
                child: Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(
    BuildContext context, {
    required String id,
    required String name,
    required String? avatarUrl,
    required bool isWinner,
    required bool isTop,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMe = currentUserId != null && id == currentUserId;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isWinner
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : (isMe ? colorScheme.secondaryContainer.withValues(alpha: 0.3) : colorScheme.surfaceContainerHighest),
          borderRadius: BorderRadius.vertical(
            top: isTop ? const Radius.circular(8) : Radius.zero,
            bottom: !isTop ? const Radius.circular(8) : Radius.zero,
          ),
          border: isWinner
              ? Border.all(color: Colors.green, width: 2)
              : (isMe ? Border.all(color: colorScheme.secondary, width: 2) : Border.all(color: Colors.transparent, width: 2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
              foregroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              onForegroundImageError: avatarUrl != null && avatarUrl.isNotEmpty ? (_, __) {} : null,
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
                  fontWeight: isWinner || isMe ? FontWeight.bold : FontWeight.normal,
                  color: isWinner ? Colors.green : (isMe ? colorScheme.secondary : null),
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
