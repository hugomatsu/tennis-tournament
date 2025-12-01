import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:uuid/uuid.dart';

import 'package:tennis_tournament/features/tournaments/application/tournament_providers.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/domain/participant.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament_category.dart';
import 'package:uuid/uuid.dart';

class ParticipantManagementScreen extends ConsumerWidget {
  final String tournamentId;

  const ParticipantManagementScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantsProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Players'),
      ),
      body: participantsAsync.when(
        data: (participants) {
          final pending = participants.where((p) => p.status == 'pending').toList();
          final approved = participants.where((p) => p.status == 'approved').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                Text(
                  'Pending Requests (${pending.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                ),
                const SizedBox(height: 8),
                ...pending.map((p) => _ParticipantTile(
                      participant: p,
                      tournamentId: tournamentId,
                      isPending: true,
                    )),
                const SizedBox(height: 24),
              ],
              Text(
                'Approved Players (${approved.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
              ),
              const SizedBox(height: 8),
              if (approved.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No approved players yet.'),
                ),
              ...approved.map((p) => _ParticipantTile(
                    participant: p,
                    tournamentId: tournamentId,
                    isPending: false,
                  )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddParticipantDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddParticipantDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddParticipantDialog(tournamentId: tournamentId),
    );
  }
}

class _ParticipantTile extends ConsumerWidget {
  final Participant participant;
  final String tournamentId;
  final bool isPending;

  const _ParticipantTile({
    required this.participant,
    required this.tournamentId,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(tournamentRepositoryProvider).getCategories(tournamentId);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: participant.avatarUrl != null
              ? NetworkImage(participant.avatarUrl!)
              : null,
          child: participant.avatarUrl == null
              ? Text(participant.name[0].toUpperCase())
              : null,
        ),
        title: Text(participant.name),
        subtitle: FutureBuilder(
          future: categoriesAsync,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('Joined: ${_formatDate(participant.joinedAt)}');
            final category = snapshot.data!.firstWhere(
              (c) => c.id == participant.categoryId,
              orElse: () => TournamentCategory(id: '', tournamentId: '', name: 'Unknown', type: ''),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${category.name}'),
                Text('Joined: ${_formatDate(participant.joinedAt)}'),
              ],
            );
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPending) ...[
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _updateStatus(ref, 'approved'),
                tooltip: 'Accept',
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _updateStatus(ref, 'rejected'),
                tooltip: 'Deny',
              ),
            ] else
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () => _updateStatus(ref, 'rejected'), // Or delete
                tooltip: 'Remove',
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(WidgetRef ref, String status) async {
    await ref.read(tournamentRepositoryProvider).updateParticipantStatus(
          tournamentId,
          participant.id,
          status,
        );
    ref.invalidate(participantsProvider(tournamentId));
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _AddParticipantDialog extends ConsumerStatefulWidget {
  final String tournamentId;

  const _AddParticipantDialog({required this.tournamentId});

  @override
  ConsumerState<_AddParticipantDialog> createState() => _AddParticipantDialogState();
}

class _AddParticipantDialogState extends ConsumerState<_AddParticipantDialog> {
  final _nameController = TextEditingController();
  final _uuid = const Uuid();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(tournamentRepositoryProvider).getCategories(widget.tournamentId);

    return AlertDialog(
      title: const Text('Add Participant'),
      content: FutureBuilder(
        future: categoriesAsync,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final categories = snapshot.data!;
          if (categories.isEmpty) return const Text('No categories found.');
          
          if (_selectedCategoryId == null && categories.isNotEmpty) {
            _selectedCategoryId = categories.first.id;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g. Hugo or Hugo & Arthur)',
                  hintText: 'Enter participant name',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedCategoryId == null) return;

    final participant = Participant(
      id: _uuid.v4(),
      name: name,
      userId: null, // Manual entry
      categoryId: _selectedCategoryId!,
      status: 'approved', // Auto-approve manual entries
      joinedAt: DateTime.now(),
    );

    await ref.read(tournamentRepositoryProvider).addParticipant(
          widget.tournamentId,
          participant,
        );
    
    ref.invalidate(participantsProvider(widget.tournamentId));
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
