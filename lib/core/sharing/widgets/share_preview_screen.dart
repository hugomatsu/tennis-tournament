import 'package:flutter/material.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/core/sharing/sharing_service.dart';

/// A full-screen preview modal for sharing content.
/// Shows a live preview with background color options, copy, and share buttons.
class SharePreviewScreen extends ConsumerStatefulWidget {
  final Widget shareWidget;
  final String shareSubject;

  const SharePreviewScreen({
    super.key,
    required this.shareWidget,
    required this.shareSubject,
  });

  /// Show the share preview screen as a modal
  static Future<void> show({
    required BuildContext context,
    required Widget shareWidget,
    required String shareSubject,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SharePreviewScreen(
        shareWidget: shareWidget,
        shareSubject: shareSubject,
      ),
    );
  }

  @override
  ConsumerState<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends ConsumerState<SharePreviewScreen> {
  ShareBackgroundColor _selectedColor = ShareBackgroundColor.blue;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(sharingServiceProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.sharePreview,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Preview area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildPreview(service),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Background color options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorChip(
                  color: const Color(0xFF1E88E5),
                  label: l10n.backgroundBlue,
                  value: ShareBackgroundColor.blue,
                ),
                const SizedBox(width: 8),
                _buildColorChip(
                  color: const Color(0xFFE53935),
                  label: l10n.backgroundRed,
                  value: ShareBackgroundColor.red,
                ),
                const SizedBox(width: 8),
                _buildColorChip(
                  color: const Color(0xFFFDD835),
                  label: l10n.backgroundYellow,
                  value: ShareBackgroundColor.yellow,
                ),
                const SizedBox(width: 8),
                _buildColorChip(
                  color: null, // Transparent
                  label: l10n.backgroundNone,
                  value: ShareBackgroundColor.none,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Copy button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleCopy,
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.copy),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Share button
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _handleShare,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share),
                    label: Text(l10n.share),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildPreview(SharingService service) {
    final gradientColors = service.getGradientColors(_selectedColor);
    final hasBackground = gradientColors.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: hasBackground
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            )
          : BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: widget.shareWidget,
        ),
      ),
    );
  }

  Widget _buildColorChip({
    required Color? color,
    required String label,
    required ShareBackgroundColor value,
  }) {
    final isSelected = _selectedColor == value;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedColor = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? theme.colorScheme.surfaceContainerHighest)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? theme.colorScheme.outline)
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null)
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            if (color == null)
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.block,
                  size: 12,
                  color: theme.colorScheme.outline,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected && color != null
                    ? Colors.white
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCopy() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(sharingServiceProvider);
      await service.copyWidgetToClipboard(
        widget: widget.shareWidget,
        backgroundColor: _selectedColor,
        context: context,
      );
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.copiedToClipboard)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(sharingServiceProvider);
      await service.shareWidgetWithColor(
        widget: widget.shareWidget,
        subject: widget.shareSubject,
        backgroundColor: _selectedColor,
        context: context,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
