import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/debug/application/simulation_service.dart';

class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  bool _isLoading = false;

  Future<void> _runSimulation(String name, int players, int categories) async {
    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(simulationServiceProvider).seedTournament(
            name: name,
            playerCount: players,
            categoryCount: categories,
          );
      
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Simulation "$name" created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation & Debug'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tournament Scenarios',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create tournaments with pre-filled data to test bracket generation and user flows.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _SimulationCard(
            title: 'Small Tournament',
            description: '4 Players, 1 Category. Simple bracket.',
            icon: Icons.person_outline,
            isLoading: _isLoading,
            onTap: () => _runSimulation('Sim: Small (4P)', 4, 1),
          ),
          _SimulationCard(
            title: 'Standard Tournament',
            description: '8 Players, 1 Category. Quarter-finals start.',
            icon: Icons.people_outline,
            isLoading: _isLoading,
            onTap: () => _runSimulation('Sim: Standard (8P)', 8, 1),
          ),
          _SimulationCard(
            title: 'Large Tournament',
            description: '16 Players, 1 Category. Round of 16.',
            icon: Icons.groups_outlined,
            isLoading: _isLoading,
            onTap: () => _runSimulation('Sim: Large (16P)', 16, 1),
          ),
          _SimulationCard(
            title: 'Odd Players (Byes)',
            description: '5 Players. Tests bye generation logic.',
            icon: Icons.filter_5,
            isLoading: _isLoading,
            onTap: () => _runSimulation('Sim: Odd (5P)', 5, 1),
          ),
          _SimulationCard(
            title: 'Multi-Category',
            description: '2 Categories, 4 Players each (Total 8).',
            icon: Icons.category_outlined,
            isLoading: _isLoading,
            onTap: () => _runSimulation('Sim: Multi (2x4P)', 4, 2),
          ),
          const Divider(height: 48),
          FilledButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            label: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }
}

class _SimulationCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _SimulationCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isLoading ? null : onTap,
      ),
    );
  }
}
