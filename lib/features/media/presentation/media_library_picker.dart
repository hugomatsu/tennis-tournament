import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tennis_tournament/features/media/data/media_repository.dart';
import 'package:tennis_tournament/features/media/domain/media_asset.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart'; // For currentUserProvider

final userMediaProvider = FutureProvider.family<List<MediaAsset>, String>((ref, userId) {
  return ref.watch(mediaRepositoryProvider).getUserMedia(userId);
});

final userStorageUsageProvider = FutureProvider.family<int, String>((ref, userId) {
  return ref.watch(mediaRepositoryProvider).getUserStorageUsage(userId);
});

class MediaLibraryPicker extends ConsumerStatefulWidget {
  final Function(MediaAsset asset) onImageSelected;

  const MediaLibraryPicker({super.key, required this.onImageSelected});

  @override
  ConsumerState<MediaLibraryPicker> createState() => _MediaLibraryPickerState();
}

class _MediaLibraryPickerState extends ConsumerState<MediaLibraryPicker> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _uploadImage() async {
    final userAsync = ref.read(currentUserProvider);
    final userId = userAsync.value?.id;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isUploading = true);
        
        final bytes = await image.readAsBytes();
        await ref.read(mediaRepositoryProvider).uploadImageBytes(
          bytes, 
          image.name, 
          userId,
        );
        
        // Invalidate providers to refresh list and usage
        ref.invalidate(userMediaProvider(userId));
        ref.invalidate(userStorageUsageProvider(userId));
        
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
      print('Error uploading image: $e');
    }
  }

  Future<void> _deleteImage(MediaAsset asset) async {
    final userAsync = ref.read(currentUserProvider);
    final userId = userAsync.value?.id;
    if (userId == null) return;

    try {
      await ref.read(mediaRepositoryProvider).deleteMedia(asset.id);
      ref.invalidate(userMediaProvider(userId));
      ref.invalidate(userStorageUsageProvider(userId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting image: $e')),
        );
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final userId = userAsync.value?.id;

    if (userId == null) {
      return const Center(child: Text('Please log in to access library'));
    }

    final mediaFuture = ref.watch(userMediaProvider(userId));
    final usageFuture = ref.watch(userStorageUsageProvider(userId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Library', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  usageFuture.when(
                    data: (usage) => Text('Storage used: ${_formatBytes(usage)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    loading: () => const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const Text('Error loading usage'),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: _isUploading ? null : _uploadImage,
                icon: _isUploading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.upload),
                label: const Text('Upload'),
              ),
            ],
          ),
        ),
        Expanded(
          child: mediaFuture.when(
            data: (assets) {
              if (assets.isEmpty) {
                return const Center(child: Text('No images in library'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => widget.onImageSelected(asset),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            asset.url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deleteImage(asset),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
