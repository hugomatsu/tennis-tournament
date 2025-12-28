import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:tennis_tournament/features/matches/presentation/widgets/match_list_calendar.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';

class MatchCalendarTab extends ConsumerStatefulWidget {
  final Tournament tournament;

  const MatchCalendarTab({super.key, required this.tournament});

  @override
  ConsumerState<MatchCalendarTab> createState() => _MatchCalendarTabState();
}

class _MatchCalendarTabState extends ConsumerState<MatchCalendarTab> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIds.clear();
    });
  }

  void _toggleMatchSelection(String matchId) {
    setState(() {
      if (_selectedIds.contains(matchId)) {
        _selectedIds.remove(matchId);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(matchId);
      }
    });
  }

  Future<void> _updateStatus(String status) async {
    if (_selectedIds.isEmpty) return;
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(matchRepositoryProvider).updateMatchesStatus(
        _selectedIds.toList(),
        status,
      );
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Updated ${_selectedIds.length} matches to $status')),
      );
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error updating matches: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchListProvider(widget.tournament.id));
    final loc = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserProvider);
    final isAdmin = userAsync.asData?.value?.userType == 'admin';

    return Stack(
      children: [
        matchesAsync.when(
          data: (matches) {
            return MatchListCalendar(
              matches: matches,
              emptyState: Center(child: Text(loc.noMatchesScheduled)),
              selectionMode: _isSelectionMode,
              selectedIds: _selectedIds,
              onToggleSelection: _toggleMatchSelection,
              onLongPressMatch: isAdmin ? (id) {
                setState(() {
                  _isSelectionMode = true;
                  _selectedIds.add(id);
                });
              } : null,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
        if (_isSelectionMode)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${_selectedIds.length} selected',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.edit_note),
                      tooltip: 'Change Status',
                      onSelected: _updateStatus,
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'Scheduled', child: Text('Mark Scheduled')),
                        const PopupMenuItem(value: 'Confirmed', child: Text('Mark Confirmed')),
                        const PopupMenuItem(value: 'Started', child: Text('Mark Started')),
                        const PopupMenuItem(value: 'Finished', child: Text('Mark Finished')),
                        const PopupMenuItem(value: 'Cancelled', child: Text('Mark Cancelled')),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _toggleSelectionMode,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Provider for fetching matches
final matchListProvider = StreamProvider.family<List<TennisMatch>, String>((ref, tournamentId) {
  return ref.watch(matchRepositoryProvider).watchMatchesForTournament(tournamentId);
});
