import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

final sharingServiceProvider = Provider((ref) => SharingService());

class SharingService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> shareUrl(String url) async {
    await Share.share(url);
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
      // 1. Wrap widget in a capture container with optional background
      final captureWidget = Container(
        color: withBackground ? Colors.white : null,
        child: withBackground 
            ? Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                        ),
                      ),
                    ),
                  ),
                  Center(child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: widget,
                  )),
                ],
              )
            : Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget,
            ),
      );

      // 2. Capture image
      return await _screenshotController.captureFromWidget(
        captureWidget,
        delay: const Duration(milliseconds: 100),
        pixelRatio: 2.0,
        context: context, 
      );
  }

  Future<void> shareWidget({
    required Widget widget,
    required String subject,
    required bool withBackground,
    BuildContext? context,
  }) async {
    try {
      final image = await _captureWidget(widget, withBackground, context);

      final fileName = 'share_${DateTime.now().millisecondsSinceEpoch}.png';
      
      await Share.shareXFiles(
        [
          XFile.fromData(
            image,
            name: fileName,
            mimeType: 'image/png',
          ),
        ],
        subject: subject,
      );
      
    } catch (e) {
      debugPrint('Error sharing widget: $e');
      rethrow;
    }
  }
}
