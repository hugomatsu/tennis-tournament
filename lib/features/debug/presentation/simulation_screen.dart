import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/debug/application/simulation_service.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

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
        final loc = AppLocalizations.of(context)!;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(loc.simulationCreated(name))),
        );
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(loc.errorGeneric(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _runAmericanoSimulation(String name, int players, int playersPerGroup, int guaranteedMatches) async {
    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(simulationServiceProvider).seedAmericanoTournament(
            name: name,
            playerCount: players,
            playersPerGroup: playersPerGroup,
            guaranteedMatches: guaranteedMatches,
          );
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(loc.americanoCreated(name))),
        );
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(loc.errorGeneric(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _runOpenTennisSimulation(String name, int players, int groups, int points) async {
    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(simulationServiceProvider).seedOpenTennisTournament(
            name: name,
            playerCount: players,
            groupCount: groups,
            pointsPerWin: points,
          );

      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(loc.openTennisCreated(name))),
        );
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(loc.errorGeneric(e.toString()))),
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.simulationDebug),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            loc.tournamentScenarios,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            loc.tournamentScenariosDesc,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _SimulationCard(
            title: loc.simSmallTitle,
            description: loc.simSmallDesc,
            icon: Icons.person_outline,
            isLoading: _isLoading,
            onTap: () => _runSimulation('Sim: Small (4P)', 4, 1),
          ),
          _SimulationCard(
            title: loc.simStandardTitle,
            description: loc.simStandardDesc,
            icon: Icons.people_outline,
            isLoading: _isLoading,
            onTap: () => _runSimulation('Sim: Standard (8P)', 8, 1),
          ),
          _SimulationCard(
            title: loc.simLargeTitle,
            description: loc.simLargeDesc,
            icon: Icons.groups_outlined,
            isLoading: _isLoading,
            onTap: () => _runSimulation('Sim: Large (16P)', 16, 1),
          ),
          _SimulationCard(
            title: loc.simOddTitle,
            description: loc.simOddDesc,
            icon: Icons.filter_5,
            isLoading: _isLoading,
            onTap: () => _runSimulation('Sim: Odd (5P)', 5, 1),
          ),
          _SimulationCard(
            title: loc.simMultiTitle,
            description: loc.simMultiDesc,
            icon: Icons.category_outlined,
            isLoading: _isLoading,
            onTap: () => _runSimulation('Sim: Multi (2x4P)', 4, 2),
          ),
          const Divider(height: 32),
          Text(
            loc.openTennisMode,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            loc.openTennisRoundRobinDesc,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _SimulationCard(
            title: loc.simOT4Title,
            description: loc.simOT4Desc,
            icon: Icons.group,
            isLoading: _isLoading,
            onTap: () => _runOpenTennisSimulation('Sim: OpenTennis (4P)', 4, 2, 3),
          ),
          _SimulationCard(
            title: loc.simOT6Title,
            description: loc.simOT6Desc,
            icon: Icons.group,
            isLoading: _isLoading,
            onTap: () => _runOpenTennisSimulation('Sim: OpenTennis (6P)', 6, 2, 3),
          ),
          _SimulationCard(
            title: loc.simOT8_2gTitle,
            description: loc.simOT8_2gDesc,
            icon: Icons.group,
            isLoading: _isLoading,
            onTap: () => _runOpenTennisSimulation('Sim: OpenTennis (8P 2G)', 8, 2, 3),
          ),
          _SimulationCard(
            title: loc.simOT8_4gTitle,
            description: loc.simOT8_4gDesc,
            icon: Icons.group,
            isLoading: _isLoading,
            onTap: () => _runOpenTennisSimulation('Sim: OpenTennis (8P 4G)', 8, 4, 3),
          ),
          const Divider(height: 32),
          Text(
            loc.americanoMode,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            loc.americanoRoundRobinDesc,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _SimulationCard(
            title: loc.simAm8Title,
            description: loc.simAm8Desc,
            icon: Icons.swap_horiz,
            isLoading: _isLoading,
            onTap: () => _runAmericanoSimulation('Sim: Americano (8P)', 8, 4, 5),
          ),
          _SimulationCard(
            title: loc.simAm12Title,
            description: loc.simAm12Desc,
            icon: Icons.swap_horiz,
            isLoading: _isLoading,
            onTap: () => _runAmericanoSimulation('Sim: Americano (12P)', 12, 4, 5),
          ),
          _SimulationCard(
            title: loc.simAm16Title,
            description: loc.simAm16Desc,
            icon: Icons.swap_horiz,
            isLoading: _isLoading,
            onTap: () => _runAmericanoSimulation('Sim: Americano (16P)', 16, 4, 5),
          ),
          const Divider(height: 48),
          FilledButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            label: Text(loc.goToHome),
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
