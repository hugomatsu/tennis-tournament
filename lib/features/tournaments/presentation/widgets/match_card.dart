import 'package:flutter/material.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';

class MatchCard extends StatelessWidget {
  final TennisMatch match;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = match.status == 'completed';
    final winner = match.winner;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PlayerRow(
                name: match.player1Name,
                avatarUrl: match.player1AvatarUrl,
                score: match.score?.isNotEmpty == true ? match.score!.split('-')[0] : '',
                isWinner: isCompleted && winner == match.player1Name,
              ),
              const Divider(height: 16),
              _PlayerRow(
                name: match.player2Name ?? 'Bye',
                avatarUrl: match.player2AvatarUrl,
                score: match.score?.isNotEmpty == true && match.score!.contains('-') 
                    ? match.score!.split('-')[1] 
                    : '',
                isWinner: isCompleted && winner == match.player2Name,
              ),
              if (match.status == 'Scheduled') ...[
                const SizedBox(height: 8),
                Text(
                  '${match.time.month}/${match.time.day} ${match.time.hour}:${match.time.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String score;
  final bool isWinner;

  const _PlayerRow({
    required this.name,
    this.avatarUrl,
    required this.score,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isWinner
          ? BoxDecoration(
              border: Border(left: BorderSide(color: Colors.green, width: 4)),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          if (avatarUrl != null) ...[
            CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(avatarUrl!),
            ),
            const SizedBox(width: 8),
          ] else
            const SizedBox(width: 32), // Placeholder spacing
            
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                color: isWinner ? Colors.green : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (score.isNotEmpty)
            Text(
              score,
              style: TextStyle(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }
}
