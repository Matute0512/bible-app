import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../services/verse_connections_service.dart';
import '../theme/bible_theme.dart';

Future<void> showGraphExplorer(BuildContext context, {int? fromVerse}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => GraphExplorerWidget(fromVerse: fromVerse),
  );
}

/// Interactive map of the curated connections leaving [center].
///
/// The related passages are laid out as nodes around the current passage and
/// linked with painted edges; every node is tappable and scales subtly on
/// press. Below the map, each relation is repeated as a chip-style row with a
/// short note, so the same navigation is reachable both visually and by
/// screen readers.
class GraphExplorerWidget extends ConsumerWidget {
  const GraphExplorerWidget({super.key, this.fromVerse});

  /// Optional verse number where the graph was opened from.
  final int? fromVerse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final state = ref.watch(dailyReadingProvider).value;
    if (state is! Loaded && state is! Navigating) {
      return const SizedBox.shrink();
    }

    final chapter = state is Loaded
        ? state.chapter
        : (state as Navigating).previousChapter;
    final center = PassageRef(
      bookId: chapter.bookId,
      bookName: chapter.bookName,
      chapterNumber: chapter.chapterNumber,
    );

    final connections = ref
        .watch(verseConnectionsProvider)
        .connectionsFor(
          bookId: chapter.bookId,
          chapterNumber: chapter.chapterNumber,
        );

    final originHint = fromVerse != null
        ? 'desde el versículo $fromVerse'
        : null;

    void onOpenPassage(PassageRef target) {
      Navigator.of(context).pop();
      final plan = state is Loaded ? state.plan : (state as Navigating).plan;
      final index = plan.indexWhere(
        (entry) =>
            entry.bookId == target.bookId &&
            entry.chapterNumber == target.chapterNumber,
      );
      if (index >= 0) {
        ref.read(dailyReadingProvider.notifier).goToPlanIndex(index);
      } else {
        final colorScheme = Theme.of(context).colorScheme;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, size: 22, color: colorScheme.error),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Este pasaje no está en tu plan actual de lectura',
                    ),
                  ),
                ],
              ),
            ),
          );
      }
    }

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 4, 24, bottomInset + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeading(context, center, originHint),
            const SizedBox(height: 6),
            if (connections.isEmpty)
              _buildEmptyState(context)
            else ...[
              _GraphCanvas(
                center: center,
                connections: connections,
                colorScheme: colorScheme,
                onOpenPassage: onOpenPassage,
              ),
              const SizedBox(height: 12),
              Text(
                'Relaciones',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              for (final connection in connections)
                _ConnectionRow(
                  key: ValueKey(
                    '${connection.target.reference}-${connection.kind}',
                  ),
                  connection: connection,
                  onTap: () => onOpenPassage(connection.target),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(
    BuildContext context,
    PassageRef center,
    String? originHint,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.hub_outlined, size: 22, color: colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conexiones de ${center.reference}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (originHint != null)
                Text(
                  originHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.alt_route, size: 40, color: colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'Este pasaje aún no tiene conexiones registradas.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'La red de referencias crece pasaje por pasaje.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Radial hub-and-spoke map: [center] in the middle, related passages around
/// it, edges painted behind the nodes with a [CustomPainter].
class _GraphCanvas extends StatelessWidget {
  const _GraphCanvas({
    required this.center,
    required this.connections,
    required this.colorScheme,
    required this.onOpenPassage,
  });

  final PassageRef center;
  final List<VerseConnection> connections;
  final ColorScheme colorScheme;
  final ValueChanged<PassageRef> onOpenPassage;

  static const double _centerWidth = 128;
  static const double _centerHeight = 58;
  static const double _nodeHeight = 48;

  @override
  Widget build(BuildContext context) {
    final reading = Theme.of(context).extension<BibleReadingStyle>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final box = math.min(constraints.maxWidth, 380.0);
        final half = box / 2;

        // Target pills sit on a ring just inside the box edges.
        final count = connections.length;
        final radius = (half - _nodeHeight / 2 - 14)
            .clamp(70.0, half - 34.0)
            .toDouble();
        final chord = 2 * radius * math.sin(math.pi / count);
        final nodeWidth = chord.clamp(64.0, 150.0).toDouble();

        final centerOffset = Offset(half, half);
        final targets = <Offset>[];
        for (var i = 0; i < count; i++) {
          final angle = -math.pi / 2 + i * (2 * math.pi / count);
          targets.add(
            Offset(
              half + radius * math.cos(angle),
              half + radius * math.sin(angle),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: SizedBox(
            width: box,
            height: box,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Edges first, so nodes render above the lines.
                CustomPaint(
                  size: Size.square(box),
                  painter: _EdgesPainter(
                    center: centerOffset,
                    targets: targets,
                    color: colorScheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                // Center node.
                Positioned(
                  left: centerOffset.dx - _centerWidth / 2,
                  top: centerOffset.dy - _centerHeight / 2,
                  child: _Node(
                    width: _centerWidth,
                    height: _centerHeight,
                    textColor: colorScheme.onPrimary,
                    fill: colorScheme.primary,
                    border: colorScheme.primary,
                    label: center.reference,
                    semanticsLabel: 'Pasaje actual: ${center.reference}',
                    onTap: null,
                  ),
                ),
                // Related nodes.
                for (var i = 0; i < count; i++)
                  Positioned(
                    left: targets[i].dx - nodeWidth / 2,
                    top: targets[i].dy - _nodeHeight / 2,
                    child: _Node(
                      width: nodeWidth,
                      height: _nodeHeight,
                      textColor: colorScheme.onSurface,
                      fill: reading.chipSurface,
                      border: reading.chipBorder,
                      label: connections[i].target.reference,
                      semanticsLabel:
                          'Ir a ${connections[i].target.reference} · '
                          '${connections[i].kind.label}',
                      onTap: () => onOpenPassage(connections[i].target),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One graph node: a rounded pill that scales subtly while pressed.
class _Node extends StatefulWidget {
  const _Node({
    required this.width,
    required this.height,
    required this.label,
    required this.textColor,
    required this.fill,
    required this.border,
    required this.onTap,
    required this.semanticsLabel,
  });

  final double width;
  final double height;
  final String label;
  final Color textColor;
  final Color fill;
  final Color border;
  final VoidCallback? onTap;
  final String semanticsLabel;

  @override
  State<_Node> createState() => _NodeState();
}

class _NodeState extends State<_Node> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null;
    return Semantics(
      button: tappable,
      label: widget.semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: tappable ? (_) => setState(() => _pressed = true) : null,
        onTapUp: tappable ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: tappable ? () => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.fill,
              borderRadius: BorderRadius.circular(widget.height / 2),
              border: Border.all(color: widget.border, width: 1.2),
              boxShadow: _pressed
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.label,
                maxLines: 1,
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: widget.onTap == null ? 15 : 13.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the hub-and-spoke edges underneath the nodes.
class _EdgesPainter extends CustomPainter {
  _EdgesPainter({
    required this.center,
    required this.targets,
    required this.color,
  });

  final Offset center;
  final List<Offset> targets;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final target in targets) {
      canvas.drawLine(center, target, paint);
      // A tiny amber bead on the far end makes the connection feel alive.
      final bead = Paint()..color = color;
      canvas.drawCircle(target, 3, bead);
    }
  }

  @override
  bool shouldRepaint(_EdgesPainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.color != color ||
      oldDelegate.targets.length != targets.length;
}

/// Chip-style row showing one relation with its icon, kind label and note.
class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({
    super.key,
    required this.connection,
    required this.onTap,
  });

  final VerseConnection connection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reading = Theme.of(context).extension<BibleReadingStyle>()!;
    final colorScheme = Theme.of(context).colorScheme;

    final row = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      decoration: BoxDecoration(
        color: reading.chipSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: reading.chipBorder, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            connectionIconFor(connection.kind),
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      connection.target.reference,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: ReadingPalette.amber.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        connection.kind.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ReadingPalette.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (connection.note != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    connection.note!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: colorScheme.outline),
        ],
      ),
    );

    return Semantics(
      button: true,
      label: 'Abrir ${connection.target.reference} · ${connection.kind.label}',
      excludeSemantics: true,
      child: GestureDetector(onTap: onTap, child: row),
    );
  }
}
