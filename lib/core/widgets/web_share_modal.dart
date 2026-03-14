import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class WebShareModal extends StatelessWidget {
  final String title;
  final String text;
  final String? url;
  final VoidCallback? onDownloadImage;

  const WebShareModal({
    super.key,
    required this.title,
    required this.text,
    this.url,
    this.onDownloadImage,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildOption(
                context,
                icon: Icons.copy,
                label: loc.copyLink,
                onTap: () async {
                  final dataToCopy = url ?? text;
                  await Clipboard.setData(ClipboardData(text: dataToCopy));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.copiedToClipboard)),
                    );
                  }
                },
              ),
              if (url != null) ...[
                const SizedBox(height: 12),
                _buildOption(
                  context,
                  icon: Icons.alternate_email,
                  label: loc.shareOnTwitter,
                  onTap: () {
                    _launchSocial(
                        'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}&url=${Uri.encodeComponent(url!)}');
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  context,
                  icon: Icons.message,
                  label: loc.shareOnWhatsApp,
                  onTap: () {
                    _launchSocial(
                        'https://wa.me/?text=${Uri.encodeComponent("$text $url")}');
                  },
                ),
              ],
              if (onDownloadImage != null) ...[
                const SizedBox(height: 12),
                _buildOption(
                  context,
                  icon: Icons.download,
                  label: loc.downloadImage,
                  onTap: () {
                    onDownloadImage!();
                    Navigator.of(context).pop();
                  },
                ),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchSocial(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
