import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/verse_annotation.dart';
import '../providers/reading_plan_provider.dart';
import '../providers/study_providers.dart';
import '../theme/bible_theme.dart';
import '../widgets/reader/note_editor_sheet.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedHighlightColor; // null means 'Todos'
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToVerse(VerseAnnotation annotation) {
    ref.read(dailyReadingProvider.notifier).loadFreeChapter(
          annotation.bookId,
          annotation.bookNameSnapshot,
          annotation.chapterNumber,
        );
    context.push('/reading');
  }

  Future<void> _toggleFavorite(VerseAnnotation annotation) async {
    final repo = ref.read(studyRepositoryProvider);
    await repo.toggleFavorite(
      bookId: annotation.bookId,
      chapterNumber: annotation.chapterNumber,
      verseNumber: annotation.verseNumber,
      originTranslationId: annotation.originTranslationId,
      bookNameSnapshot: annotation.bookNameSnapshot,
      verseTextSnapshot: annotation.verseTextSnapshot,
    );
  }

  void _openNoteEditor(VerseAnnotation annotation) {
    final repo = ref.read(studyRepositoryProvider);
    NoteEditorSheet.show(
      context: context,
      reference: annotation.reference,
      initialNote: annotation.noteText,
      initialTags: annotation.tagsCsv,
      onSave: (text, tags) {
        repo.saveNote(
          bookId: annotation.bookId,
          chapterNumber: annotation.chapterNumber,
          verseNumber: annotation.verseNumber,
          noteText: text,
          tagsCsv: tags,
          originTranslationId: annotation.originTranslationId,
          bookNameSnapshot: annotation.bookNameSnapshot,
          verseTextSnapshot: annotation.verseTextSnapshot,
        );
      },
      onDelete: () {
        repo.saveNote(
          bookId: annotation.bookId,
          chapterNumber: annotation.chapterNumber,
          verseNumber: annotation.verseNumber,
          noteText: null,
          tagsCsv: null,
          originTranslationId: annotation.originTranslationId,
          bookNameSnapshot: annotation.bookNameSnapshot,
          verseTextSnapshot: annotation.verseTextSnapshot,
        );
      },
    );
  }

  Future<void> _deleteAnnotation(VerseAnnotation annotation) async {
    final repo = ref.read(studyRepositoryProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar versículo guardado?',
            style: TextStyle(fontFamily: 'Lora')),
        content: Text(
          'Se eliminarán el favorito, los resaltados y las notas asociadas a ${annotation.reference}.',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await repo.deleteAnnotation(annotation.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${annotation.reference} eliminado.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  List<VerseAnnotation> _filterByQuery(List<VerseAnnotation> list) {
    if (_searchQuery == null || _searchQuery!.trim().isEmpty) return list;
    final q = _searchQuery!.toLowerCase().trim();
    return list.where((a) {
      final matchesRef = a.reference.toLowerCase().contains(q);
      final matchesText = a.verseTextSnapshot.toLowerCase().contains(q);
      final matchesNote = a.noteText?.toLowerCase().contains(q) ?? false;
      final matchesTags =
          a.tags.any((tag) => tag.toLowerCase().contains(q));
      return matchesRef || matchesText || matchesNote || matchesTags;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    final allAnnotationsAsync = ref.watch(allAnnotationsProvider);
    final favoritesAsync = ref.watch(allFavoritesProvider);
    final highlightsAsync = ref.watch(highlightsProvider(_selectedHighlightColor));
    final notesAsync = ref.watch(allNotesProvider);

    return Scaffold(
      backgroundColor: readingStyle.surfaceColor,
      appBar: AppBar(
        backgroundColor: readingStyle.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Guardados y Estudio',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            color: readingStyle.textColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: readingStyle.metaColor,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Favoritos'),
            Tab(text: 'Resaltados'),
            Tab(text: 'Notas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Tab Todos
          _buildAnnotationsStreamView(
            asyncValue: allAnnotationsAsync,
            emptyTitle: 'No tenés versículos guardados',
            emptySubtitle:
                'Al leer un capítulo, tocá cualquier versículo para destacarlo, guardarlo como favorito o escribir una nota personal.',
            emptyIcon: Icons.collections_bookmark_outlined,
          ),

          // 2. Tab Favoritos
          _buildAnnotationsStreamView(
            asyncValue: favoritesAsync,
            emptyTitle: 'Sin versículos favoritos',
            emptySubtitle:
                'Marcá versículos con la estrella para encontrarlos rápidamente en esta sección.',
            emptyIcon: Icons.bookmark_border_rounded,
          ),

          // 3. Tab Resaltados con filtro por color
          Column(
            children: [
              _buildHighlightColorFilter(),
              Expanded(
                child: _buildAnnotationsStreamView(
                  asyncValue: highlightsAsync,
                  emptyTitle: 'Sin versículos resaltados',
                  emptySubtitle:
                      'Resaltá versículos usando los 4 colores editoriales: Ocre, Oliva, Terracota o Índigo.',
                  emptyIcon: Icons.border_color_outlined,
                ),
              ),
            ],
          ),

          // 4. Tab Notas
          _buildAnnotationsStreamView(
            asyncValue: notesAsync,
            emptyTitle: 'Sin notas de estudio',
            emptySubtitle:
                'Escribí reflexiones, oraciones y notas personales vinculadas a tus lecturas diarias.',
            emptyIcon: Icons.edit_note_rounded,
            isNotesTab: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightColorFilter() {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    final colors = [
      (null, 'Todos'),
      ('ochre', 'Ocre'),
      ('olive', 'Oliva'),
      ('terracotta', 'Terracota'),
      ('indigo', 'Índigo'),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: colors.map((item) {
          final isSelected = _selectedHighlightColor == item.$1;
          Color? swatch;
          if (item.$1 == 'ochre') swatch = const Color(0xFFC89332);
          if (item.$1 == 'olive') swatch = const Color(0xFF637D42);
          if (item.$1 == 'terracotta') swatch = const Color(0xFFB85942);
          if (item.$1 == 'indigo') swatch = const Color(0xFF435B88);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: swatch != null
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: swatch,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              label: Text(
                item.$2,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : readingStyle.metaColor,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedHighlightColor = item.$1;
                });
              },
              backgroundColor: readingStyle.cardBackground,
              selectedColor: theme.colorScheme.primaryContainer,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnnotationsStreamView({
    required AsyncValue<List<VerseAnnotation>> asyncValue,
    required String emptyTitle,
    required String emptySubtitle,
    required IconData emptyIcon,
    bool isNotesTab = false,
  }) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    return asyncValue.when(
      data: (items) {
        final filteredItems = _filterByQuery(items);
        if (filteredItems.isEmpty) {
          return _buildEmptyState(
            title: emptyTitle,
            subtitle: emptySubtitle,
            icon: emptyIcon,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredItems.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final annotation = filteredItems[index];
            return _buildAnnotationCard(annotation, isNotesTab: isNotesTab);
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary,
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error al cargar elementos guardados: $err',
            style: TextStyle(color: readingStyle.metaColor),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnotationCard(
    VerseAnnotation annotation, {
    bool isNotesTab = false,
  }) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    Color? highlightBg;
    Color? highlightBorder;
    if (annotation.highlightColor == 'ochre') {
      highlightBg = readingStyle.highlightOchre;
      highlightBorder = const Color(0xFFC89332);
    } else if (annotation.highlightColor == 'olive') {
      highlightBg = readingStyle.highlightOlive;
      highlightBorder = const Color(0xFF637D42);
    } else if (annotation.highlightColor == 'terracotta') {
      highlightBg = readingStyle.highlightTerracotta;
      highlightBorder = const Color(0xFFB85942);
    } else if (annotation.highlightColor == 'indigo') {
      highlightBg = readingStyle.highlightIndigo;
      highlightBorder = const Color(0xFF435B88);
    }

    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'es');
    final formattedDate = dateFormat.format(annotation.updatedAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToVerse(annotation),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: highlightBg ?? readingStyle.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: highlightBorder ??
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: highlightBorder != null ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Reference + Star + Note + Delete
              Row(
                children: [
                  Text(
                    annotation.reference,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      annotation.originTranslationId.toUpperCase().replaceAll('_', ' '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontFamily: 'Inter',
                        color: readingStyle.metaColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      annotation.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 20,
                      color: annotation.isFavorite
                          ? const Color(0xFFE5A024)
                          : readingStyle.metaColor,
                    ),
                    tooltip: annotation.isFavorite
                        ? 'Quitar de favoritos'
                        : 'Marcar como favorito',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _toggleFavorite(annotation),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, size: 20),
                    tooltip: 'Editar nota',
                    color: readingStyle.metaColor,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _openNoteEditor(annotation),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    tooltip: 'Eliminar',
                    color: readingStyle.metaColor,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _deleteAnnotation(annotation),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Verse text
              Text(
                '«${annotation.verseTextSnapshot}»',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 14.5,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                  color: readingStyle.textColor,
                ),
              ),

              // Personal Note preview (if any)
              if (annotation.noteText != null &&
                  annotation.noteText!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: readingStyle.cardBackground.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Nota personal',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formattedDate,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontFamily: 'Inter',
                              color: readingStyle.metaColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        annotation.noteText!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1.4,
                          color: readingStyle.textColor,
                        ),
                      ),
                      if (annotation.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: annotation.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final readingStyle = BibleReadingStyle.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: readingStyle.metaColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Lora',
                fontWeight: FontWeight.w600,
                color: readingStyle.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Inter',
                color: readingStyle.metaColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
