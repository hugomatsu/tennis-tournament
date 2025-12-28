import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/locations/data/location_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

final matchDetailProvider = StreamProvider.family<TennisMatch?, String>((ref, matchId) {
  return ref.watch(matchRepositoryProvider).watchMatch(matchId);
});

class MatchDetailScreen extends ConsumerStatefulWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  // Admin Editing State
  bool _isEditing = false;
  String? _pendingStatus;
  String? _pendingWinner;
  
  @override
  void dispose() {
    _scoreController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.matchDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
               // Share feature
            },
          ),
          if (_isEditing)
             IconButton(
               icon: const Icon(Icons.save),
               onPressed: _saveChanges,
             )
          // Add admin edit button check here if needed
        ],
      ),
      body: matchAsync.when(
        data: (match) {
           if (match == null) return const Center(child: Text('Match not found'));

           // Use local _initializeEditing once if needed, or rely on state
           // Since we use a provider, valid to just read data.

           return SingleChildScrollView(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 if (_isEditing) _buildAdminControls(match), // You might need to check if you have this method or restore it too. 
                 // Assuming _buildAdminControls is further down or needs verification.
                 // Wait, I saw _buildAdminControls comment in the file view.
                 
                 _buildVsView(match),
                 const SizedBox(height: 24),
                 _buildInfoSection(match, loc),
                 const SizedBox(height: 24),
                 _buildPlayerActions(match, loc),
               ],
             ),
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _initializeEditing(TennisMatch match) {
    if (_scoreController.text.isEmpty) {
       _scoreController.text = match.score ?? '';
    }
    _pendingStatus ??= match.status;
    _pendingWinner ??= match.winner;
  }

  Future<void> _saveChanges() async {
    final matchAsync = ref.read(matchDetailProvider(widget.matchId));
    final match = matchAsync.value;
    if (match == null) return;

    final updatedMatch = match.copyWith(
      score: _scoreController.text,
      status: _pendingStatus ?? match.status,
      winner: _pendingWinner,
      // Location and Time updates would go here in a full implementation
    );

    // If winner changed and status is Finished/Completed, trigger updateMatchScore
    if ((_pendingStatus == 'Finished' || _pendingStatus == 'Completed') && 
        _pendingWinner != null && _pendingWinner!.isNotEmpty) {
      await ref.read(matchRepositoryProvider).updateMatchScore(
        match.id, 
        _scoreController.text, 
        _pendingWinner!
      );
    } else {
      // Just update match details
      await ref.read(matchRepositoryProvider).updateMatch(updatedMatch);
    }

    setState(() {
      _isEditing = false;
      _pendingStatus = null;
      _pendingWinner = null;
    });
  }

  Future<void> _handleDecline(TennisMatch match, String playerId) async {
    final controller = TextEditingController();
    final justified = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline & Justify'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason for unavailability'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (justified != null && justified.isNotEmpty) {
      final isP1 = match.player1UserIds.contains(playerId);
       // We can set confirmed to false explicitly, and save justification
       final updated = match.copyWith(
         player1Confirmed: isP1 ? false : match.player1Confirmed,
         player2Confirmed: !isP1 ? false : match.player2Confirmed,
         player1Justification: isP1 ? justified : match.player1Justification,
         player2Justification: !isP1 ? justified : match.player2Justification,
       );
       await ref.read(matchRepositoryProvider).updateMatch(updated);
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Response submitted. Admin notified.')));
       }
    }
  }

  Future<void> _handleConfirm(TennisMatch match, String playerId) async {
      final isP1 = match.player1UserIds.contains(playerId);
      final updated = match.copyWith(
         player1Confirmed: isP1 ? true : match.player1Confirmed,
         player2Confirmed: !isP1 ? true : match.player2Confirmed,
      );
      
      // Check if both confirmed -> status = Confirmed
      var finalMatch = updated;
      if (updated.player1Confirmed && updated.player2Confirmed && updated.status == 'Scheduled') {
        finalMatch = updated.copyWith(status: 'Confirmed');
      }

      await ref.read(matchRepositoryProvider).updateMatch(finalMatch);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance confirmed!')));
      }
  }

  Future<void> _togglePlayerConfirmation(TennisMatch match, String infoId, bool isConfirmed) async {
    // Note: infoId passed here is likely the team ID (participant ID) or legacy user ID
    // Check if it matches team ID or contained in user IDs
    final isP1 = match.player1Id == infoId || match.player1UserIds.contains(infoId);
    
    // We update the match immediately
    var updated = match.copyWith(
      player1Confirmed: isP1 ? isConfirmed : match.player1Confirmed,
      player2Confirmed: !isP1 ? isConfirmed : match.player2Confirmed,
    );

    // Auto-confirm status if both present
    // Only if match is currently Scheduled or Preparing
    if ((updated.status == 'Scheduled' || updated.status == 'Preparing') && 
        updated.player1Confirmed && 
        (updated.player2Name == null || updated.player2Confirmed)) {
        updated = updated.copyWith(status: 'Confirmed');
    }

    await ref.read(matchRepositoryProvider).updateMatch(updated);
    // No need to set state as stream will update UI
  }
  
  Widget _buildAdminControls(TennisMatch match) {
      if (!_isEditing) return const SizedBox.shrink();
      
      return Card(
        color: Colors.orange.shade50,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Admin Controls', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _scoreController,
                decoration: const InputDecoration(labelText: 'Score', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _pendingStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Scheduled', 'Confirmed', 'Live', 'Completed', 'Cancelled']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _pendingStatus = val),
              ),
              const SizedBox(height: 8),
               DropdownButtonFormField<String>(
                value: _pendingWinner,
                decoration: const InputDecoration(labelText: 'Winner'),
                items: [
                  match.player1Name, 
                  if (match.player2Name != null) match.player2Name!
                ].toSet().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _pendingWinner = val),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildInfoSection(TennisMatch match, AppLocalizations loc) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
             ListTile(
               leading: const Icon(Icons.calendar_today),
               title: Text(dateFormat.format(match.time)),
               subtitle: Text(match.status),
             ),
             const Divider(),
             ListTile(
               leading: const Icon(Icons.stadium),
               title: Text(match.court),
               subtitle: Text('${loc.round} ${match.round}'),
             ),
             if (match.locationId != null) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('View Location'), // Placeholder for location name lookup
                  onTap: () {
                     // Launch map logic
                  },
                ),
             ],
          ],
        ),
      ),
    );
  }

  Widget _buildVsView(TennisMatch match) {
    return Row(
      children: [
        Expanded(
          child: _PlayerCard(
            name: match.player1Name,
            avatarUrls: match.player1AvatarUrls,
            isWinner: match.winner == match.player1Name,
            isLeft: true,
          ),
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                'VS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: _PlayerCard(
            name: match.player2Name ?? 'TBD',
            avatarUrls: match.player2AvatarUrls,
            isWinner: match.winner != null && match.winner == match.player2Name,
            isLeft: false,
          ),
        ),
      ],
    );
  }
  
  // ... (keep _buildInfoSection)

  Widget _buildPlayerActions(TennisMatch match, AppLocalizations loc) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    if (user == null) return const SizedBox.shrink();

    final isP1 = match.player1UserIds.contains(user.id);
    final isP2 = match.player2UserIds.contains(user.id);

    if (!isP1 && !isP2) return const SizedBox.shrink();

    if (match.status != 'Scheduled') return const SizedBox.shrink();

    final isConfirmed = isP1 ? match.player1Confirmed : match.player2Confirmed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isConfirmed ? loc.youHaveConfirmed : loc.pleaseConfirm,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isConfirmed ? Colors.green : Colors.orange,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (!isConfirmed)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleDecline(match, user.id),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: Text(loc.decline),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _handleConfirm(match, user.id),
                  icon: const Icon(Icons.check),
                  label: Text(loc.confirm),
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  // ... (keep _buildAdminControls)

}

class _PlayerCard extends StatelessWidget {
  final String name;
  final List<String?> avatarUrls;
  final bool isWinner;
  final bool isLeft;

  const _PlayerCard({
    required this.name,
    this.avatarUrls = const [],
    required this.isWinner,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    // Create avatar widget
    Widget avatarWidget;
    if (avatarUrls.isEmpty) {
       avatarWidget = CircleAvatar(
          radius: 30,
          backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
          child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(fontSize: 20)),
        );
    } else if (avatarUrls.length == 1) {
       final url = avatarUrls.first;
       avatarWidget = CircleAvatar(
          radius: 30,
          backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
          foregroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
          onForegroundImageError: url != null && url.isNotEmpty ? (_, __) {} : null,
          child: (url == null || url.isEmpty) 
             ? Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(fontSize: 20)) 
             : null,
       );
    } else {
       // Multiple avatars
       avatarWidget = SizedBox(
         width: 80,
         height: 60,
         child: Stack(
           alignment: Alignment.center,
           children: [
             for (int i = 0; i < avatarUrls.length && i < 2; i++)
               Positioned(
                 left: i * 30.0,
                 child: CircleAvatar(
                   radius: 25,
                   backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
                    foregroundImage: avatarUrls[i] != null && avatarUrls[i]!.isNotEmpty ? NetworkImage(avatarUrls[i]!) : null,
                   backgroundColor: Theme.of(context).cardColor,
                 ),
               ),
           ],
         ),
       );
    }

    return Card(
      elevation: isWinner ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          bottomLeft: const Radius.circular(12),
          topRight: isLeft ? Radius.zero : const Radius.circular(12),
          bottomRight: isLeft ? Radius.zero : const Radius.circular(12),
        ),
        side: isWinner ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 140, // Fixed height for alignment
        child: Column(
          children: [
            avatarWidget,
            const Spacer(),
            Text(
              name, 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWinner ? Theme.of(context).colorScheme.primary : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isWinner) 
              const Icon(Icons.emoji_events, size: 16, color: Colors.amber)
          ],
        ),
      ),
    );
  }
}
