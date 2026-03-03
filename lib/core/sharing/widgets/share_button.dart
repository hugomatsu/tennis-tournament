import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/core/sharing/widgets/share_preview_screen.dart';

class ShareButton extends ConsumerWidget {
  final String shareSubject;
  final String shareUrl;
  final Widget shareWidget;
  final String label;
  final VoidCallback? onShare;

  const ShareButton({
    super.key,
    required this.shareSubject,
    required this.shareUrl,
    required this.shareWidget,
    this.label = 'Share',
    this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.share),
      tooltip: label,
      onPressed: () => _showSharePreview(context),
    );
  }

  void _showSharePreview(BuildContext context) {
    SharePreviewScreen.show(
      context: context,
      shareWidget: shareWidget,
      shareSubject: shareSubject,
      onShare: onShare,
    );
  }
}
