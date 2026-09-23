import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Dependency-free loading skeleton for a chapter.
///
/// Renders muted bars shaped like the verse column and sweeps a soft light
/// band across them while the chapter downloads. The skeleton reads as "paper
/// that is still being written" instead of a spinner, and because the motion
/// is a paint animation it never triggers extra layout work.
class VerseShimmerList extends StatefulWidget {
  const VerseShimmerList({super.key, this.itemCount = 9});

  /// Number of "verse" placeholders to draw while loading.
  final int itemCount;

  @override
  State<VerseShimmerList> createState() => _VerseShimmerListState();
}

class _VerseShimmerListState extends State<VerseShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    // Tones adapt to the theme: soft warm gray bars on cream, soft warm light
    // on the dark surface. The sheen is always a translucent "higher" tone.
    final baseColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.10 : 0.08,
    );
    final numberColor = colorScheme.secondary.withValues(
      alpha: isDark ? 0.22 : 0.18,
    );
    final sheenColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.16 : 0.14,
    );

    return Semantics(
      label: 'Cargando el capítulo',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              size: Size.infinite,
              painter: _VerseSkeletonPainter(
                itemCount: widget.itemCount,
                baseColor: baseColor,
                numberColor: numberColor,
                sheenColor: sheenColor,
                progress: _controller.value,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the shimmering verse placeholders.
class _VerseSkeletonPainter extends CustomPainter {
  _VerseSkeletonPainter({
    required this.itemCount,
    required this.baseColor,
    required this.numberColor,
    required this.sheenColor,
    required this.progress,
  });

  final int itemCount;
  final Color baseColor;
  final Color numberColor;
  final Color sheenColor;

  /// Animation progress in `[0, 1)`; drives the light band sweep.
  final double progress;

  /// Deterministic pseudo-random widths so the same verse always shows the
  /// same broken-line shape across frames (no jitter between rebuilds).
  static const List<double> _widthPatterns = [1.0, 0.93, 0.72, 0.88, 0.6, 0.96];

  static const double _barHeight = 15;
  static const double _numberSize = 14;
  static const double _lineGap = 6;
  static const double _rowGap = 20;

  @override
  void paint(Canvas canvas, Size size) {
    // Reserve the verse-number gutter, then draw each verse's broken lines.
    final textLeft = _numberSize + 14.0;
    var rowY = 0.0;

    // Collect bar rects so the sheen can be clipped to exactly them.
    final barsPath = Path();
    final bars = <Rect>[];

    for (var verse = 0; verse < itemCount; verse++) {
      if (rowY + 120 > size.height) {
        break; // Leave an empty tail instead of overflowing the viewport.
      }

      // Small square for the verse number, tinted amber like real numerals.
      final numberRect = Rect.fromLTWH(
        0,
        rowY + (_barHeight - _numberSize) / 2,
        _numberSize,
        _numberSize,
      );
      final numberRRect = RRect.fromRectAndRadius(
        numberRect,
        const Radius.circular(4),
      );
      canvas.drawRRect(numberRRect, Paint()..color = numberColor);

      var y = rowY;
      final lineCount = 2 + (verse % 3 == 0 ? 1 : 0); // occasional third line
      for (var line = 0; line < lineCount; line++) {
        final fraction = _widthPatterns[(verse + line) % _widthPatterns.length];
        // The last line of a verse is shorter, as real wrapped text would be.
        final width = line == lineCount - 1
            ? (size.width - textLeft) * (fraction * 0.72)
            : (size.width - textLeft) * (fraction * 0.96);

        final rect = Rect.fromLTWH(textLeft, y, width, _barHeight);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(7));
        canvas.drawRRect(rrect, Paint()..color = baseColor);
        barsPath.addRRect(rrect);
        bars.add(rect);
        y += _barHeight + _lineGap;
      }

      rowY = y + _rowGap;
    }

    if (bars.isEmpty) {
      return;
    }

    // Sweep a soft light band across the bars. The band is wider than one
    // "cycle" so a single horizontal pass reads as a continuous shine.
    final bandWidth = size.width * 0.55;
    final travel = size.width + bandWidth;
    final left = progress * travel - bandWidth;
    final band = Rect.fromLTWH(left, 0, bandWidth, rowY);

    canvas.save();
    canvas.clipPath(barsPath);
    final sheen = Paint()
      ..shader = ui.Gradient.linear(
        band.centerLeft,
        band.centerRight,
        [
          sheenColor.withValues(alpha: 0),
          sheenColor,
          sheenColor.withValues(alpha: 0),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(band, sheen);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_VerseSkeletonPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.itemCount != itemCount ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.numberColor != numberColor ||
      oldDelegate.sheenColor != sheenColor;
}
