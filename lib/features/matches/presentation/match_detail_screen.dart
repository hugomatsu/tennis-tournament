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
      final isP1 = match.player1Id == playerId;
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
      final isP1 = match.player1Id == playerId;
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

  Future<void> _togglePlayerConfirmation(TennisMatch match, String playerId, bool isConfirmed) async {
    final isP1 = match.player1Id == playerId;
    
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

  Future<void> _showRescheduleDialog(TennisMatch match) async {
    // 1. Pick Date
    final newDate = await showDatePicker(
      context: context,
      initialDate: match.time,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (newDate == null) return;

    // 2. Pick Time
    if (!mounted) return;
    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(match.time),
    );
    if (newTime == null) return;

    final dateTime = DateTime(newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);

    // 3. Pick Court (Simulated for now, would ideally fetch from Location)
    // We can just keep the current court or allow edit text.
    // Let's use a simple dialog step or just assume same court, offering text field.
    String court = match.court;
    
    // Check conflicts
    final hasConflict = await _checkForConflicts(dateTime, court, match.id, match.tournamentId, match.durationMinutes);
    
    if (!mounted) return;
    
    if (hasConflict) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Conflict Detected'),
          content: Text('There is already a match listed on $court at this time.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Book Anyway')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    // Update
    final updated = match.copyWith(time: dateTime, court: court, status: 'Scheduled'); 
    await ref.read(matchRepositoryProvider).updateMatch(updated);
    
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Match Rescheduled')));
       setState(() => _isEditing = false);
    }
  }

  Future<void> _toggleFollow(Player user, String matchId) async {
    final currentFollowed = List<String>.from(user.followedMatchIds);
    if (currentFollowed.contains(matchId)) {
      currentFollowed.remove(matchId);
    } else {
      currentFollowed.add(matchId);
    }

    // Update user in repository
    // We need to create a slightly modified copy of Player because User is immutable generated
    final updatedUser = user.copyWith(followedMatchIds: currentFollowed);
    
    // We use ref.read(playerRepositoryProvider) but we need to ensure it's imported (added in previous step)
    await ref.read(playerRepositoryProvider).updateUser(updatedUser);
    
    // Invalidate currentUserProvider to trigger UI rebuild
    ref.invalidate(currentUserProvider);
  }

  Future<bool> _checkForConflicts(DateTime start, String court, String matchId, String tournamentId, int durationMinutes) async {
    final matches = await ref.read(matchRepositoryProvider).getMatchesForTournament(tournamentId);
    final end = start.add(Duration(minutes: durationMinutes));

    for (var m in matches) {
      if (m.id == matchId) continue;
      if (m.court != court) continue; 
      // Simplify court check (text based match)
      // Check time overlaps
      final mStart = m.time;
      final mEnd = m.time.add(Duration(minutes: m.durationMinutes));

      if (start.isBefore(mEnd) && end.isAfter(mStart)) {
        return true;
      }
    }
    return false;
  }

  String _getLocalizedStatus(AppLocalizations loc, String status) {
    if (status == 'Finished') return loc.statusFinished;
    switch (status) {
      case 'Preparing': return loc.statusPreparing;
      case 'Scheduled': return loc.statusScheduled;
      case 'Confirmed': return loc.statusConfirmed;
      case 'Started': return loc.statusStarted;
      case 'Completed': return loc.statusCompleted;
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));
    final userAsync = ref.watch(currentUserProvider);
    final isAdmin = userAsync.value?.userType == 'admin';
    final loc = AppLocalizations.of(context)!;

    return matchAsync.when(
      data: (match) {
        if (match == null) {
          return const Scaffold(
            body: Center(child: Text('Match not found')),
          );
        }

        if (_isEditing) {
          _initializeEditing(match);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(loc.matchDetails),
            actions: [
              if (userAsync.value != null)
                IconButton(
                  icon: Icon(
                    userAsync.value!.followedMatchIds.contains(match.id)
                        ? Icons.star
                        : Icons.star_border,
                    color: userAsync.value!.followedMatchIds.contains(match.id)
                        ? Colors.amber
                        : null,
                  ),
                  tooltip: userAsync.value!.followedMatchIds.contains(match.id)
                      ? loc.unfollow
                      : loc.follow,
                  onPressed: () => _toggleFollow(userAsync.value!, match.id),
                ),
              if (isAdmin && !_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                      _scoreController.text = match.score ?? '';
                      _pendingStatus = match.status;
                      _pendingWinner = match.winner;
                    });
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header (Status & Time)
                _buildHeader(match, loc),
                const SizedBox(height: 24),
                
                // Players VS View
                _buildVsView(match),
                
                const SizedBox(height: 32),
                
                // Location & Details
                _buildInfoSection(match, loc),

                 const SizedBox(height: 32),

                // Admin Controls
                if (_isEditing) _buildAdminControls(match, loc),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildHeader(TennisMatch match, AppLocalizations loc) {
    Color statusColor;
    switch (match.status) {
      case 'Preparing': statusColor = Colors.orange; break;
      case 'Scheduled': statusColor = Colors.blue; break;
      case 'Confirmed': statusColor = Colors.purple; break;
      case 'Started': statusColor = Colors.green; break;
      case 'Finished': 
      case 'Completed': statusColor = Colors.grey; break;
      default: statusColor = Colors.blueGrey;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            _getLocalizedStatus(loc, match.status).toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          DateFormat('EEEE, MMMM d, y • HH:mm').format(match.time),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        if (match.score != null && match.score!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              match.score!,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVsView(TennisMatch match) {
    return Row(
      children: [
        Expanded(
          child: _PlayerCard(
            name: match.player1Name,
            avatarUrl: match.player1AvatarUrl,
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
            avatarUrl: match.player2AvatarUrl,
            isWinner: match.winner != null && match.winner == match.player2Name,
            isLeft: false,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(TennisMatch match, AppLocalizations loc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (match.locationId != null)
              Consumer(builder: (context, ref, child) {
                  return FutureBuilder(
                    future: ref.watch(locationRepositoryProvider).getLocation(match.locationId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                         final place = snapshot.data!;
                         return InkWell(
                           onTap: () async {
                               final uri = Uri.parse(place.googleMapsUrl);
                             if (await canLaunchUrl(uri)) {
                               await launchUrl(uri);
                             }
                           },
                           child: Row(
                             children: [
                               const Icon(Icons.location_on, color: Colors.red),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.blue)),
                                      Text('${place.numberOfCourts} Courts available', style: Theme.of(context).textTheme.bodySmall),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         );
                      }
                      return const SizedBox.shrink();
                    }
                  );
              })
            else if (match.court.isNotEmpty)
               Row(
                 children: [
                   const Icon(Icons.location_on, color: Colors.red),
                   const SizedBox(width: 12),
                   Text(match.court),
                 ],
               ),
            
             const Divider(height: 24),
             
             Row(
               children: [
                 const Icon(Icons.timer, color: Colors.orange),
                 const SizedBox(width: 12),
                 Text('${match.durationMinutes} minutes'),
               ],
             ),

              const Divider(height: 24),

             Row(
               children: [
                 const Icon(Icons.emoji_events, color: Colors.amber),
                 const SizedBox(width: 12),
                 Text(match.round),
               ],
             ),

             const Divider(height: 24),
             _buildPlayerActions(match, loc),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerActions(TennisMatch match, AppLocalizations loc) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    if (user == null) return const SizedBox.shrink();

    final isP1 = match.player1Id == user.id;
    final isP2 = match.player2Id == user.id;

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

  Widget _buildAdminControls(TennisMatch match, AppLocalizations loc) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(loc.adminControls, style: Theme.of(context).textTheme.titleMedium),
                 TextButton.icon(
                   onPressed: () => _showRescheduleDialog(match),
                   icon: const Icon(Icons.calendar_month),
                   label: Text(loc.reschedule),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             
             if (match.player1Justification != null)
                Text('Player 1 Declined: ${match.player1Justification}', style: const TextStyle(color: Colors.red)),
             if (match.player2Justification != null)
                Text('Player 2 Declined: ${match.player2Justification}', style: const TextStyle(color: Colors.red)),
             
             if (match.player1Justification != null || match.player2Justification != null)
                const SizedBox(height: 16),

             const SizedBox(height: 16),
             
             Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text(match.player1Name, style: const TextStyle(fontSize: 12)),
                    value: match.player1Confirmed,
                    onChanged: (val) => _togglePlayerConfirmation(match, match.player1Id, val!),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (match.player2Name != null) ...[
                 const SizedBox(width: 8),
                 Expanded(
                  child: CheckboxListTile(
                    title: Text(match.player2Name!, style: const TextStyle(fontSize: 12)),
                    value: match.player2Confirmed,
                    onChanged: (val) => _togglePlayerConfirmation(match, match.player2Id!, val!),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                 ),
                ],
               ],
             ),

             const SizedBox(height: 16),

             DropdownButtonFormField<String>(
               value: _pendingStatus,
               decoration: const InputDecoration(labelText: 'Status'),
               items: [
                 DropdownMenuItem(value: 'Preparing', child: Text(loc.statusPreparing)),
                 DropdownMenuItem(value: 'Scheduled', child: Text(loc.statusScheduled)),
                 DropdownMenuItem(value: 'Confirmed', child: Text(loc.statusConfirmed)),
                 DropdownMenuItem(value: 'Started', child: Text(loc.statusStarted)),
                 DropdownMenuItem(value: 'Completed', child: Text(loc.statusCompleted)),
               ],
               onChanged: (val) => setState(() => _pendingStatus = val),
             ),
             
             const SizedBox(height: 16),
             
             TextField(
               controller: _scoreController,
               decoration: InputDecoration(labelText: loc.score),
             ),
             
             const SizedBox(height: 16),
             
             Text(loc.winner),
             RadioListTile<String>(
                title: Text(match.player1Name),
                value: match.player1Name,
                groupValue: _pendingWinner,
                onChanged: (val) => setState(() => _pendingWinner = val),
             ),
             RadioListTile<String>(
                title: Text(match.player2Name ?? 'TBD'),
                value: match.player2Name ?? 'TBD',
                groupValue: _pendingWinner,
                onChanged: (val) => setState(() => _pendingWinner = val),
             ),
             
             const SizedBox(height: 16),
             
             Row(
               children: [
                 Expanded(
                   child: OutlinedButton(
                     onPressed: () => setState(() => _isEditing = false),
                     child: Text(loc.cancel),
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: FilledButton(
                     onPressed: _saveChanges,
                     child: Text(loc.saveChanges),
                   ),
                 ),
               ],
             ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isWinner;
  final bool isLeft;

  const _PlayerCard({
    required this.name,
    this.avatarUrl,
    required this.isWinner,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
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
            CircleAvatar(
              radius: 30,
              backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
              foregroundImage: avatarUrl != null && avatarUrl!.isNotEmpty ? NetworkImage(avatarUrl!) : null,
              onForegroundImageError: avatarUrl != null && avatarUrl!.isNotEmpty ? (_, __) {} : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty) 
                  ? Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(fontSize: 20)) 
                  : null,
            ),
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
