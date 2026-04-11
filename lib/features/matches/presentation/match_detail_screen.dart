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
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tennis_tournament/core/sharing/widgets/share_preview_screen.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:tennis_tournament/core/analytics/analytics_service.dart';

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
  DateTime? _pendingDateTime;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logViewMatchDetail();
    });
  }

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
      ),
      bottomNavigationBar: matchAsync.when(
        data: (match) => match != null ? _buildBottomBar(match) : null,
        loading: () => null,
        error: (_, __) => null,
      ),
      body: matchAsync.when(
        data: (match) {
          if (match == null) return Center(child: Text(loc.matchNotFound));
          final isCompleted = match.status == 'Completed' || match.status == 'Finished';
          final hasWinner = match.winner != null && match.winner!.isNotEmpty;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isEditing) _buildAdminControls(match),
                if (isCompleted && hasWinner)
                  _buildWinnerCelebration(match, loc)
                else
                  _buildVsView(match),
                const SizedBox(height: 24),
                _buildInfoSection(match, loc),
                const SizedBox(height: 24),
                _buildPlayerActions(match, loc),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(AppLocalizations.of(context)!.errorOccurred(e.toString()))),
      ),
    );
  }


  void _initializeEditing(TennisMatch match) {
    if (_scoreController.text.isEmpty) {
       _scoreController.text = match.score ?? '';
    }
    _pendingStatus ??= match.status;
    _pendingWinner ??= match.winner;
    _pendingDateTime ??= match.time;
  }

  Future<void> _saveChanges() async {
    final matchAsync = ref.read(matchDetailProvider(widget.matchId));
    final match = matchAsync.value;
    if (match == null) return;

    final updatedMatch = match.copyWith(
      score: _scoreController.text,
      status: _pendingStatus ?? match.status,
      winner: _pendingWinner,
      time: _pendingDateTime ?? match.time,
    );

    if ((_pendingStatus == 'Finished' || _pendingStatus == 'Completed') &&
        _pendingWinner != null && _pendingWinner!.isNotEmpty) {
      await ref.read(matchRepositoryProvider).updateMatchScore(
        match.id,
        _scoreController.text,
        _pendingWinner!
      );
      ref.read(analyticsServiceProvider).logSubmitMatchScore(
        matchId: match.id,
        tournamentName: match.tournamentName,
      );
    } else {
      await ref.read(matchRepositoryProvider).updateMatch(updatedMatch);
    }

    setState(() {
      _isEditing = false;
      _pendingStatus = null;
      _pendingWinner = null;
      _pendingDateTime = null;
    });
  }

  Future<bool> _checkCanManage(TennisMatch match, Player user) async {
    if (user.userType == 'admin') return true;
    final isParticipant = match.player1UserIds.contains(user.id) ||
        match.player2UserIds.contains(user.id);
    if (isParticipant) return true;
    final tournament = await ref.read(tournamentRepositoryProvider).getTournament(match.tournamentId);
    if (tournament == null) return false;
    return tournament.ownerId == user.id || tournament.adminIds.contains(user.id);
  }

  Future<void> _handleFollow(TennisMatch match, Player user) async {
    final isFollowing = user.followedMatchIds.contains(match.id);
    final newList = isFollowing
        ? user.followedMatchIds.where((id) => id != match.id).toList()
        : [...user.followedMatchIds, match.id];
    await ref.read(playerRepositoryProvider).updateUser(
      user.copyWith(followedMatchIds: newList),
    );
    if (!isFollowing) {
      ref.read(analyticsServiceProvider).logFollowMatch();
    }
  }

  void _handleShare(TennisMatch match) {
    final loc = AppLocalizations.of(context)!;
    ref.read(analyticsServiceProvider).logShareMatch(
      matchId: match.id,
      tournamentName: match.tournamentName,
    );
    SharePreviewScreen.show(
      context: context,
      shareSubject: loc.shareMatch,
      shareWidget: _buildShareWidget(match),
    );
  }

  Widget _buildShareWidget(TennisMatch match) {
    final loc = AppLocalizations.of(context)!;
    final isCompleted = match.status == 'Completed' || match.status == 'Finished';
    final hasWinner = match.winner != null && match.winner!.isNotEmpty;

    if (isCompleted && hasWinner) {
      final isP1Winner = match.winner == match.player1Name;
      final winnerName = match.winner!;
      final winnerAvatarUrls = isP1Winner ? match.player1AvatarUrls : match.player2AvatarUrls;
      final loserName = isP1Winner ? (match.player2Name ?? 'TBD') : match.player1Name;
      final loserAvatarUrls = isP1Winner ? match.player2AvatarUrls : match.player1AvatarUrls;

      return Theme(
        data: ThemeData.light(),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                match.tournamentName.toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Icon(Icons.emoji_events, size: 56, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                loc.winner.toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white24,
                  backgroundImage: winnerAvatarUrls.isNotEmpty && winnerAvatarUrls.first != null
                      ? NetworkImage(winnerAvatarUrls.first!)
                      : null,
                  child: winnerAvatarUrls.isEmpty
                      ? Text(winnerName.isNotEmpty ? winnerName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white))
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(winnerName,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center),
              if (match.score != null && match.score!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                  child: Text(match.score!,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.amber.shade800)),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white30,
                    backgroundImage: loserAvatarUrls.isNotEmpty && loserAvatarUrls.first != null
                        ? NetworkImage(loserAvatarUrls.first!)
                        : null,
                    child: loserAvatarUrls.isEmpty
                        ? Text(loserName.isNotEmpty ? loserName[0] : '?',
                            style: const TextStyle(color: Colors.white))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loserName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      const Text('Runner-Up', style: TextStyle(fontSize: 11, color: Colors.white60)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_tennis, size: 14, color: Colors.white54),
                  SizedBox(width: 6),
                  Text('tennis-tournment.web.app', style: TextStyle(fontSize: 11, color: Colors.white54)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Regular VS share widget
    return Theme(
      data: ThemeData.light(),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              match.tournamentName.toUpperCase(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white24,
                          backgroundImage: match.player1AvatarUrls.isNotEmpty ? NetworkImage(match.player1AvatarUrls.first!) : null,
                          child: match.player1AvatarUrls.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(match.player1Name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 2),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                  child: const Text('VS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white24,
                          backgroundImage: match.player2AvatarUrls.isNotEmpty ? NetworkImage(match.player2AvatarUrls.first!) : null,
                          child: match.player2AvatarUrls.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(match.player2Name ?? 'TBD',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                          maxLines: 2),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(match.time != null ? DateFormat('EEE, MMM d').format(match.time!) : loc.timeTBD,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(match.time != null ? DateFormat('h:mm a').format(match.time!) : loc.timeTBD,
                style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_tennis, size: 16, color: Colors.white70),
                SizedBox(width: 8),
                Text('tennis-tournment.web.app', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(TennisMatch match) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final isFollowing = user != null && user.followedMatchIds.contains(match.id);
    final isCompleted = match.status == 'Completed' || match.status == 'Finished';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Share
                Expanded(
                  child: _BottomBarButton(
                    icon: Icons.share_outlined,
                    label: loc.share,
                    onTap: () => _handleShare(match),
                  ),
                ),
                // Follow
                Expanded(
                  child: _BottomBarButton(
                    icon: isFollowing ? Icons.bookmark : Icons.bookmark_border,
                    label: isFollowing ? loc.following : loc.follow,
                    color: isFollowing ? theme.colorScheme.primary : null,
                    onTap: user == null ? null : () => _handleFollow(match, user),
                  ),
                ),
                // Edit — only for authorized users
                if (user != null)
                  FutureBuilder<bool>(
                    future: _checkCanManage(match, user),
                    builder: (context, snapshot) {
                      if (snapshot.data != true) return const SizedBox.shrink();
                      return Expanded(
                        child: _BottomBarButton(
                          icon: _isEditing ? Icons.save_outlined : Icons.edit_outlined,
                          label: _isEditing ? loc.save : loc.edit,
                          onTap: () {
                            if (_isEditing) {
                              _saveChanges();
                            } else {
                              _initializeEditing(match);
                              setState(() => _isEditing = true);
                            }
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Add Results — always visible, disabled for non-authorized users
            if (user != null)
              FutureBuilder<bool>(
                future: _checkCanManage(match, user),
                builder: (context, snapshot) {
                  final canManage = snapshot.data ?? false;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.scoreboard_outlined),
                      label: Text(loc.addResults),
                      onPressed: (canManage && !isCompleted)
                          ? () => _showAddResultsDialog(match)
                          : null,
                    ),
                  );
                },
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.scoreboard_outlined),
                  label: Text(loc.addResults),
                  onPressed: null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddResultsDialog(TennisMatch match) async {
    final tournament = await ref.read(tournamentRepositoryProvider).getTournament(match.tournamentId);
    final setsToPlay = (tournament?.matchRules['setsToWin'] as int?) ?? 2;
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _StructuredScoreDialog(
        match: match,
        setsToPlay: setsToPlay,
        onSubmit: (score, winner, resultType) async {
          await ref.read(matchRepositoryProvider).updateMatchScore(
            match.id,
            score,
            winner,
            resultType: resultType,
          );
          ref.read(analyticsServiceProvider).logSubmitMatchScore(
            matchId: match.id,
            tournamentName: match.tournamentName,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.resultsAdded)),
            );
          }
        },
      ),
    );
  }

  Future<void> _handleDecline(TennisMatch match, String playerId) async {
    final controller = TextEditingController();
    final justified = await showDialog<String>(
      context: context,
      builder: (context) {
        final loc = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(loc.declineJustify),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: loc.reasonForUnavailability),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text(loc.cancel)
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(loc.submit),
            ),
          ],
        );
      },
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
         final loc = AppLocalizations.of(context)!;
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.responseSubmitted)));
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
         final loc = AppLocalizations.of(context)!;
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.attendanceConfirmed)));
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
    final loc = AppLocalizations.of(context)!;
    final displayDt = _pendingDateTime ?? match.time;
    final dtLabel = displayDt != null ? DateFormat('EEE, MMM d • h:mm a').format(displayDt) : loc.timeTBD;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.adminControls, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Date & time picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(loc.dateAndTime),
              subtitle: Text(dtLabel),
              contentPadding: EdgeInsets.zero,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: displayDt ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked == null || !mounted) return;
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: displayDt != null ? TimeOfDay.fromDateTime(displayDt) : TimeOfDay.now(),
                );
                if (pickedTime == null || !mounted) return;
                setState(() {
                  _pendingDateTime = DateTime(
                    picked.year, picked.month, picked.day,
                    pickedTime.hour, pickedTime.minute,
                  );
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _scoreController,
              decoration: InputDecoration(labelText: loc.score, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _pendingStatus,
              decoration: InputDecoration(labelText: loc.status),
              items: ['Preparing', 'Scheduled', 'Confirmed', 'Live', 'Completed', 'Cancelled']
                  .map((s) => DropdownMenuItem(value: s, child: Text(_getLocalizedStatus(s, loc))))
                  .toList(),
              onChanged: (val) => setState(() => _pendingStatus = val),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _pendingWinner,
              decoration: InputDecoration(labelText: loc.winner),
              items: [
                match.player1Name,
                if (match.player2Name != null) match.player2Name!
              ].toSet().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() {
                _pendingWinner = val;
                if (val != null && val.isNotEmpty) {
                  _pendingStatus = 'Completed';
                }
              }),
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
               title: Text(match.time != null ? dateFormat.format(match.time!) : loc.timeTBD),
               subtitle: Text('${_getLocalizedStatus(match.status, loc)} • ${loc.round} ${match.round}'),
             ),
              if (match.locationId != null)
                FutureBuilder(
                  future: ref.watch(locationRepositoryProvider).getLocation(match.locationId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final location = snapshot.data!;
                      return Column(
                        children: [
                          const Divider(),
                          InkWell(
                            onTap: () async {
                              final uri = Uri.parse(location.googleMapsUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (location.imageUrl != null && location.imageUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          location.imageUrl!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.location_on, size: 40, color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  else
                                    const Padding(
                                      padding: EdgeInsets.only(right: 16),
                                      child: Icon(Icons.location_on, size: 24, color: Colors.grey),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          location.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                            decorationColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        Text(
                                          loc.viewLocation,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink(); 
                  },
                ),
             const Divider(),
             ListTile(
                leading: const Icon(Icons.emoji_events),
                title: Text(match.tournamentName),
                subtitle: Text(loc.tournaments), 
                onTap: () => context.push('/tournaments/${match.tournamentId}'),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerCelebration(TennisMatch match, AppLocalizations loc) {
    final theme = Theme.of(context);
    final isP1Winner = match.winner == match.player1Name;
    final winnerName = match.winner!;
    final winnerAvatarUrls = isP1Winner ? match.player1AvatarUrls : match.player2AvatarUrls;
    final winnerUserIds = isP1Winner ? match.player1UserIds : match.player2UserIds;
    final loserName = isP1Winner ? (match.player2Name ?? 'TBD') : match.player1Name;
    final loserAvatarUrls = isP1Winner ? match.player2AvatarUrls : match.player1AvatarUrls;
    
    return Column(
      children: [
        // Winner celebration card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber.shade400,
                Colors.orange.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Trophy icon
                const Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.winner.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                // Winner avatar with golden border
                GestureDetector(
                  onTap: () {
                    if (winnerUserIds.isNotEmpty) {
                      context.push('/players/${winnerUserIds.first}');
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white24,
                      backgroundImage: winnerAvatarUrls.isNotEmpty && winnerAvatarUrls.first != null
                          ? NetworkImage(winnerAvatarUrls.first!)
                          : null,
                      child: winnerAvatarUrls.isEmpty
                          ? Text(
                              winnerName.isNotEmpty ? winnerName[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Winner name
                Text(
                  winnerName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (match.score != null && match.score!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      match.score!,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Runner-up section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: theme.colorScheme.surfaceContainerLow,
                backgroundImage: loserAvatarUrls.isNotEmpty && loserAvatarUrls.first != null
                    ? NetworkImage(loserAvatarUrls.first!)
                    : null,
                child: loserAvatarUrls.isEmpty
                    ? Text(
                        loserName.isNotEmpty ? loserName[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loserName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      loc.runnerUp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.sports_tennis,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
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
            avatarUrls: match.player1AvatarUrls,
            userIds: match.player1UserIds,
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
                AppLocalizations.of(context)!.vs,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            if (match.score != null && match.score!.isNotEmpty) ...[
               const SizedBox(height: 8),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.tertiaryContainer,
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: Text(
                   match.score!,
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 16,
                     color: Theme.of(context).colorScheme.onTertiaryContainer,
                   ),
                 ),
               ),
            ],
          ],
        ),
        Expanded(
          child: _PlayerCard(
            name: match.player2Name ?? 'TBD',
            avatarUrls: match.player2AvatarUrls,
            userIds: match.player2UserIds,
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

  String _getLocalizedStatus(String status, AppLocalizations loc) {
    switch (status) {
      case 'Preparing': return loc.statusPreparing;
      case 'Scheduled': return loc.statusScheduled;
      case 'Confirmed': return loc.statusConfirmed;
      case 'Live': return loc.statusLive;
      case 'Completed': return loc.statusCompleted;
      case 'Finished': return loc.statusCompleted; // Handle legacy/alternate
      case 'Cancelled': return loc.statusCancelled;
      default: return status;
    }
  }
}

class _PlayerCard extends ConsumerWidget {
  final String name;
  final List<String?> avatarUrls;
  final List<String> userIds;
  final bool isWinner;
  final bool isLeft;

  const _PlayerCard({
    required this.name,
    this.avatarUrls = const [],
    this.userIds = const [],
    required this.isWinner,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        borderRadius: BorderRadius.circular(16),
        side: isWinner ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 180, // Increased height for member list
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                 if (userIds.isNotEmpty) {
                   // If team, maybe show list or pick first? 
                   // Ideally prompt. For MVP, go to first user or show specific logic.
                   // If explicit userIds present, we might want to show a bottom sheet of members to visit.
                   if (userIds.length == 1) {
                      context.push('/players/${userIds.first}');
                   } else {
                      // Team: Show bottom sheet
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => ListView(
                          shrinkWrap: true,
                          children: userIds.map((uid) => ListTile(
                            title: FutureBuilder<Player?>(
                              future: ref.read(allPlayersProvider.future).then((players) => players.firstWhere((p) => p.id == uid)),
                              builder: (context, snapshot) => Text(snapshot.data?.name ?? AppLocalizations.of(context)!.loading),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/players/$uid');
                            },
                          )).toList(),
                        ),
                      );
                   }
                 }
              },
              child: Column(
                children: [
                  avatarWidget,
                  const SizedBox(height: 8),
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
                ],
              ),
            ),
             if (userIds.length > 1) ...[
                const SizedBox(height: 4),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final uid in userIds)
                          FutureBuilder<Player?>(
                            // Naive fetch for now, assuming provider caching helps or simple future
                            future: ref.watch(allPlayersProvider.future).then((players) => 
                              players.firstWhere((p) => p.id == uid, orElse: () => Player(
                                id: uid, 
                                name: AppLocalizations.of(context)!.unknownPlayer, 
                                avatarUrl: '', 
                                userType: 'player',
                                title: 'N/A',
                                category: 'N/A',
                                playingSince: 'N/A',
                                wins: 0,
                                losses: 0,
                                rank: 0,
                                bio: '',
                              ))
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox.shrink();
                              return Text(
                                snapshot.data!.name,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, color: Theme.of(context).hintColor),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
             ] else
               const Spacer(),
            if (isWinner)
              const Icon(Icons.emoji_events, size: 16, color: Colors.amber)
          ],
        ),
      ),
    );
  }
}

// ── Structured Score Entry Dialog ──────────────────────────────────────────

class _StructuredScoreDialog extends StatefulWidget {
  final TennisMatch match;
  final int setsToPlay; // e.g. 2 means "best of 2 — tiebreak decides"
  final Future<void> Function(String score, String winner, String resultType) onSubmit;

  const _StructuredScoreDialog({
    required this.match,
    required this.setsToPlay,
    required this.onSubmit,
  });

  @override
  State<_StructuredScoreDialog> createState() => _StructuredScoreDialogState();
}

class _StructuredScoreDialogState extends State<_StructuredScoreDialog> {
  bool _isWalkover = false;
  String? _selectedWinner;
  bool _isSubmitting = false;

  // Set scores: each entry is [p1Games, p2Games]
  late List<List<int>> _sets;
  // Tiebreak score: [p1Points, p2Points]
  List<int> _tiebreakScore = [0, 0];
  // Who serves first in the tiebreak: 0 = p1, 1 = p2, null = unset
  int? _tiebreakFirstServer;

  String get _p1Name => widget.match.player1Name;
  String get _p2Name => widget.match.player2Name ?? 'TBD';

  @override
  void initState() {
    super.initState();
    _sets = [for (int i = 0; i < widget.setsToPlay; i++) [0, 0]];
  }

  // Returns true if we're in tiebreak state:
  // Each player has won the same number of sets and all defined sets are done.
  bool get _isTiebreak {
    final p1Sets = _sets.where((s) => s[0] > s[1]).length;
    final p2Sets = _sets.where((s) => s[1] > s[0]).length;
    return p1Sets == widget.setsToPlay - 1 && p2Sets == widget.setsToPlay - 1;
  }

  int get _p1SetsWon => _sets.where((s) => s[0] > s[1]).length;
  int get _p2SetsWon => _sets.where((s) => s[1] > s[0]).length;

  // Current server in tiebreak rotation: first server gets 1 serve, then alternates 2 each
  int get _currentTiebreakServer {
    if (_tiebreakFirstServer == null) return -1;
    // Points 0: server=first; 1,2: other; 3,4: first; 5,6: other; ...
    final total = _tiebreakScore[0] + _tiebreakScore[1];
    if (total == 0) return _tiebreakFirstServer!;
    // After first serve, groups of 2
    final adjusted = total - 1; // 0-based after first point
    final group = adjusted ~/ 2;
    return (group % 2 == 0)
        ? (1 - _tiebreakFirstServer!)
        : _tiebreakFirstServer!;
  }

  String _buildScore() {
    if (_isWalkover) return 'W.O.';
    final parts = <String>[];
    for (int i = 0; i < widget.setsToPlay; i++) {
      parts.add('${_sets[i][0]}-${_sets[i][1]}');
    }
    if (_isTiebreak) {
      parts.add('${_tiebreakScore[0]}-${_tiebreakScore[1]}');
    }
    return parts.join(', ');
  }

  String? _deriveWinner() {
    if (_isWalkover) return _selectedWinner;
    if (_isTiebreak) {
      if (_tiebreakScore[0] > _tiebreakScore[1]) return _p1Name;
      if (_tiebreakScore[1] > _tiebreakScore[0]) return _p2Name;
      return null;
    }
    if (_p1SetsWon > _p2SetsWon) return _p1Name;
    if (_p2SetsWon > _p1SetsWon) return _p2Name;
    return null;
  }

  bool get _canSubmit {
    if (_isWalkover) return _selectedWinner != null;
    if (_isTiebreak) {
      return _tiebreakScore[0] != _tiebreakScore[1];
    }
    return _p1SetsWon != _p2SetsWon;
  }

  Future<void> _submit() async {
    final winner = _deriveWinner();
    if (winner == null) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(_buildScore(), winner, _isWalkover ? 'walkover' : 'normal');
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(loc.addResults),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(loc.markAsWalkover),
              value: _isWalkover,
              contentPadding: EdgeInsets.zero,
              dense: true,
              onChanged: (val) => setState(() {
                _isWalkover = val;
                _selectedWinner = null;
              }),
            ),
            if (_isWalkover) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedWinner,
                decoration: InputDecoration(labelText: loc.winner),
                hint: Text(loc.selectWinner),
                items: [
                  DropdownMenuItem(value: _p1Name, child: Text(_p1Name)),
                  DropdownMenuItem(value: _p2Name, child: Text(_p2Name)),
                ],
                onChanged: (val) => setState(() => _selectedWinner = val),
              ),
            ] else ...[
              const SizedBox(height: 12),
              // Sets header row
              Row(
                children: [
                  const SizedBox(width: 56),
                  Expanded(child: Text(_p1Name, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_p2Name, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)),
                ],
              ),
              const SizedBox(height: 8),
              // One row per set
              for (int i = 0; i < widget.setsToPlay; i++) ...[
                _SetRow(
                  label: '${loc.set} ${i + 1}',
                  p1Score: _sets[i][0],
                  p2Score: _sets[i][1],
                  onP1Changed: (v) => setState(() => _sets[i][0] = v),
                  onP2Changed: (v) => setState(() => _sets[i][1] = v),
                ),
                const SizedBox(height: 6),
              ],
              // Tiebreak section — shown when sets are tied
              if (_isTiebreak) ...[
                const Divider(),
                Text(
                  loc.tiebreakSectionTitle(_p1SetsWon, _p2SetsWon),
                  style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 8),
                // Choose who serves first
                if (_tiebreakFirstServer == null) ...[
                  Text(loc.initialServerQuestion, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() {
                            _tiebreakFirstServer = 0;
                          }),
                          child: Text(_p1Name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() {
                            _tiebreakFirstServer = 1;
                          }),
                          child: Text(_p2Name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Show current server
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loc.servingNow(_currentTiebreakServer == 0 ? _p1Name : _p2Name),
                      style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SetRow(
                    label: '10',
                    p1Score: _tiebreakScore[0],
                    p2Score: _tiebreakScore[1],
                    onP1Changed: (v) => setState(() => _tiebreakScore[0] = v),
                    onP2Changed: (v) => setState(() => _tiebreakScore[1] = v),
                    minVal: 0,
                    maxVal: 20,
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _tiebreakFirstServer = null;
                      _tiebreakScore = [0, 0];
                    }),
                    child: Text(loc.initialServerQuestion, style: theme.textTheme.labelSmall),
                  ),
                ],
              ],
              // Score preview
              if (_deriveWinner() != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, size: 16, color: theme.colorScheme.tertiary),
                      const SizedBox(width: 6),
                      Text(
                        '${_deriveWinner()!}  •  ${_buildScore()}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onTertiaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: (_canSubmit && !_isSubmitting) ? _submit : null,
          child: _isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(loc.submit),
        ),
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  final String label;
  final int p1Score;
  final int p2Score;
  final ValueChanged<int> onP1Changed;
  final ValueChanged<int> onP2Changed;
  final int minVal;
  final int maxVal;

  const _SetRow({
    required this.label,
    required this.p1Score,
    required this.p2Score,
    required this.onP1Changed,
    required this.onP2Changed,
    this.minVal = 0,
    this.maxVal = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Expanded(child: _ScoreSpinner(value: p1Score, onChanged: onP1Changed, min: minVal, max: maxVal)),
        const SizedBox(width: 8),
        Expanded(child: _ScoreSpinner(value: p2Score, onChanged: onP2Changed, min: minVal, max: maxVal)),
      ],
    );
  }
}

class _ScoreSpinner extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const _ScoreSpinner({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 7,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: value > min ? () => onChanged(value - 1) : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: value > min ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.remove, size: 16, color: value > min ? theme.colorScheme.onPrimaryContainer : theme.disabledColor),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: value < max ? () => onChanged(value + 1) : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: value < max ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, size: 16, color: value < max ? theme.colorScheme.onPrimaryContainer : theme.disabledColor),
          ),
        ),
      ],
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _BottomBarButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: onTap == null ? theme.disabledColor : effectiveColor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: onTap == null ? theme.disabledColor : effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
