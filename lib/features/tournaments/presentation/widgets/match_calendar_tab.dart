import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:tennis_tournament/features/matches/presentation/widgets/match_list_calendar.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';
import 'package:tennis_tournament/features/tournaments/application/single_elimination_service.dart';
import 'package:tennis_tournament/features/tournaments/application/tournament_providers.dart';

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
        if (_selectedIds.isEmpty) _isSelectionMode = false;
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
      final loc = AppLocalizations.of(context)!;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(loc.updatedMatchesStatus(_selectedIds.length, status))),
      );
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
    } catch (e) {
      final loc = AppLocalizations.of(context)!;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(loc.errorUpdatingMatches(e.toString()))),
      );
    }
  }

  Future<void> _autoScheduleSelected(List<TennisMatch> allMatches) async {
    if (_selectedIds.isEmpty) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final loc = AppLocalizations.of(context)!;
    final selectedMatches = allMatches.where((m) => _selectedIds.contains(m.id)).toList();
    final occupiedMatches = allMatches.where((m) => !_selectedIds.contains(m.id)).toList();
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    startDate = DateTime(startDate.year, startDate.month, startDate.day, 9, 0);
    try {
      final updatedMatches = await ref
          .read(schedulingServiceForTournamentProvider(widget.tournament.tournamentType))
          .assignSlotsToMatches(
            widget.tournament,
            selectedMatches,
            startDate,
            additionalOccupiedMatches: occupiedMatches,
          );
      final repo = ref.read(matchRepositoryProvider);
      for (final m in updatedMatches) {
        await repo.updateMatch(m);
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(loc.updatedMatchesStatus(_selectedIds.length, "Scheduled"))),
      );
      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(loc.errorUpdatingMatches(e.toString()))),
      );
    }
  }

  Future<void> _exportCsv(List<TennisMatch> matches, Map<String, String> categoryNames) async {
    final loc = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final csv = _buildCsv(matches, categoryNames);
      final bytes = Uint8List.fromList(csv.codeUnits);
      final fileName =
          '${widget.tournament.name.replaceAll(RegExp(r'[^\w]'), '_')}_matches';
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.custom,
        customMimeType: 'text/csv',
      );
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(loc.exportCsvSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(loc.exportCsvError(e.toString()))),
        );
      }
    }
  }

  String _buildCsv(List<TennisMatch> matches, Map<String, String> categoryNames) {
    // Sort: by date then round then matchIndex
    final sorted = [...matches]..sort((a, b) {
        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return 1;
        if (b.time == null) return -1;
        final timeCmp = a.time!.compareTo(b.time!);
        if (timeCmp != 0) return timeCmp;
        final roundCmp = a.round.compareTo(b.round);
        if (roundCmp != 0) return roundCmp;
        return a.matchIndex.compareTo(b.matchIndex);
      });

    final buf = StringBuffer();
    // Header
    buf.writeln('Round,Category,Date,Time,Court,Player 1,Player 2,Status,Score,Winner');

    final dateFmt = DateFormat('yyyy-MM-dd');
    final timeFmt = DateFormat('HH:mm');

    String escape(String? v) {
      if (v == null || v.isEmpty) return '';
      if (v.contains(',') || v.contains('"') || v.contains('\n')) {
        return '"${v.replaceAll('"', '""')}"';
      }
      return v;
    }

    String resolveCategory(TennisMatch m) {
      final name = m.categoryName?.isNotEmpty == true
          ? m.categoryName!
          : categoryNames[m.categoryId] ?? '';
      if (name.isEmpty) return m.tournamentName;
      return '${m.tournamentName} — $name';
    }

    for (final m in sorted) {
      buf.writeln([
        escape(m.round),
        escape(resolveCategory(m)),
        m.time != null ? dateFmt.format(m.time!) : '',
        m.time != null ? timeFmt.format(m.time!) : '',
        escape(m.court),
        escape(m.player1Name),
        escape(m.player2Name),
        escape(m.status),
        escape(m.score),
        escape(m.winner),
      ].join(','));
    }

    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchListProvider(widget.tournament.id));
    final categoriesAsync = ref.watch(tournamentCategoriesProvider(widget.tournament.id));
    final loc = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.asData?.value;
    final isAdmin = user != null &&
        (widget.tournament.ownerId == user.id ||
            widget.tournament.adminIds.contains(user.id));

    // Build categoryId → name fallback map for older matches without categoryName
    final categoryNames = <String, String>{
      for (final c in categoriesAsync.asData?.value ?? []) c.id: c.name,
    };

    return Stack(
      children: [
        matchesAsync.when(
          data: (matches) {
            return MatchListCalendar(
              matches: matches,
              categoryNames: categoryNames,
              emptyState: Center(child: Text(loc.noMatchesScheduled)),
              selectionMode: _isSelectionMode,
              selectedIds: _selectedIds,
              onToggleSelection: _toggleMatchSelection,
              onLongPressMatch: isAdmin
                  ? (id) {
                      setState(() {
                        _isSelectionMode = true;
                        _selectedIds.add(id);
                      });
                    }
                  : null,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text(loc.errorGeneric(e.toString()))),
        ),
        // Admin toolbar — shown when not in selection mode
        if (isAdmin && !_isSelectionMode)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'export_csv',
              tooltip: loc.exportCsv,
              onPressed: () => _exportCsv(matchesAsync.value ?? [], categoryNames),
              child: const Icon(Icons.download),
            ),
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
                      loc.nSelected(_selectedIds.length),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.auto_fix_high),
                      tooltip: loc.autoScheduleDates,
                      onPressed: () => _autoScheduleSelected(matchesAsync.value ?? []),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.edit_note),
                      tooltip: loc.changeStatus,
                      onSelected: _updateStatus,
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'Scheduled', child: Text(loc.markScheduled)),
                        PopupMenuItem(value: 'Confirmed', child: Text(loc.markConfirmed)),
                        PopupMenuItem(value: 'Started', child: Text(loc.markStarted)),
                        PopupMenuItem(value: 'Finished', child: Text(loc.markFinished)),
                        PopupMenuItem(value: 'Cancelled', child: Text(loc.markCancelled)),
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
