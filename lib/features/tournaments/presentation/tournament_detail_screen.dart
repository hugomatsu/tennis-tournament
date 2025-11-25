import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';
import 'package:tennis_tournament/features/players/presentation/profile_screen.dart';
import 'package:tennis_tournament/features/tournaments/application/single_elimination_service.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/tournaments/presentation/widgets/bracket_view.dart';

final tournamentDetailProvider = FutureProvider.family<Tournament?, String>((ref, id) {
  return ref.watch(tournamentRepositoryProvider).getTournament(id);
});

class TournamentDetailScreen extends ConsumerWidget {
  final String id;

  const TournamentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(tournamentDetailProvider(id));
    final userAsync = ref.watch(currentUserProvider);

    return tournamentAsync.when(
      data: (tournament) {
        if (tournament == null) {
          return const Scaffold(body: Center(child: Text('Tournament not found')));
        }
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    actions: [
                      if (userAsync.asData?.value?.userType == 'admin')
                        IconButton(
                          icon: const Icon(Icons.shuffle),
                          tooltip: 'Generate Bracket',
                          onPressed: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            try {
                              // 1. Fetch players
                              final players = await ref
                                  .read(playerRepositoryProvider)
                                  .getPlayersForTournament(tournament.id);

                              if (players.length < 2) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Not enough players to generate bracket')),
                                );
                                return;
                              }

                              // 2. Generate matches
                              final matches = await ref
                                  .read(schedulingServiceProvider)
                                  .generateBracket(tournament, players);

                              // 3. Save matches
                              await ref.read(matchRepositoryProvider).createMatches(matches);

                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Generated ${matches.length} matches!')),
                              );
                            } catch (e) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(tournament.name),
                      background: Image.network(
                        tournament.imageUrl,
                        fit: BoxFit.cover,
                        color: Colors.black.withValues(alpha: 0.4),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        tabs: [
                          Tab(text: 'Info'),
                          Tab(text: 'Bracket'),
                          Tab(text: 'Standings'),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _InfoTab(tournament: tournament),
                  BracketView(tournament: tournament),
                  const Center(child: Text('Standings Placeholder')),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

class _InfoTab extends ConsumerWidget {
  final Tournament tournament;

  const _InfoTab({required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(tournament.description),
        const SizedBox(height: 24),
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.calendar_today, text: tournament.dateRange),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.location_on, text: tournament.location),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.people, text: '${tournament.playersCount} Players'),
        const SizedBox(height: 32),
        const SizedBox(height: 32),
        _JoinTournamentButton(
          tournament: tournament,
          currentUser: userAsync.asData?.value,
        ),
      ],
    );
  }
}

class _JoinTournamentButton extends ConsumerStatefulWidget {
  final Tournament tournament;
  final Player? currentUser;

  const _JoinTournamentButton({
    required this.tournament,
    required this.currentUser,
  });

  @override
  ConsumerState<_JoinTournamentButton> createState() => _JoinTournamentButtonState();
}

class _JoinTournamentButtonState extends ConsumerState<_JoinTournamentButton> {
  bool _isLoading = false;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  @override
  void didUpdateWidget(_JoinTournamentButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUser != widget.currentUser) {
      _checkRegistration();
    }
  }

  Future<void> _checkRegistration() async {
    if (widget.currentUser == null) {
      if (mounted) setState(() => _isRegistered = false);
      return;
    }

    final isRegistered = await ref
        .read(tournamentRepositoryProvider)
        .isPlayerRegistered(widget.tournament.id, widget.currentUser!.id);
    
    if (mounted) {
      setState(() => _isRegistered = isRegistered);
    }
  }

  Future<void> _joinTournament() async {
    if (widget.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to join')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(tournamentRepositoryProvider)
          .joinTournament(widget.tournament.id, widget.currentUser!.id);
      
      if (mounted) {
        setState(() => _isRegistered = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined tournament!')),
        );
        ref.invalidate(tournamentDetailProvider(widget.tournament.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isRegistered) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: null,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check),
              SizedBox(width: 8),
              Text('Registered'),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isLoading ? null : _joinTournament,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Join Tournament'),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
