import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/core/sharing/sharing_service.dart';

class ShareButton extends ConsumerWidget {
  final String shareSubject;
  final String shareUrl;
  final Widget shareWidget;
  final String label;

  const ShareButton({
    super.key,
    required this.shareSubject,
    required this.shareUrl,
    required this.shareWidget,
    this.label = 'Share',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.share),
      tooltip: label,
      onPressed: () => _showShareOptions(context, ref),
    );
  }

  Future<void> _showShareOptions(BuildContext context, WidgetRef ref) async {
    final service = ref.read(sharingServiceProvider);
    
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Share Link'),
              onTap: () {
                Navigator.pop(context);
                service.shareUrl(shareUrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Share Image (With Background)'),
              onTap: () {
                Navigator.pop(context);
                service.shareWidget(
                  widget: shareWidget,
                  subject: shareSubject,
                  withBackground: true,
                  context: context,
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.crop_free),
              title: const Text('Share Image (Transparent/Simple)'),
              onTap: () {
                Navigator.pop(context);
                service.shareWidget(
                  widget: shareWidget,
                  subject: shareSubject,
                  withBackground: false,
                  context: context,
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Save Image (With Background)'),
              onTap: () {
                Navigator.pop(context);
                service.saveWidgetImage(
                  widget: shareWidget,
                  subject: shareSubject,
                  withBackground: true,
                  context: context,
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Save Image (Transparent)'),
              onTap: () {
                Navigator.pop(context);
                service.saveWidgetImage(
                  widget: shareWidget,
                  subject: shareSubject,
                  withBackground: false,
                  context: context,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
