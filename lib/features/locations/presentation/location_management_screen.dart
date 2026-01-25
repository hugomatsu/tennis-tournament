import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/locations/application/location_providers.dart';
import 'package:tennis_tournament/features/locations/data/location_repository.dart';
import 'package:tennis_tournament/features/locations/domain/location.dart';
import 'package:tennis_tournament/features/media/presentation/media_library_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class LocationManagementScreen extends ConsumerWidget {
  const LocationManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(locationsProvider);

    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.manageLocations),
      ),
      body: locationsAsync.when(
        data: (locations) {
          if (locations.isEmpty) {
            return Center(child: Text(loc.noLocationsAddedYet));
          }
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return ListTile(
                leading: location.imageUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(location.imageUrl!))
                    : const CircleAvatar(child: Icon(Icons.stadium)),
                title: Text(location.name),
                subtitle: Text('${location.numberOfCourts} Courts - ${location.description}', maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddEditDialog(context, ref, location: location),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteLocation(context, ref, location),
                    ),
                  ],
                ),
                onTap: () => _showAddEditDialog(context, ref, location: location),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(loc.errorOccurred(e.toString()))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, WidgetRef ref, {TournamentLocation? location}) {
    showDialog(
      context: context,
      builder: (context) => _AddEditLocationDialog(location: location),
    );
  }

  Future<void> _deleteLocation(BuildContext context, WidgetRef ref, TournamentLocation location) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(loc.deleteLocationTitle),
          content: Text(loc.deleteLocationConfirm(location.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(loc.delete),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(locationRepositoryProvider).deleteLocation(location.id);
    }
  }
}

class _AddEditLocationDialog extends ConsumerStatefulWidget {
  final TournamentLocation? location;

  const _AddEditLocationDialog({this.location});

  @override
  ConsumerState<_AddEditLocationDialog> createState() => _AddEditLocationDialogState();
}

class _AddEditLocationDialogState extends ConsumerState<_AddEditLocationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mapsUrlController = TextEditingController();
  final _descController = TextEditingController();
  final _courtsController = TextEditingController(text: '1');
  final _imageUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.location != null) {
      _nameController.text = widget.location!.name;
      _mapsUrlController.text = widget.location!.googleMapsUrl;
      _descController.text = widget.location!.description;
      _courtsController.text = widget.location!.numberOfCourts.toString();
      _imageUrlController.text = widget.location!.imageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mapsUrlController.dispose();
    _descController.dispose();
    _courtsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _showMediaLibrary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            AppBar(
              title: Text(AppLocalizations.of(context)!.selectImage),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: MediaLibraryPicker(
                onImageSelected: (asset) {
                  setState(() {
                    _imageUrlController.text = asset.url;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final location = TournamentLocation(
        id: widget.location?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        googleMapsUrl: _mapsUrlController.text.trim(),
        description: _descController.text.trim(),
        numberOfCourts: int.parse(_courtsController.text.trim()),
        imageUrl: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
      );

      if (widget.location != null) {
        await ref.read(locationRepositoryProvider).updateLocation(location);
      } else {
        await ref.read(locationRepositoryProvider).addLocation(location);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.location != null ? AppLocalizations.of(context)!.editLocation : AppLocalizations.of(context)!.addLocation),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mapsUrlController,
                decoration: const InputDecoration(labelText: 'Google Maps Link'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courtsController,
                decoration: const InputDecoration(labelText: 'Number of Courts'),
                keyboardType: TextInputType.number,
                 validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid number' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                      readOnly: true,
                      onTap: _showMediaLibrary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: _showMediaLibrary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
