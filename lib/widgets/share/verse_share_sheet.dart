import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/verse_image_service.dart';
import '../../theme/bible_theme.dart';
import 'editorial_verse_card_canvas.dart';

/// Modal bottom sheet allowing the user to customize an editorial card
/// and share it as a high-resolution PNG image or formatted text.
class VerseShareSheet extends StatefulWidget {
  const VerseShareSheet({
    super.key,
    required this.reference,
    required this.verseText,
    this.translationLabel,
  });

  final String reference;
  final String verseText;
  final String? translationLabel;

  static Future<void> show({
    required BuildContext context,
    required String reference,
    required String verseText,
    String? translationLabel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VerseShareSheet(
        reference: reference,
        verseText: verseText,
        translationLabel: translationLabel,
      ),
    );
  }

  @override
  State<VerseShareSheet> createState() => _VerseShareSheetState();
}

class _VerseShareSheetState extends State<VerseShareSheet> {
  final GlobalKey _repaintKey = GlobalKey();
  EditorialCardStyle _selectedStyle = EditorialCardStyle.ivory;
  bool _showWatermark = true;
  bool _isExporting = false;

  Future<void> _shareAsImage() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      await VerseImageService.shareVerseCard(
        repaintKey: _repaintKey,
        reference: widget.reference,
        verseText: widget.verseText,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo generar la imagen: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _shareAsText() {
    final text = '«${widget.verseText}»\n— ${widget.reference}'
        '${widget.translationLabel != null ? ' (${widget.translationLabel})' : ''}';
    SharePlus.instance.share(
      ShareParams(
        text: text,
        title: widget.reference,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    return Container(
      decoration: BoxDecoration(
        color: readingStyle.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Text(
                  'Compartir Versículo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.bold,
                    color: readingStyle.textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Live Preview of the Editorial Canvas (RepaintBoundary)
            Center(
              child: RepaintBoundary(
                key: _repaintKey,
                child: EditorialVerseCardCanvas(
                  verseText: widget.verseText,
                  reference: widget.reference,
                  translationLabel: widget.translationLabel,
                  style: _selectedStyle,
                  showWatermark: _showWatermark,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Style Selector Chips
            Text(
              'Estilo visual:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: readingStyle.metaColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: EditorialCardStyle.values.map((style) {
                final isSelected = style == _selectedStyle;
                Color swatch;
                if (style == EditorialCardStyle.ivory) {
                  swatch = ReadingPalette.cream;
                } else if (style == EditorialCardStyle.sepia) {
                  swatch = ReadingPalette.sepiaSurface;
                } else {
                  swatch = ReadingPalette.charcoalSurface;
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: isSelected
                            ? theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.35)
                            : Colors.transparent,
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                          width: isSelected ? 2 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => setState(() => _selectedStyle = style),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: swatch,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              style.label.split(' ')[0], // 'Marfil', 'Pergamino', 'Vigilia'
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : readingStyle.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Watermark switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Incluir marca discreta (bible_app)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: readingStyle.textColor,
                  ),
                ),
                Switch.adaptive(
                  value: _showWatermark,
                  onChanged: (val) => setState(() => _showWatermark = val),
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            FilledButton.icon(
              onPressed: _isExporting ? null : _shareAsImage,
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.image_outlined, size: 20),
              label: Text(
                _isExporting ? 'Generando imagen...' : 'Compartir como imagen',
                style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),

            TextButton.icon(
              onPressed: _isExporting ? null : _shareAsText,
              icon: const Icon(Icons.text_fields_rounded, size: 18),
              label: const Text(
                'Compartir solo texto',
                style: TextStyle(fontFamily: 'Inter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
