import 'package:flutter/material.dart';

import 'package:tennis_tournament/core/utils/mock_data.dart';

class TournamentDetailScreen extends StatelessWidget {
  final String id;

  const TournamentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final tournament = MockData.liveTournaments.firstWhere(
      (t) => t['id'] == id,
      orElse: () => MockData.liveTournaments[0],
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(tournament['name'] as String),
                  background: Image.network(
                    tournament['image'] as String,
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
              const _BracketTab(),
              const Center(child: Text('Standings Placeholder')),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final Map<String, dynamic> tournament;

  const _InfoTab({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          tournament['description'] as String,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _InfoRow(icon: Icons.calendar_today, text: tournament['dates'] as String),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.location_on, text: tournament['location'] as String),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.people, text: '${tournament['players']} Players'),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {},
            child: const Text('Register Now'),
          ),
        ),
      ],
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

class _BracketTab extends StatelessWidget {
  const _BracketTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: MockData.bracket.length,
      itemBuilder: (context, index) {
        final round = MockData.bracket[index];
        final matches = round['matches'] as List;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                round['round'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            ...matches.map((m) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${m['p1']} vs ${m['p2']}'),
                    trailing: Text(
                      m['score'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: m['winner'] != ''
                        ? Text('Winner: ${m['winner']}',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary))
                        : null,
                  ),
                )),
            const SizedBox(height: 16),
          ],
        );
      },
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
