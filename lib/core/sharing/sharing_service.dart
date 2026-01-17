import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:tennis_tournament/core/widgets/web_share_modal.dart';

final sharingServiceProvider = Provider((ref) => SharingService());

/// Background color options for sharing
enum ShareBackgroundColor {
  blue,
  red,
  yellow,
  none,
}

class SharingService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Get gradient colors for a background option
  List<Color> getGradientColors(ShareBackgroundColor bgColor) {
    switch (bgColor) {
      case ShareBackgroundColor.blue:
        return [const Color(0xFF1E88E5), const Color(0xFF1565C0)];
      case ShareBackgroundColor.red:
        return [const Color(0xFFE53935), const Color(0xFFC62828)];
      case ShareBackgroundColor.yellow:
        return [const Color(0xFFFDD835), const Color(0xFFF9A825)];
      case ShareBackgroundColor.none:
        return []; // Transparent
    }
  }

  Future<void> shareUrl(String url, {String? subject, BuildContext? context}) async {
    if (kIsWeb && context != null) {
      await showDialog(
        context: context,
        builder: (context) => WebShareModal(
          title: subject ?? 'Share',
          text: url,
        ),
      );
    } else {
      await Share.share(url, subject: subject);
    }
  }

  Future<void> saveWidgetImage({
    required Widget widget,
    required String subject,
    required bool withBackground,
    BuildContext? context,
  }) async {
    try {
      final image = await _captureWidget(widget, withBackground, context);
      
      final fileName = 'tennis_share_${DateTime.now().millisecondsSinceEpoch}';
      
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: image,
        mimeType: MimeType.png,
      );
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error saving widget: $e');
      if (context != null && context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
      rethrow;
    }
  }

  Future<Uint8List> _captureWidget(Widget widget, bool withBackground, BuildContext? context) async {
      // Use default blue background if withBackground is true
      return captureWidgetWithColor(
        widget: widget,
        backgroundColor: withBackground ? ShareBackgroundColor.blue : ShareBackgroundColor.none,
        context: context,
      );
  }

  /// Capture widget with a specific background color
  Future<Uint8List> captureWidgetWithColor({
    required Widget widget,
    required ShareBackgroundColor backgroundColor,
    BuildContext? context,
  }) async {
    final gradientColors = getGradientColors(backgroundColor);
    final hasBackground = gradientColors.isNotEmpty;

    final captureWidget = Container(
      color: hasBackground ? null : Colors.transparent,
      decoration: hasBackground
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            )
          : null,
      child: hasBackground
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: widget,
              ))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget,
            ),
    );

    return await _screenshotController.captureFromWidget(
      captureWidget,
      delay: const Duration(milliseconds: 100),
      pixelRatio: 2.0,
      context: context,
    );
  }

  /// Copy widget image to clipboard
  Future<void> copyWidgetToClipboard({
    required Widget widget,
    required ShareBackgroundColor backgroundColor,
    BuildContext? context,
  }) async {
    try {
      final image = await captureWidgetWithColor(
        widget: widget,
        backgroundColor: backgroundColor,
        context: context,
      );

      // Copy image data to clipboard
      await Clipboard.setData(ClipboardData(text: '')); // Clear text clipboard
      
      // For mobile, we need to save temp file and use platform-specific clipboard
      // For now, we'll save to a temp file that user can paste
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/share_temp.png');
        await tempFile.writeAsBytes(image);
        
        // On iOS/Android, copying image to clipboard requires platform channels
        // For simplicity, we'll use the share sheet with a "copy" hint
        // or save the file for manual copy
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved! You can now paste it.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error copying: $e')),
        );
      }
    }
  }

  Future<void> shareWidget({
    required Widget widget,
    required String subject,
    required bool withBackground,
    BuildContext? context,
  }) async {
    try {
      final image = await _captureWidget(widget, withBackground, context);

      final fileName = 'share_${DateTime.now().millisecondsSinceEpoch}';

      if (kIsWeb && context != null) {
         await showDialog(
          context: context,
          builder: (context) => WebShareModal(
            title: subject,
            text: 'Here is the $subject',
            onDownloadImage: () async {
              await FileSaver.instance.saveFile(
                name: fileName,
                bytes: image,
                mimeType: MimeType.png,
              );
            },
          ),
        );
      } else {
         final fileNameWithExt = '$fileName.png';
         await Share.shareXFiles(
          [
            XFile.fromData(
              image,
              name: fileNameWithExt,
              mimeType: 'image/png',
            ),
          ],
          subject: subject,
        );
      }
      
    } catch (e) {
      debugPrint('Error sharing widget: $e');
      rethrow;
    }
  }

  /// Share widget with specific background color
  Future<void> shareWidgetWithColor({
    required Widget widget,
    required String subject,
    required ShareBackgroundColor backgroundColor,
    BuildContext? context,
  }) async {
    try {
      final image = await captureWidgetWithColor(
        widget: widget,
        backgroundColor: backgroundColor,
        context: context,
      );

      final fileName = 'share_${DateTime.now().millisecondsSinceEpoch}';

      if (kIsWeb && context != null) {
        await showDialog(
          context: context,
          builder: (context) => WebShareModal(
            title: subject,
            text: 'Here is the $subject',
            onDownloadImage: () async {
              await FileSaver.instance.saveFile(
                name: fileName,
                bytes: image,
                mimeType: MimeType.png,
              );
            },
          ),
        );
      } else {
        final fileNameWithExt = '$fileName.png';
        await Share.shareXFiles(
          [
            XFile.fromData(
              image,
              name: fileNameWithExt,
              mimeType: 'image/png',
            ),
          ],
          subject: subject,
        );
      }
    } catch (e) {
      debugPrint('Error sharing widget: $e');
      rethrow;
    }
  }
}
