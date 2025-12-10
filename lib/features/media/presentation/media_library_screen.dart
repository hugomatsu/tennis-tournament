import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tennis_tournament/features/media/domain/media_asset.dart';
import 'package:tennis_tournament/features/media/presentation/media_library_picker.dart';

class MediaLibraryScreen extends ConsumerStatefulWidget {
  const MediaLibraryScreen({super.key});

  @override
  ConsumerState<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends ConsumerState<MediaLibraryScreen> {
  // We can reuse MediaLibraryPicker, but we need to intercept the tap.
  // Actually, MediaLibraryPicker is designed to PICK. 
  // If we want to View/Manage, we might want to show details on tap.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Media Library'),
      ),
      body: MediaLibraryPicker(
        onImageSelected: (asset) {
          // Instead of returning, show details
          _showImageDetails(context, asset);
        },
      ),
    );
  }

  void _showImageDetails(BuildContext context, MediaAsset asset) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(asset.url, fit: BoxFit.contain),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('File Name:', style: Theme.of(context).textTheme.titleSmall),
                    Text(asset.fileName ?? 'Unknown'),
                    const SizedBox(height: 12),
                    Text('Uploaded At:', style: Theme.of(context).textTheme.titleSmall),
                    Text(asset.uploadedAt.toLocal().toString().split('.')[0]),
                    const SizedBox(height: 12),
                    Text('Size:', style: Theme.of(context).textTheme.titleSmall),
                    Text(_formatBytes(asset.size)),
                    const SizedBox(height: 12),
                    Text('Metadata (JSON):', style: Theme.of(context).textTheme.titleSmall),
                    SelectableText(asset.toJson().toString()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
