import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized design tokens for the warm, legible "open book" reading
/// experience.
///
/// Keeping colors and the reading typography here (instead of scattered hex
/// values across widgets) lets every screen share one decision point while
/// light and dark modes carry their own variants via [BibleReadingStyle].
abstract final class ReadingPalette {
  /// Deep indigo: primary actions, active elements and graph connections.
  static const Color indigo = Color(0xFF4A3B76);

  /// Warm amber/gold: verse numbers, accents and graph highlights.
  static const Color amber = Color(0xFFD4A017);

  /// Slightly lighter amber reserved for dark surfaces, where the base amber
  /// no longer meets comfortable contrast.
  static const Color amberLight = Color(0xFFE3B23C);

  /// Soft cream: the reading surface that reduces visual fatigue.
  static const Color cream = Color(0xFFF9F7F2);

  /// Slightly brighter cream for elevated surfaces (sheets, cards).
  static const Color paper = Color(0xFFFDFBF7);

  /// Warm charcoal: biblical body text on light surfaces.
  static const Color charcoal = Color(0xFF2D2A26);

  /// Warm near-black: dark-mode reading surface.
  static const Color charcoalSurface = Color(0xFF16130F);

  /// Warm light-gray: dark-mode biblical body text.
  static const Color charcoalPaper = Color(0xFFEDE5D8);

  /// Soft amber hairline used under headings (≈19% amber).
  static const Color amberDivider = Color(0x30D4A017);

  /// Soft amber hairline visible on dark surfaces (≈40% amber).
  static const Color amberDividerDark = Color(0x66D4A017);

  /// Sepia reading surface (paper-like).
  static const Color sepiaSurface = Color(0xFFF4ECD8);

  /// Sepia body text (deep brown/black).
  static const Color sepiaText = Color(0xFF433422);

  /// Soft amber hairline visible on sepia surfaces.
  static const Color amberDividerSepia = Color(0x4DD4A017);
}

/// Typography and surface tokens describing how a chapter is presented.
///
/// Exposed as a [ThemeExtension] so both light and dark [ThemeData] can carry
/// their own variant and widgets can read it back with
/// `Theme.of(context).extension<BibleReadingStyle>()!`.
@immutable
class BibleReadingStyle extends ThemeExtension<BibleReadingStyle> {
  const BibleReadingStyle({
    required this.readingBackground,
    required this.bodyText,
    required this.verseNumber,
    required this.chapterTitle,
    required this.headingDivider,
    required this.navBarBackground,
    required this.chipSurface,
    required this.chipBorder,
  });

  /// Background behind the biblical text (avoids pure white glare).
  final Color readingBackground;

  /// Serif style for the biblical text: 18sp base, generous 1.6 line height.
  final TextStyle bodyText;

  /// Small amber numeral shown at the start of every verse.
  final TextStyle verseNumber;

  /// Large, centered serif title for the passage heading (e.g. "Génesis 1").
  final TextStyle chapterTitle;

  /// Hairline color drawn under the passage heading.
  final Color headingDivider;

  /// Translucent background of the floating previous/next navigation bar.
  final Color navBarBackground;

  /// Background of the interactive connection chips inside the graph sheet.
  final Color chipSurface;

  /// Border color of the connection chips.
  final Color chipBorder;

  /// Base size of the biblical text before the user's font slider multiplies it.
  static const double baseBodyFontSize = 18;

  /// Scale applied to the whole reading column in the [bodyText].
  static const double baseLineHeight = 1.6;

  static final BibleReadingStyle light = BibleReadingStyle(
    readingBackground: ReadingPalette.cream,
    headingDivider: ReadingPalette.amberDivider,
    navBarBackground: const Color(0xF2F9F7F2), // cream at ~95% opacity
    chipSurface: const Color(0x1FD4A017), // amber tint (~12%)
    chipBorder: const Color(0x55D4A017),
    chapterTitle: GoogleFonts.lora(
      fontSize: 27,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: ReadingPalette.charcoal,
    ),
    bodyText: GoogleFonts.lora(
      fontSize: baseBodyFontSize,
      height: baseLineHeight,
      color: ReadingPalette.charcoal,
    ),
    verseNumber: GoogleFonts.inter(
      fontSize: 14,
      height: 1.0,
      fontWeight: FontWeight.w600,
      color: ReadingPalette.amber,
    ),
  );

  static final BibleReadingStyle sepia = BibleReadingStyle(
    readingBackground: ReadingPalette.sepiaSurface,
    headingDivider: ReadingPalette.amberDividerSepia,
    navBarBackground: const Color(0xF2F4ECD8),
    chipSurface: const Color(0x22D4A017),
    chipBorder: const Color(0x55D4A017),
    chapterTitle: GoogleFonts.lora(
      fontSize: 27,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: ReadingPalette.sepiaText,
    ),
    bodyText: GoogleFonts.lora(
      fontSize: baseBodyFontSize,
      height: baseLineHeight,
      color: ReadingPalette.sepiaText,
    ),
    verseNumber: GoogleFonts.inter(
      fontSize: 14,
      height: 1.0,
      fontWeight: FontWeight.w600,
      color: ReadingPalette.amber,
    ),
  );

  static final BibleReadingStyle dark = BibleReadingStyle(
    readingBackground: ReadingPalette.charcoalSurface,
    headingDivider: ReadingPalette.amberDividerDark,
    navBarBackground: const Color(0xF216130F),
    chipSurface: const Color(0x33D4A017),
    chipBorder: const Color(0x66D4A017),
    chapterTitle: GoogleFonts.lora(
      fontSize: 27,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: ReadingPalette.charcoalPaper,
    ),
    bodyText: GoogleFonts.lora(
      fontSize: baseBodyFontSize,
      height: baseLineHeight,
      color: ReadingPalette.charcoalPaper,
    ),
    verseNumber: GoogleFonts.inter(
      fontSize: 14,
      height: 1.0,
      fontWeight: FontWeight.w600,
      color: ReadingPalette.amberLight,
    ),
  );

  /// Returns the body style scaled by [multiplier] (the user's font slider).
  ///
  /// The system text scale factor is applied on top of it automatically by the
  /// [Text] widgets, so both accessibility levers compose instead of fighting.
  TextStyle readingText(double multiplier) =>
      bodyText.copyWith(fontSize: baseBodyFontSize * multiplier);

  @override
  BibleReadingStyle copyWith({
    Color? readingBackground,
    TextStyle? bodyText,
    TextStyle? verseNumber,
    TextStyle? chapterTitle,
    Color? headingDivider,
    Color? navBarBackground,
    Color? chipSurface,
    Color? chipBorder,
  }) {
    return BibleReadingStyle(
      readingBackground: readingBackground ?? this.readingBackground,
      bodyText: bodyText ?? this.bodyText,
      verseNumber: verseNumber ?? this.verseNumber,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      headingDivider: headingDivider ?? this.headingDivider,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      chipSurface: chipSurface ?? this.chipSurface,
      chipBorder: chipBorder ?? this.chipBorder,
    );
  }

  @override
  BibleReadingStyle lerp(ThemeExtension<BibleReadingStyle>? other, double t) {
    if (other is! BibleReadingStyle) {
      return this;
    }
    return BibleReadingStyle(
      readingBackground: Color.lerp(
        readingBackground,
        other.readingBackground,
        t,
      )!,
      headingDivider: Color.lerp(headingDivider, other.headingDivider, t)!,
      navBarBackground: Color.lerp(
        navBarBackground,
        other.navBarBackground,
        t,
      )!,
      chipSurface: Color.lerp(chipSurface, other.chipSurface, t)!,
      chipBorder: Color.lerp(chipBorder, other.chipBorder, t)!,
      bodyText: TextStyle.lerp(bodyText, other.bodyText, t)!,
      verseNumber: TextStyle.lerp(verseNumber, other.verseNumber, t)!,
      chapterTitle: TextStyle.lerp(chapterTitle, other.chapterTitle, t)!,
    );
  }
}
