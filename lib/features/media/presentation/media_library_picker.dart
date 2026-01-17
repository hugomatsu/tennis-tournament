import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tennis_tournament/features/media/data/media_repository.dart';
import 'package:tennis_tournament/features/media/domain/media_asset.dart';
import 'package:tennis_tournament/features/players/application/player_providers.dart'; // For currentUserProvider
import 'package:tennis_tournament/l10n/app_localizations.dart';

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
  
  static const int maxStorageBytes = 15 * 1024 * 1024; // 15 MB

  Future<void> _uploadImage() async {
    final userAsync = ref.read(currentUserProvider);
    final userId = userAsync.value?.id;
    final loc = AppLocalizations.of(context)!;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.pleaseLogIn)),
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
        final bytes = await image.readAsBytes();
        
        // Check storage limit
        final currentUsage = await ref.read(mediaRepositoryProvider).getUserStorageUsage(userId);
        if (currentUsage + bytes.length > maxStorageBytes) {
          if (mounted) {
            _showStorageLimitDialog(loc);
          }
          return;
        }
        
        setState(() => _isUploading = true);
        
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
  
  void _showStorageLimitDialog(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.storage, size: 48, color: Colors.orange),
        title: Text(loc.storageLimitReached),
        content: Text(loc.storageLimitMessage),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
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
    final loc = AppLocalizations.of(context)!;

    if (userId == null) {
      return Center(child: Text(loc.pleaseLogIn));
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
                  Text(loc.myLibrary, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  usageFuture.when(
                    data: (usage) {
                      final usedStr = _formatBytes(usage);
                      final limitStr = _formatBytes(maxStorageBytes);
                      final percent = (usage / maxStorageBytes * 100).clamp(0, 100).toInt();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.storageUsedOfLimit(usedStr, limitStr),
                            style: TextStyle(
                              fontSize: 12, 
                              color: percent >= 90 ? Colors.red : Colors.grey,
                              fontWeight: percent >= 90 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 120,
                            child: LinearProgressIndicator(
                              value: usage / maxStorageBytes,
                              backgroundColor: Colors.grey[300],
                              color: percent >= 90 ? Colors.red : (percent >= 70 ? Colors.orange : null),
                            ),
                          ),
                        ],
                      );
                    },
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
                label: Text(loc.upload),
              ),
            ],
          ),
        ),
        Expanded(
          child: mediaFuture.when(
            data: (assets) {
              if (assets.isEmpty) {
                return Center(child: Text(loc.noImages));
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
