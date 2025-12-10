import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/locations/application/location_providers.dart';
import 'package:tennis_tournament/features/locations/domain/location.dart';

class LocationPicker extends ConsumerStatefulWidget {
  final Function(TournamentLocation location) onLocationSelected;

  const LocationPicker({super.key, required this.onLocationSelected});

  @override
  ConsumerState<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends ConsumerState<LocationPicker> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search locations...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
          ),
        ),
        Expanded(
          child: locationsAsync.when(
            data: (locations) {
              final filtered = locations.where((l) {
                return l.name.toLowerCase().contains(_searchQuery) ||
                       l.description.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('No locations found'));
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final location = filtered[index];
                  return ListTile(
                    leading: location.imageUrl != null
                        ? CircleAvatar(backgroundImage: NetworkImage(location.imageUrl!))
                        : const CircleAvatar(child: Icon(Icons.stadium)),
                    title: Text(location.name),
                    subtitle: Text('${location.numberOfCourts} Courts available'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => widget.onLocationSelected(location),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
