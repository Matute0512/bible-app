import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';




import '../../models/bible_chapter.dart';

import '../../models/verse.dart';

import '../../models/verse_annotation.dart';

import '../../providers/app_providers.dart';

import '../../theme/bible_theme.dart';

import 'note_editor_sheet.dart';

import '../share/verse_share_sheet.dart';



/// Contextual bottom sheet displayed when tapping any verse in the reader.

class VerseActionSheet extends ConsumerWidget {

  const VerseActionSheet({

    super.key,

    required this.chapter,

    required this.verse,

    required this.translationId,

    this.annotation,

    this.onOpenGraph,

  });



  final BibleChapter chapter;

  final Verse verse;

  final String translationId;

  final VerseAnnotation? annotation;

  final VoidCallback? onOpenGraph;



  static Future<void> show({

    required BuildContext context,

    required BibleChapter chapter,

    required Verse verse,

    required String translationId,

    VerseAnnotation? annotation,

    VoidCallback? onOpenGraph,

  }) {

    return showModalBottomSheet<void>(

      context: context,

      isScrollControlled: true,

      showDragHandle: false,

      backgroundColor: Colors.transparent,

      builder: (ctx) => VerseActionSheet(

        chapter: chapter,

        verse: verse,

        translationId: translationId,

        annotation: annotation,

        onOpenGraph: onOpenGraph,

      ),

    );

  }



  String get _reference => '${chapter.bookName} ${chapter.chapterNumber}:${verse.number}';



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final isFavorite = annotation?.isFavorite ?? false;

    final activeHighlight = annotation?.highlightColor;



    return Container(

      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),

      decoration: BoxDecoration(

        color: colorScheme.surface,

        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),

      ),

      child: Column(

        mainAxisSize: MainAxisSize.min,

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          Center(

            child: Container(

              width: 36,

              height: 4,

              decoration: BoxDecoration(

                color: colorScheme.outlineVariant.withValues(alpha: 0.6),

                borderRadius: BorderRadius.circular(2),

              ),

            ),

          ),

          const SizedBox(height: 12),



          // Header: Reference & Snippet

          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Text(

                _reference,

                style: theme.textTheme.titleMedium?.copyWith(

                  fontWeight: FontWeight.bold,

                  color: colorScheme.primary,

                ),

              ),

              IconButton(

                icon: const Icon(Icons.close, size: 20),

                onPressed: () => Navigator.of(context).pop(),

                visualDensity: VisualDensity.compact,

              ),

            ],

          ),

          const SizedBox(height: 6),

          Text(

            '«${verse.text}»',

            maxLines: 3,

            overflow: TextOverflow.ellipsis,

            style: theme.textTheme.bodyMedium?.copyWith(

              fontStyle: FontStyle.italic,

              color: colorScheme.onSurfaceVariant,

            ),

          ),

          const SizedBox(height: 16),



          // Color Palette Swatches for Highlighting

          Row(

            children: [

              Text(

                'Resaltar:',

                style: theme.textTheme.labelMedium?.copyWith(

                  color: colorScheme.onSurfaceVariant,

                  fontWeight: FontWeight.w600,

                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                child: Row(

                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [

                    _buildColorSwatch(

                      context,

                      ref,

                      colorCode: 'ochre',

                      swatchColor: ReadingPalette.swatchOchre,

                      isSelected: activeHighlight == 'ochre',

                    ),

                    _buildColorSwatch(

                      context,

                      ref,

                      colorCode: 'olive',

                      swatchColor: ReadingPalette.swatchOlive,

                      isSelected: activeHighlight == 'olive',

                    ),

                    _buildColorSwatch(

                      context,

                      ref,

                      colorCode: 'terracotta',

                      swatchColor: ReadingPalette.swatchTerracotta,

                      isSelected: activeHighlight == 'terracotta',

                    ),

                    _buildColorSwatch(

                      context,

                      ref,

                      colorCode: 'indigo',

                      swatchColor: ReadingPalette.swatchIndigo,

                      isSelected: activeHighlight == 'indigo',

                    ),

                    if (activeHighlight != null)

                      IconButton(

                        icon: const Icon(Icons.format_color_reset_outlined, size: 20),

                        tooltip: 'Quitar resaltado',

                        visualDensity: VisualDensity.compact,

                        onPressed: () => _setHighlight(ref, null),

                      ),

                  ],

                ),

              ),

            ],

          ),

          const Divider(height: 28),



          // Action Grid: Favorite, Note, Copy, Share, Connections

          Wrap(

            spacing: 8,

            runSpacing: 8,

            alignment: WrapAlignment.spaceAround,

            children: [

              _buildActionButton(

                icon: isFavorite ? Icons.star_rounded : Icons.star_border_rounded,

                label: isFavorite ? 'Favorito' : 'Favorito',

                color: isFavorite ? Colors.amber[700] : colorScheme.onSurface,

                onTap: () => _toggleFavorite(ref),

              ),

              _buildActionButton(

                icon: annotation?.hasNote == true

                    ? Icons.note_alt_rounded

                    : Icons.note_add_outlined,

                label: annotation?.hasNote == true ? 'Ver nota' : 'Nota',

                color: annotation?.hasNote == true

                    ? colorScheme.primary

                    : colorScheme.onSurface,

                onTap: () => _openNoteEditor(context, ref),

              ),

              _buildActionButton(

                icon: Icons.copy_rounded,

                label: 'Copiar',

                onTap: () => _copyVerse(context),

              ),

              _buildActionButton(

                icon: Icons.share_rounded,

                label: 'Compartir',

                onTap: () => _shareVerse(context),

              ),

              if (onOpenGraph != null)

                _buildActionButton(

                  icon: Icons.hub_outlined,

                  label: 'Conexiones',

                  color: colorScheme.primary,

                  onTap: () {

                    Navigator.of(context).pop();

                    onOpenGraph!();

                  },

                ),

            ],

          ),

        ],

      ),

    );

  }



  Widget _buildColorSwatch(

    BuildContext context,

    WidgetRef ref, {

    required String colorCode,

    required Color swatchColor,

    required bool isSelected,

  }) {

    return GestureDetector(

      onTap: () => _setHighlight(ref, isSelected ? null : colorCode),

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 200),

        width: 34,

        height: 34,

        decoration: BoxDecoration(

          color: swatchColor,

          shape: BoxShape.circle,

          border: isSelected

              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)

              : null,

          boxShadow: [

            if (isSelected)

              BoxShadow(

                color: swatchColor.withValues(alpha: 0.4),

                blurRadius: 8,

                spreadRadius: 1,

              ),

          ],

        ),

        child: isSelected

            ? const Icon(Icons.check, size: 18, color: Colors.white)

            : null,

      ),

    );

  }



  Widget _buildActionButton({

    required IconData icon,

    required String label,

    Color? color,

    required VoidCallback onTap,

  }) {

    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(12),

      child: Padding(

        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(icon, color: color, size: 22),

            const SizedBox(height: 4),

            Text(

              label,

              style: TextStyle(

                fontSize: 12,

                fontWeight: FontWeight.w500,

                color: color,

              ),

            ),

          ],

        ),

      ),

    );

  }



  Future<void> _toggleFavorite(WidgetRef ref) async {

    await ref.read(studyRepositoryProvider).toggleFavorite(

          bookId: chapter.bookId,

          chapterNumber: chapter.chapterNumber,

          verseNumber: verse.number,

          originTranslationId: translationId,

          bookNameSnapshot: chapter.bookName,

          verseTextSnapshot: verse.text,

        );

  }



  Future<void> _setHighlight(WidgetRef ref, String? color) async {

    await ref.read(studyRepositoryProvider).setHighlight(

          bookId: chapter.bookId,

          chapterNumber: chapter.chapterNumber,

          verseNumber: verse.number,

          highlightColor: color,

          originTranslationId: translationId,

          bookNameSnapshot: chapter.bookName,

          verseTextSnapshot: verse.text,

        );

  }



  void _openNoteEditor(BuildContext context, WidgetRef ref) {

    Navigator.of(context).pop();

    NoteEditorSheet.show(

      context: context,

      reference: _reference,

      initialNote: annotation?.noteText,

      initialTags: annotation?.tagsCsv,

      onSave: (text, tags) {

        ref.read(studyRepositoryProvider).saveNote(

              bookId: chapter.bookId,

              chapterNumber: chapter.chapterNumber,

              verseNumber: verse.number,

              noteText: text,

              tagsCsv: tags,

              originTranslationId: translationId,

              bookNameSnapshot: chapter.bookName,

              verseTextSnapshot: verse.text,

            );

      },

      onDelete: () {

        ref.read(studyRepositoryProvider).saveNote(

              bookId: chapter.bookId,

              chapterNumber: chapter.chapterNumber,

              verseNumber: verse.number,

              noteText: null,

              originTranslationId: translationId,

              bookNameSnapshot: chapter.bookName,

              verseTextSnapshot: verse.text,

            );

      },

    );

  }



  void _copyVerse(BuildContext context) {

    final text = '«${verse.text}»\n— $_reference';

    Clipboard.setData(ClipboardData(text: text));

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text('Versículo copiado al portapapeles'),

        duration: Duration(seconds: 2),

      ),

    );

  }



  void _shareVerse(BuildContext context) {

    Navigator.of(context).pop();

    final translationName = translationId == 'spa_blm'

        ? 'Biblia Latinoamericana'

        : 'Reina Valera 1909';



    VerseShareSheet.show(

      context: context,

      reference: _reference,

      verseText: verse.text,

      translationLabel: translationName,

    );

  }

}

