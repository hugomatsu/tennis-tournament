import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class MatchListCalendar extends ConsumerWidget {
  final List<TennisMatch> matches;
  final Widget? emptyState;
  /// Optional fallback map of categoryId → categoryName for matches that
  /// predate the categoryName field being added to the model.
  final Map<String, String> categoryNames;

  const MatchListCalendar({
    super.key,
    required this.matches,
    this.emptyState,
    this.selectionMode = false,
    this.selectedIds = const {},
    this.onToggleSelection,
    this.onLongPressMatch,
    this.categoryNames = const {},
  });

  final bool selectionMode;
  final Set<String> selectedIds;
  final Function(String)? onToggleSelection;
  final Function(String)? onLongPressMatch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    if (matches.isEmpty) {
      return emptyState ?? Center(child: Text(loc.noMatchesScheduled));
    }

    // Group matches by date
    final groupedMatches = <DateTime?, List<TennisMatch>>{};
    for (final match in matches) {
      final date = match.time != null ? DateTime(match.time!.year, match.time!.month, match.time!.day) : null;
      if (!groupedMatches.containsKey(date)) {
        groupedMatches[date] = [];
      }
      groupedMatches[date]!.add(match);
    }

    // Sort dates
    final sortedDates = groupedMatches.keys.toList()..sort((a, b) {
      if (a == null && b == null) return 0;
      if (a == null) return -1;
      if (b == null) return 1;
      return a.compareTo(b);
    });

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayMatches = groupedMatches[date]!..sort((a, b) {
          if (a.time == null && b.time == null) return 0;
          if (a.time == null) return -1;
          if (b.time == null) return 1;
          return a.time!.compareTo(b.time!);
        });

        return StickyHeader(
          header: Container(
            height: 50.0,
            color: Theme.of(context).colorScheme.surfaceContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: Text(
              date != null
                  ? DateFormat('EEEE, d \'de\' MMMM \'de\' y', Localizations.localeOf(context).toString()).format(date)
                  : loc.timeTBD,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          content: Column(
            children: dayMatches.map((match) => MatchCard(
              match: match,
              selectionMode: selectionMode,
              isSelected: selectedIds.contains(match.id),
              onToggle: onToggleSelection != null ? () => onToggleSelection!(match.id) : null,
              onLongPress: onLongPressMatch != null ? () => onLongPressMatch!(match.id) : null,
              categoryNames: categoryNames,
            )).toList(),
          ),
        );
      },
    );
  }
}

String _cardLabel(TennisMatch match, Map<String, String> categoryNames) {
  final categoryName = match.categoryName?.isNotEmpty == true
      ? match.categoryName!
      : categoryNames[match.categoryId] ?? '';
  if (categoryName.isEmpty) return match.tournamentName;
  return '${match.tournamentName} — $categoryName';
}

class MatchCard extends ConsumerWidget {
  final TennisMatch match;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onToggle;
  final VoidCallback? onLongPress;
  final Map<String, String> categoryNames;

  const MatchCard({
    super.key,
    required this.match,
    this.selectionMode = false,
    this.isSelected = false,
    this.onToggle,
    this.onLongPress,
    this.categoryNames = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUserId = currentUserAsync.value?.id;
    final isParticipant = currentUserId != null &&
        (match.player1UserIds.contains(currentUserId) || match.player2UserIds.contains(currentUserId));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isParticipant
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: selectionMode ? onToggle : () {
          context.push('/matches/${match.id}');
        },
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (selectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggle?.call(),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: tournament name + category on left, status on right
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cardLabel(match, categoryNames),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusChip(status: match.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Players row with score/time in center
                    Row(
                      children: [
                        Expanded(
                          child: PlayerInfo(
                            name: match.player1Name,
                            avatarUrls: match.player1AvatarUrls,
                            isWinner: match.winner == match.player1Name,
                            isMe: currentUserId != null && match.player1UserIds.contains(currentUserId),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: _MatchCenterLabel(match: match),
                        ),
                        Expanded(
                          child: PlayerInfo(
                            name: match.player2Name ?? 'TBD',
                            avatarUrls: match.player2AvatarUrls,
                            isWinner: match.winner != null && match.winner == match.player2Name,
                            isRightAligned: true,
                            isMe: currentUserId != null && match.player2UserIds.contains(currentUserId),
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
      ),
    );
  }
}

class _MatchCenterLabel extends StatelessWidget {
  final TennisMatch match;
  const _MatchCenterLabel({required this.match});

  @override
  Widget build(BuildContext context) {
    final isFinished = match.status == 'Finished' || match.status == 'Completed';
    if (isFinished && match.score != null && match.score!.isNotEmpty) {
      return Text(
        match.score!,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        textAlign: TextAlign.center,
      );
    }
    return Text(
      match.time != null
          ? DateFormat('HH:mm').format(match.time!)
          : AppLocalizations.of(context)!.timeTBD,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class PlayerInfo extends StatelessWidget {
  final String name;
  final List<String?> avatarUrls;
  final bool isWinner;
  final bool isRightAligned;
  final bool isMe;

  const PlayerInfo({
    super.key,
    required this.name,
    this.avatarUrls = const [],
    this.isWinner = false,
    this.isRightAligned = false,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    // Create avatar widget
    Widget avatarWidget;
    if (avatarUrls.isEmpty) {
       avatarWidget = CircleAvatar(
          radius: 20,
          child: Text(name.isNotEmpty ? name[0] : '?',
              style: const TextStyle(fontSize: 14)),
        );
    } else if (avatarUrls.length == 1) {
       final url = avatarUrls.first;
       avatarWidget = CircleAvatar(
         radius: 20,
         backgroundImage: url != null ? NetworkImage(url) : null,
         child: url == null ? Text(name.isNotEmpty ? name[0] : '?') : null,
       );
    } else {
       // Multiple avatars
       avatarWidget = SizedBox(
         width: 50,
         height: 40,
         child: Stack(
           children: [
             for (int i = 0; i < avatarUrls.length && i < 2; i++)
               Positioned(
                 left: i * 20.0,
                 child: CircleAvatar(
                   radius: 18,
                   backgroundImage: avatarUrls[i] != null ? NetworkImage(avatarUrls[i]!) : null,
                   backgroundColor: Theme.of(context).cardColor,
                   child: avatarUrls[i] == null ? Text('?') : null,
                 ),
               ),
           ],
         ),
       );
    }


    final nameText = Text(
      name + (isMe ? loc.youSuffix : ''),
      style: TextStyle(
        fontWeight: isWinner || isMe ? FontWeight.bold : FontWeight.normal,
        color: isWinner
            ? Theme.of(context).colorScheme.primary
            : (isMe ? Theme.of(context).colorScheme.secondary : null),
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: isRightAligned ? TextAlign.right : TextAlign.left,
    );

    if (isRightAligned) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(child: nameText),
          const SizedBox(width: 8),
          avatarWidget,
        ],
      );
    } else {
      return Row(
        children: [
          avatarWidget,
          const SizedBox(width: 8),
          Expanded(child: nameText),
        ],
      );
    }
  }
}

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    Color color;
    String label = status;

    if (status == 'Finished' || status == 'Completed')
      label = loc.statusCompleted;
    else if (status == 'Preparing')
      label = loc.statusPreparing;
    else if (status == 'Scheduled')
      label = loc.statusScheduled;
    else if (status == 'Confirmed')
      label = loc.statusConfirmed;
    else if (status == 'Started' || status == 'Live')
      label = loc.statusLive;

    switch (status) {
      case 'Preparing':
        color = Colors.orange;
        break;
      case 'Scheduled':
        color = Colors.blue;
        break;
      case 'Confirmed':
        color = Colors.purple;
        break;
      case 'Started':
        color = Colors.green;
        break;
      case 'Finished':
      case 'Completed':
        color = Colors.grey;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
