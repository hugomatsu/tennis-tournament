import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/players/data/player_repository.dart';
import 'package:tennis_tournament/features/players/domain/player.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class ManageAdminsScreen extends ConsumerStatefulWidget {
  final Tournament tournament;

  const ManageAdminsScreen({super.key, required this.tournament});

  @override
  ConsumerState<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends ConsumerState<ManageAdminsScreen> {
  final _searchController = TextEditingController();
  List<Player> _searchResults = [];
  bool _isSearching = false;
  late List<String> _currentAdminIds;

  @override
  void initState() {
    super.initState();
    _currentAdminIds = List.from(widget.tournament.adminIds);
  }

  Future<void> _searchPlayers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    
    // In a real app we would have a search endpoint. 
    // For now we get all and filter (inefficient but works for MVP/Sim)
    // Or assume we have a search method.
    // Let's use getAllPlayers and filter locally for this MVP.
    try {
      final allPlayers = await ref.read(playerRepositoryProvider).getAllPlayers();
      setState(() {
        _searchResults = allPlayers.where((p) => 
          p.name.toLowerCase().contains(query.toLowerCase()) &&
          !_currentAdminIds.contains(p.id)
        ).take(5).toList();
      });
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _addAdmin(Player player) async {
    setState(() {
      _currentAdminIds.add(player.id);
      _searchController.clear();
      _searchResults = [];
    });

    await _updateTournament();
    
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.adminAdded)),
       );
    }
  }

  Future<void> _removeAdmin(String adminId) async {
    if (adminId == widget.tournament.ownerId) return; // Cannot remove owner

    setState(() {
      _currentAdminIds.remove(adminId);
    });

    await _updateTournament();

     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(AppLocalizations.of(context)!.adminRemoved)),
       );
    }
  }

  Future<void> _updateTournament() async {
    final updatedTournament = widget.tournament.copyWith(
      adminIds: _currentAdminIds,
    );
    await ref.read(tournamentRepositoryProvider).updateTournament(updatedTournament);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ownerId = widget.tournament.ownerId;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageAdmins),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchByName,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching 
                  ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) {
                // Debounce could be here
                if (val.length > 2) _searchPlayers(val);
                else setState(() => _searchResults = []);
              },
            ),
          ),
          
          if (_searchResults.isNotEmpty) ...[
             const Divider(),
             ListView.builder(
               shrinkWrap: true,
               itemCount: _searchResults.length,
               itemBuilder: (context, index) {
                 final player = _searchResults[index];
                 return ListTile(
                   leading: CircleAvatar(backgroundImage: NetworkImage(player.avatarUrl)),
                   title: Text(player.name),
                   trailing: IconButton(
                     icon: const Icon(Icons.add_circle, color: Colors.green),
                     onPressed: () => _addAdmin(player),
                   ),
                 );
               },
             ),
             const Divider(thickness: 4),
          ],

          Expanded(
            child: FutureBuilder<List<Player>>(
              future: ref.read(playerRepositoryProvider).getAllPlayers(), // We need names for IDs
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final allPlayers = snapshot.data!;
                final adminPlayers = allPlayers.where((p) => _currentAdminIds.contains(p.id)).toList();

                return ListView.builder(
                  itemCount: adminPlayers.length,
                  itemBuilder: (context, index) {
                    final admin = adminPlayers[index];
                    final isOwner = admin.id == ownerId;

                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(admin.avatarUrl)),
                      title: Text(admin.name),
                      subtitle: isOwner ? Text(l10n.owner, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)) : Text(l10n.admins),
                      trailing: isOwner 
                          ? null 
                          : IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeAdmin(admin.id),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
