import 'package:flutter/material.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/core/sharing/sharing_service.dart';

/// A full-screen preview modal for sharing content.
/// Shows a live preview with background color options, copy, and share buttons.
class SharePreviewScreen extends ConsumerStatefulWidget {
  final Widget shareWidget;
  final String shareSubject;
  final VoidCallback? onShare;

  const SharePreviewScreen({
    super.key,
    required this.shareWidget,
    required this.shareSubject,
    this.onShare,
  });

  /// Show the share preview screen as a modal
  static Future<void> show({
    required BuildContext context,
    required Widget shareWidget,
    required String shareSubject,
    VoidCallback? onShare,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SharePreviewScreen(
        shareWidget: shareWidget,
        shareSubject: shareSubject,
        onShare: onShare,
      ),
    );
  }

  @override
  ConsumerState<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends ConsumerState<SharePreviewScreen> {
  ShareBackgroundColor _selectedColor = ShareBackgroundColor.blue;
  Color? _customColor;
  bool _isLoading = false;
  final _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() => _transformController.value = Matrix4.identity();

  void _adjustZoom(double factor) {
    final m = _transformController.value;
    final currentScale = m.entry(0, 0);
    final newScale = (currentScale * factor).clamp(0.1, 5.0);
    final sf = newScale / currentScale;
    _transformController.value = Matrix4.identity()
      ..setEntry(0, 0, newScale)
      ..setEntry(1, 1, newScale)
      ..setEntry(0, 3, m.entry(0, 3) * sf)
      ..setEntry(1, 3, m.entry(1, 3) * sf);
  }

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

          // Background color options - scrollable
          SizedBox(
            height: 44,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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
                  const SizedBox(width: 8),
                  // Custom color picker
                  _buildCustomColorChip(theme),
                ],
              ),
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
    final gradientColors = service.getGradientColors(_selectedColor, _customColor);
    final hasBackground = gradientColors.isNotEmpty;
    final theme = Theme.of(context);

    final content = Container(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width - 32,
        minHeight: 200,
      ),
      decoration: hasBackground
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            )
          : BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: widget.shareWidget,
      ),
    );

    return Stack(
      children: [
        // Zoomable / pannable preview
        InteractiveViewer(
          transformationController: _transformController,
          constrained: false,
          minScale: 0.1,
          maxScale: 5.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: content,
        ),

        // Zoom controls — top-right corner of the preview box
        Positioned(
          top: 8,
          right: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PreviewZoomButton(
                icon: Icons.add,
                tooltip: 'Zoom in',
                onTap: () => _adjustZoom(1.3),
              ),
              const SizedBox(height: 4),
              _PreviewZoomButton(
                icon: Icons.remove,
                tooltip: 'Zoom out',
                onTap: () => _adjustZoom(1 / 1.3),
              ),
              const SizedBox(height: 4),
              _PreviewZoomButton(
                icon: Icons.fit_screen,
                tooltip: 'Reset zoom',
                onTap: _resetZoom,
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildCustomColorChip(ThemeData theme) {
    final isSelected = _selectedColor == ShareBackgroundColor.custom;
    
    return GestureDetector(
      onTap: () => _showColorPicker(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected && _customColor != null
              ? _customColor
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (_customColor ?? theme.colorScheme.primary)
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
            Icon(
              Icons.colorize,
              size: 14,
              color: isSelected && _customColor != null
                  ? Colors.white
                  : theme.colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(ThemeData theme) {
    // Predefined color options for quick selection
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectCustomColor),
        content: SizedBox(
          width: 280,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _customColor = color;
                    _selectedColor = ShareBackgroundColor.custom;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
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
        customColor: _customColor,
        context: context,
      );
      // Note: Snackbar is shown in the service for mobile, not here
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
        customColor: _customColor,
        context: context,
      );
      widget.onShare?.call();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _PreviewZoomButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _PreviewZoomButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
