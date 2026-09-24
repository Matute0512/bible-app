import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bible_chapter.dart';
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

/// Interactive map of the curated connections leaving the current chapter.
///
/// Related passages are laid out as nodes around the current passage and
/// linked with painted edges. Every node is tappable and scales subtly on
/// press. Below the map each relation is repeated as a chip-style row with a
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

    final readingState = ref.watch(dailyReadingProvider).value;

    // Extract the chapter from whichever reading state is active.
    final BibleChapter? chapter = switch (readingState) {
      Loaded s => s.chapter,
      FreeReadingLoaded s => s.chapter,
      Navigating s => s.previousChapter,
      _ => null,
    };

    if (chapter == null) return const SizedBox.shrink();

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

    final originHint =
        fromVerse != null ? 'desde el versículo $fromVerse' : null;

    /// Navigates to [target] passage, handling both plan-based and free reading.
    ///
    /// FIX [BUG-GRAPH-01]: Extracted closure captures [readingState] which is
    /// now a stable local variable, preventing stale-closure captures of [state]
    /// after the widget rebuilds mid-animation.
    void onOpenPassage(PassageRef target) {
      Navigator.of(context).pop();

      final plan = switch (readingState) {
        Loaded s => s.plan,
        Navigating s => s.plan,
        _ => null,
      };

      if (plan == null) {
        // Free reading mode: navigate directly with the API.
        ref.read(dailyReadingProvider.notifier).loadFreeChapter(
          target.bookId,
          target.bookName,
          target.chapterNumber,
        );
        return;
      }

      final index = plan.indexWhere(
        (entry) =>
            entry.bookId == target.bookId &&
            entry.chapterNumber == target.chapterNumber,
      );

      if (index >= 0) {
        ref.read(dailyReadingProvider.notifier).goToPlanIndex(index);
      } else {
        // Target is not in the current plan — still navigate using free reading.
        ref.read(dailyReadingProvider.notifier).loadFreeChapter(
          target.bookId,
          target.bookName,
          target.chapterNumber,
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
            _buildHeading(context, center, originHint, colorScheme),
            const SizedBox(height: 6),
            if (connections.isEmpty)
              _buildEmptyState(context, colorScheme)
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
    ColorScheme colorScheme,
  ) {
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
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

// ============================================================
// _GraphCanvas
// ============================================================

class _GraphCanvas extends StatefulWidget {
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

  @override
  State<_GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<_GraphCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  // Center node is a pill: half-height ≈ its vertical radius.
  static const double _centerWidth = 128;
  static const double _centerHeight = 58;

  // Peripheral nodes are smaller pills.
  static const double _nodeHeight = 48;

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reading = Theme.of(context).extension<BibleReadingStyle>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final box = math.min(constraints.maxWidth, 450.0);
        final half = box / 2;

        final count = widget.connections.length;

        // Orbit radius: leave enough room for half a node + padding.
        final radius = (half - _nodeHeight / 2 - 20)
            .clamp(90.0, half - 30.0)
            .toDouble();

        // Maximum chord between two adjacent nodes on the orbit.
        final chord = 2 * radius * math.sin(math.pi / math.max(count, 1));
        final nodeWidth = chord.clamp(70.0, 160.0).toDouble();

        final centerPos = Offset(half, half);

        // [FIX-ARROW-01] Pre-compute per-node geometry so the painter can
        // clip lines to the *surface* of each pill instead of its centre.
        // A rounded-rect pill has an elliptical silhouette; we approximate
        // it as a circle whose radius equals half the shorter dimension
        // (height), which is conservative and visually clean.
        final double centerRx = _centerWidth / 2;
        final double centerRy = _centerHeight / 2;
        final double nodeRx = nodeWidth / 2;
        final double nodeRy = _nodeHeight / 2;

        final targets = <Offset>[];
        for (var i = 0; i < count; i++) {
          final angle = -math.pi / 2 + i * (2 * math.pi / count);
          targets.add(
            Offset(half + radius * math.cos(angle), half + radius * math.sin(angle)),
          );
        }

        final graphBox = SizedBox(
          width: box,
          height: box,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Draw edges beneath the nodes.
              FadeTransition(
                opacity: _entrance,
                child: CustomPaint(
                  size: Size.square(box),
                  painter: _EdgesPainter(
                    center: centerPos,
                    targets: targets,
                    color: widget.colorScheme.primary.withValues(alpha: 0.35),
                    // Pill radii so the painter can trim lines at node borders.
                    centerRx: centerRx,
                    centerRy: centerRy,
                    nodeRx: nodeRx,
                    nodeRy: nodeRy,
                  ),
                ),
              ),
              // Center node
              Positioned(
                left: centerPos.dx - centerRx,
                top: centerPos.dy - centerRy,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _entrance,
                    curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
                  ),
                  child: _Node(
                    width: _centerWidth,
                    height: _centerHeight,
                    textColor: widget.colorScheme.onPrimary,
                    fill: widget.colorScheme.primary,
                    border: widget.colorScheme.primary,
                    label: widget.center.reference,
                    semanticsLabel: 'Pasaje actual: ${widget.center.reference}',
                    onTap: null,
                  ),
                ),
              ),
              // Related nodes
              for (var i = 0; i < count; i++)
                Positioned(
                  left: targets[i].dx - nodeRx,
                  top: targets[i].dy - nodeRy,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _entrance,
                      curve: Interval(
                        0.2 + (i / count) * 0.5,
                        1.0,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: _Node(
                      width: nodeWidth,
                      height: _nodeHeight,
                      textColor: widget.colorScheme.onSurface,
                      fill: reading.chipSurface,
                      border: reading.chipBorder,
                      label: widget.connections[i].target.reference,
                      semanticsLabel:
                          'Ir a ${widget.connections[i].target.reference} · '
                          '${widget.connections[i].kind.label}',
                      onTap: () =>
                          widget.onOpenPassage(widget.connections[i].target),
                    ),
                  ),
                ),
            ],
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: SizedBox(
            height: box,
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(40),
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(child: graphBox),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// _Node
// ============================================================

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
              // [FIX-NODE-01] Border radius is always height/2 so the pill
              // stays perfectly rounded regardless of the dynamic node width.
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

// ============================================================
// _EdgesPainter — hub-and-spoke with arrow tips clipped to node borders
// ============================================================

/// Paints directed edges from the centre node to each peripheral node.
///
/// [FIX-ARROW-01] The original code drew lines from centre-centre to
/// target-centre, causing the line to pass *through* both pill nodes.
/// This version trims each line so it:
///   • starts at the border of the centre pill (outward direction).
///   • ends at the border of the target pill (inward direction).
///   • finishes with a small arrowhead that points exactly at the border.
///
/// The border intersection uses an ellipse approximation:
///   t = 1 / sqrt((cos²θ / rx²) + (sin²θ / ry²))
/// where (rx, ry) are the semi-axes of the pill's bounding ellipse.
class _EdgesPainter extends CustomPainter {
  const _EdgesPainter({
    required this.center,
    required this.targets,
    required this.color,
    required this.centerRx,
    required this.centerRy,
    required this.nodeRx,
    required this.nodeRy,
  });

  final Offset center;
  final List<Offset> targets;
  final Color color;

  /// Semi-axes of the centre pill's bounding ellipse.
  final double centerRx;
  final double centerRy;

  /// Semi-axes of a peripheral pill's bounding ellipse.
  final double nodeRx;
  final double nodeRy;

  // Arrowhead geometry.
  static const double _arrowLen = 9.0;
  static const double _arrowHalf = 3.5;

  /// Returns the parameter `t` for the point on an axis-aligned ellipse
  /// (rx, ry) at angle [angle] (radians from the positive x-axis).
  ///
  ///   x = t · cos(angle),  y = t · sin(angle)   lies on the ellipse when
  ///   (x/rx)² + (y/ry)² = 1  →  t = 1/sqrt(cos²/rx² + sin²/ry²)
  static double _ellipseRadius(double angle, double rx, double ry) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    return 1.0 /
        math.sqrt((cos * cos) / (rx * rx) + (sin * sin) / (ry * ry));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final beadPaint = Paint()..color = color;

    for (final target in targets) {
      final dx = target.dx - center.dx;
      final dy = target.dy - center.dy;
      final angle = math.atan2(dy, dx);
      final angleBack = angle + math.pi; // opposite direction

      // Trim the line start: step outward from the centre pill border.
      final tCenter = _ellipseRadius(angle, centerRx, centerRy);
      final lineStart = Offset(
        center.dx + tCenter * math.cos(angle),
        center.dy + tCenter * math.sin(angle),
      );

      // Trim the line end: step inward from the target pill border.
      // The arrowhead tip lands exactly on the pill surface.
      final tNode = _ellipseRadius(angleBack, nodeRx, nodeRy);
      final tipPoint = Offset(
        target.dx + tNode * math.cos(angleBack),
        target.dy + tNode * math.sin(angleBack),
      );

      // Pull the line back by the arrow length so the shaft ends where
      // the arrowhead begins, keeping the tip flush with the node border.
      final shaftEnd = Offset(
        tipPoint.dx - _arrowLen * math.cos(angle),
        tipPoint.dy - _arrowLen * math.sin(angle),
      );

      canvas.drawLine(lineStart, shaftEnd, linePaint);

      // Draw filled arrowhead triangle.
      final perpX = -math.sin(angle) * _arrowHalf;
      final perpY = math.cos(angle) * _arrowHalf;
      final arrowPath = Path()
        ..moveTo(tipPoint.dx, tipPoint.dy)
        ..lineTo(shaftEnd.dx + perpX, shaftEnd.dy + perpY)
        ..lineTo(shaftEnd.dx - perpX, shaftEnd.dy - perpY)
        ..close();
      canvas.drawPath(arrowPath, arrowPaint);

      // Small bead at the shaft origin adds visual rhythm.
      canvas.drawCircle(lineStart, 3.0, beadPaint);
    }
  }

  @override
  bool shouldRepaint(_EdgesPainter old) =>
      old.center != center ||
      old.color != color ||
      old.targets.length != targets.length ||
      old.centerRx != centerRx ||
      old.nodeRx != nodeRx;
}

// ============================================================
// _ConnectionRow
// ============================================================

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
