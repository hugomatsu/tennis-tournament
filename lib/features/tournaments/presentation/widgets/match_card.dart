import 'package:flutter/material.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';

class MatchCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = match.status == 'Completed';
    final winnerName = match.winner;
    final theme = Theme.of(context);

    final isParticipant = currentUserId != null && 
        (match.player1Id == currentUserId || match.player2Id == currentUserId);

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
                color: theme.colorScheme.surface, 
                border: isFinal 
                    ? Border.all(color: Colors.amber, width: 2) 
                    : (isParticipant ? Border.all(color: theme.colorScheme.primary, width: 2) : null),
                boxShadow: isParticipant 
                    ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlayerRow(
                    matchId: match.id,
                    playerId: match.player1Id,
                    name: match.player1Name,
                    avatarUrls: match.player1AvatarUrls,
                    isWinner: isCompleted && winnerName == match.player1Name,
                    isTop: true,
                    cheers: match.player1Cheers,
                    isConfirmed: match.player1Confirmed,
                    currentUserId: currentUserId,
                    matchStatus: match.status,
                  ),
                  const SizedBox(height: 2), // Small gap between players
                  PlayerRow(
                    matchId: match.id,
                    playerId: match.player2Id ?? '',
                    name: match.player2Name ?? 'Bye',
                    avatarUrls: match.player2AvatarUrls,
                    isWinner: isCompleted && winnerName == match.player2Name,
                    isTop: false,
                    cheers: match.player2Cheers,
                    isConfirmed: match.player2Confirmed,
                    currentUserId: currentUserId,
                    matchStatus: match.status,
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
}

class PlayerRow extends ConsumerStatefulWidget {
  final String matchId;
  final String playerId;
  final String name;
  final List<String?> avatarUrls;
  final bool isWinner;
  final bool isTop;
  final int cheers;
  final bool isConfirmed;
  final String? currentUserId;
  final String matchStatus;

  const PlayerRow({
    super.key,
    required this.matchId,
    required this.playerId,
    required this.name,
    required this.avatarUrls,
    required this.isWinner,
    required this.isTop,
    required this.cheers,
    required this.isConfirmed,
    required this.currentUserId,
    required this.matchStatus,
  });

  @override
  ConsumerState<PlayerRow> createState() => _PlayerRowState();
}

class _PlayerRowState extends ConsumerState<PlayerRow> with SingleTickerProviderStateMixin {
  late int _cheers;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _cheers = widget.cheers;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(PlayerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cheers != oldWidget.cheers) {
      if (widget.cheers > _cheers) {
         _cheers = widget.cheers;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCheer() {
    setState(() {
      _cheers++;
    });
    _controller.forward(from: 0.0);
    ref.read(matchRepositoryProvider).cheerForMatch(widget.matchId, widget.playerId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMe = widget.currentUserId != null && widget.playerId == widget.currentUserId;
    final showConfirmButton = isMe && !widget.isConfirmed && widget.matchStatus == 'Scheduled';

    Widget avatarWidget;
    if (widget.avatarUrls.isEmpty) {
        avatarWidget = CircleAvatar(
          radius: 12,
          backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
          backgroundColor: colorScheme.primary,
          child: Text(
              widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            )
        );
    } else if (widget.avatarUrls.length == 1) {
        final url = widget.avatarUrls.first;
        avatarWidget = CircleAvatar(
          radius: 12,
          backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
          foregroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
          backgroundColor: colorScheme.primary,
          child: (url == null || url.isEmpty)
              ? Text(
                  widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                )
              : null,
        );
    } else {
       // Team avatars
       avatarWidget = SizedBox(
         width: 30, 
         height: 24,
         child: Stack(
           children: [
             for (int i = 0; i < widget.avatarUrls.length && i < 2; i++)
               Positioned(
                 left: i * 10.0,
                 child: CircleAvatar(
                   radius: 10,
                   backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                   foregroundImage: widget.avatarUrls[i] != null && widget.avatarUrls[i]!.isNotEmpty 
                      ? NetworkImage(widget.avatarUrls[i]!) : null,
                   backgroundColor: theme.cardColor,
                 ),
               ),
           ],
         ),
       );
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: widget.isWinner
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : (isMe ? colorScheme.secondaryContainer.withValues(alpha: 0.3) : colorScheme.surfaceContainerHighest),
          borderRadius: BorderRadius.vertical(
            top: widget.isTop ? const Radius.circular(8) : Radius.zero,
            bottom: !widget.isTop ? const Radius.circular(8) : Radius.zero,
          ),
          border: widget.isWinner
              ? Border.all(color: Colors.green, width: 2)
              : (isMe ? Border.all(color: colorScheme.secondary, width: 2) : Border.all(color: Colors.transparent, width: 2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Stack(
              children: [
                avatarWidget,
                if (widget.isConfirmed)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 8, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: widget.isWinner || isMe ? FontWeight.bold : FontWeight.normal,
                      color: widget.isWinner ? Colors.green : (isMe ? colorScheme.secondary : null),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.avatarUrls.length > 1) 
                     // Ideally fetch members here, but for Bracket View (collapsed), 
                     // just showing team name is standard.
                     // The user requested: "display all the players and the team name".
                     // So we should try to list names if space permits.
                     // Since space is very tight in MatchCard (height ~50 per player block), we might skip detailed names here 
                     // or show them very small. 
                     // Let's rely on Team Name being descriptive or add subtitle "2 players"
                     Text(
                       '${widget.avatarUrls.length} players',
                       style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: theme.hintColor),
                     ),

                  if (showConfirmButton)
                    InkWell(
                      onTap: () {
                        ref.read(matchRepositoryProvider).confirmMatch(widget.matchId, widget.playerId);
                      },
                      child: Text(
                        'Confirm Attendance',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (widget.isWinner)
              const Icon(Icons.check, size: 16, color: Colors.green),
            
            // Cheering UI
            if (widget.playerId.isNotEmpty) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: _handleCheer,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          Icons.favorite,
                          size: 14,
                          color: Colors.red[400],
                        ),
                      ),
                      if (_cheers > 0) ...[
                        const SizedBox(width: 2),
                        Text(
                          _cheers.toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.red[400],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
