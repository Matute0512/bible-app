import 'package:flutter/material.dart';

/// Editorial sheet to write or edit a personal study note for a verse.
class NoteEditorSheet extends StatefulWidget {
  const NoteEditorSheet({
    super.key,
    required this.reference,
    this.initialNote,
    this.initialTags,
    required this.onSave,
    this.onDelete,
  });

  final String reference;
  final String? initialNote;
  final String? initialTags;
  final void Function(String text, String? tags) onSave;
  final VoidCallback? onDelete;

  static Future<void> show({
    required BuildContext context,
    required String reference,
    String? initialNote,
    String? initialTags,
    required void Function(String text, String? tags) onSave,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NoteEditorSheet(
        reference: reference,
        initialNote: initialNote,
        initialTags: initialTags,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late final TextEditingController _noteController;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _tagsController = TextEditingController(text: widget.initialTags ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final text = _noteController.text.trim();
    if (text.isEmpty) {
      if (widget.onDelete != null) {
        widget.onDelete!();
      }
      Navigator.of(context).pop();
      return;
    }
    final tags = _tagsController.text.trim();
    widget.onSave(text, tags.isNotEmpty ? tags : null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Nota en ${widget.reference}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              if (widget.initialNote != null && widget.onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  tooltip: 'Eliminar nota',
                  onPressed: () {
                    widget.onDelete!();
                    Navigator.of(context).pop();
                  },
                ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cerrar',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 5,
            minLines: 3,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Escribe tu reflexión o apunte de estudio...',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsController,
            decoration: InputDecoration(
              hintText: 'Etiquetas (separadas por coma, ej: fe, oracion)',
              prefixIcon: const Icon(Icons.label_outline, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _handleSave,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

