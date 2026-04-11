import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';
import 'package:tennis_tournament/features/matches/presentation/widgets/match_list_calendar.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart';

enum _StatusFilter { all, upcoming, completed }

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  _StatusFilter _statusFilter = _StatusFilter.all;
  String? _categoryFilter; // null = all categories

  List<TennisMatch> _applyFilters(List<TennisMatch> matches) {
    return matches.where((m) {
      // Status filter
      final isCompleted = m.status == 'Finished' || m.status == 'Completed';
      if (_statusFilter == _StatusFilter.upcoming && isCompleted) return false;
      if (_statusFilter == _StatusFilter.completed && !isCompleted) return false;
      // Category filter
      if (_categoryFilter != null && m.categoryName != _categoryFilter) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.mySchedule),
        centerTitle: false,
      ),
      body: scheduleAsync.when(
        data: (allMatches) {
          // Collect distinct non-empty category names for the filter chips
          final categoryNames = allMatches
              .map((m) => m.categoryName)
              .where((n) => n != null && n.isNotEmpty)
              .cast<String>()
              .toSet()
              .toList()
            ..sort();

          final filtered = _applyFilters(allMatches);

          return Column(
            children: [
              // ── Filter bar ──────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    // Status filters
                    _StatusChip(
                      label: loc.filterAll,
                      selected: _statusFilter == _StatusFilter.all,
                      onTap: () => setState(() => _statusFilter = _StatusFilter.all),
                    ),
                    const SizedBox(width: 6),
                    _StatusChip(
                      label: loc.filterUpcoming,
                      selected: _statusFilter == _StatusFilter.upcoming,
                      onTap: () => setState(() => _statusFilter = _StatusFilter.upcoming),
                    ),
                    const SizedBox(width: 6),
                    _StatusChip(
                      label: loc.filterCompleted,
                      selected: _statusFilter == _StatusFilter.completed,
                      onTap: () => setState(() => _statusFilter = _StatusFilter.completed),
                    ),
                    // Category filters — only show if there are multiple categories
                    if (categoryNames.length > 1) ...[
                      const SizedBox(width: 12),
                      VerticalDivider(width: 1, indent: 4, endIndent: 4, color: Colors.grey[400]),
                      const SizedBox(width: 12),
                      _StatusChip(
                        label: loc.filterByCategory,
                        selected: _categoryFilter == null,
                        onTap: () => setState(() => _categoryFilter = null),
                      ),
                      for (final cat in categoryNames) ...[
                        const SizedBox(width: 6),
                        _StatusChip(
                          label: cat,
                          selected: _categoryFilter == cat,
                          onTap: () => setState(() =>
                              _categoryFilter = _categoryFilter == cat ? null : cat),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              // ── Match list ──────────────────────────────────────────
              Expanded(
                child: MatchListCalendar(matches: filtered),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(AppLocalizations.of(context)!.errorOccurred(error.toString()))),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// Ensure this provider captures "Participating OR Followed" matches
final scheduleProvider = StreamProvider<List<TennisMatch>>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      final followedIds = user.followedMatchIds;
      return ref.watch(matchRepositoryProvider).watchUpcomingMatches(followedIds);
    },
    loading: () => const Stream.empty(),
    error: (e, st) => const Stream.empty(),
  );
});
