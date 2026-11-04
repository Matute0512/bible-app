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

  /// Editorial highlight swatches (solid colors for UI selector buttons)
  static const Color swatchOchre = Color(0xFFD4A017);
  static const Color swatchOlive = Color(0xFF6A8050);
  static const Color swatchTerracotta = Color(0xFFC06C54);
  static const Color swatchIndigo = Color(0xFF5B4F82);
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
    required this.highlightOchre,
    required this.highlightOlive,
    required this.highlightTerracotta,
    required this.highlightIndigo,
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

  /// Translucent tint for Ochre verse highlight.
  final Color highlightOchre;

  /// Translucent tint for Olive verse highlight.
  final Color highlightOlive;

  /// Translucent tint for Terracotta verse highlight.
  final Color highlightTerracotta;

  /// Translucent tint for Indigo verse highlight.
  final Color highlightIndigo;

  /// Whether this theme extension represents the Sepia variant.
  bool get isSepia => readingBackground == ReadingPalette.sepiaSurface;

  /// Whether this theme extension represents the Dark variant.
  bool get isDark => readingBackground == ReadingPalette.charcoalSurface;

  static BibleReadingStyle of(BuildContext context) =>
      Theme.of(context).extension<BibleReadingStyle>() ?? BibleReadingStyle.light;

  Color get surfaceColor => readingBackground;
  Color get cardBackground => isDark
      ? const Color(0xFF221F1B)
      : (isSepia ? const Color(0xFFFAF5E8) : ReadingPalette.paper);
  Color get textColor =>
      bodyText.color ?? (isDark ? ReadingPalette.charcoalPaper : ReadingPalette.charcoal);
  Color get metaColor =>
      isDark ? const Color(0xFFA89F91) : const Color(0xFF756F68);

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
    highlightOchre: const Color(0x52E6B800),
    highlightOlive: const Color(0x406A8050),
    highlightTerracotta: const Color(0x3DC06C54),
    highlightIndigo: const Color(0x334A3B76),
  );

  static final BibleReadingStyle sepia = BibleReadingStyle(
    readingBackground: ReadingPalette.sepiaSurface,
    headingDivider: ReadingPalette.amberDividerSepia,
    navBarBackground: const Color(0xF2F4ECD8),
    chipSurface: const Color(0x2BD4A017),
    chipBorder: const Color(0x66D4A017),
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
    highlightOchre: const Color(0x55D4A017),
    highlightOlive: const Color(0x42556B2F),
    highlightTerracotta: const Color(0x42A9523C),
    highlightIndigo: const Color(0x384A3B76),
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
    highlightOchre: const Color(0x4DE3B23C),
    highlightOlive: const Color(0x487D995F),
    highlightTerracotta: const Color(0x4DC97B63),
    highlightIndigo: const Color(0x476E5B9E),
  );

  /// Returns the body style scaled by [multiplier] (the user's font slider).
  ///
  /// The system text scale factor is applied on top of it automatically by the
  /// [Text] widgets, so both accessibility levers compose instead of fighting.
  /// Returns the corresponding translucent highlight background color by name.
  Color? highlightColorFor(String? colorName) {
    if (colorName == null) return null;
    return switch (colorName.toLowerCase()) {
      'ochre' => highlightOchre,
      'olive' => highlightOlive,
      'terracotta' => highlightTerracotta,
      'indigo' => highlightIndigo,
      _ => null,
    };
  }

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
    Color? highlightOchre,
    Color? highlightOlive,
    Color? highlightTerracotta,
    Color? highlightIndigo,
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
      highlightOchre: highlightOchre ?? this.highlightOchre,
      highlightOlive: highlightOlive ?? this.highlightOlive,
      highlightTerracotta: highlightTerracotta ?? this.highlightTerracotta,
      highlightIndigo: highlightIndigo ?? this.highlightIndigo,
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
      highlightOchre: Color.lerp(highlightOchre, other.highlightOchre, t)!,
      highlightOlive: Color.lerp(highlightOlive, other.highlightOlive, t)!,
      highlightTerracotta: Color.lerp(highlightTerracotta, other.highlightTerracotta, t)!,
      highlightIndigo: Color.lerp(highlightIndigo, other.highlightIndigo, t)!,
    );
  }
}

/// Factory for configuring light, sepia, and dark application themes.
abstract final class BibleTheme {
  /// Builds the warm "open book" theme for [brightness].
  static ThemeData build(Brightness brightness, {bool isSepia = false}) {
    final isLight = brightness == Brightness.light;
    final reading = isLight
        ? (isSepia ? BibleReadingStyle.sepia : BibleReadingStyle.light)
        : BibleReadingStyle.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: ReadingPalette.indigo,
      brightness: brightness,
      primary: isLight ? ReadingPalette.indigo : null,
      onPrimary: isLight ? Colors.white : null,
      secondary: isLight ? ReadingPalette.amber : ReadingPalette.amberLight,
      surface: reading.readingBackground,
      onSurface: isLight
          ? (isSepia ? ReadingPalette.sepiaText : ReadingPalette.charcoal)
          : ReadingPalette.charcoalPaper,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: reading.readingBackground,
      extensions: [reading],
      appBarTheme: AppBarTheme(
        backgroundColor: reading.readingBackground,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        modalBackgroundColor: isLight
            ? (isSepia ? ReadingPalette.sepiaSurface : ReadingPalette.paper)
            : const Color(0xFF211C16),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isSepia
            ? ReadingPalette.amberDividerSepia
            : ReadingPalette.amberDivider,
        thickness: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.primary.withValues(alpha: 0.16),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      splashFactory: InkSparkle.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
