import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/locations/application/location_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/locations/domain/location.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

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
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchLocations,
              prefixIcon: const Icon(Icons.search),
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
                return Center(child: Text(AppLocalizations.of(context)!.noLocationsFound));
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
                    subtitle: Text('${location.numberOfCourts} ${AppLocalizations.of(context)!.courtsAvailable}'),
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
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.add_location_alt, color: Colors.blue),
          title: Text(AppLocalizations.of(context)!.addNewLocation),
          onTap: () {
             // Navigate to location management/creation
             // Since we are likely in a modal, we might need to route to a creation screen
             // For now, let's assume we can push the location management screen
             context.push('/admin/locations');
          },
        ),
      ],
    );
  }
}
