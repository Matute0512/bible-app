import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which translation/canon the app reads from.
enum BibleTranslation {
  /// Protestant canon (66 books), served by `spa_rvg`.
  evangelical,

  /// Catholic canon (73 books), served by `spa_blm`.
  catholic;

  /// The translation id understood by the Free Use Bible API.
  String get translationId => switch (this) {
    BibleTranslation.evangelical => 'spa_rvg',
    BibleTranslation.catholic => 'spa_blm',
  };
}

/// The visual theme mode chosen by the user.
enum AppThemeMode {
  system,
  light,
  dark,
  sepia,
}

/// Persisted user preferences for the app.
///
/// Values are loaded once at startup via [load] and kept in memory while
/// running. Every setter persists immediately, so preferences survive
/// restarts without an explicit save step.
class UserPreferences {
  UserPreferences({
    this.fontSizeMultiplier = 1.0,
    this.translation = BibleTranslation.evangelical,
    this.themeMode = AppThemeMode.system,
    this.notificationsEnabled = true,
    this.notificationHour = 8,
    this.notificationMinute = 0,
    required this.prefs,
  });

  final SharedPreferences prefs;

  /// Scales the base biblical text size (18sp) to respect the user's
  /// preference. 1.0 means the default size.
  final double fontSizeMultiplier;

  /// Which canon the reading plan is built from.
  final BibleTranslation translation;

  /// The theme mode chosen by the user.
  final AppThemeMode themeMode;

  /// Master switch for the daily notification reminder.
  final bool notificationsEnabled;

  /// Hour (0-23) of the local time at which the daily reminder fires.
  final int notificationHour;

  /// Minute (0-59) of the local time at which the daily reminder fires.
  final int notificationMinute;

  /// Convenience accessor for the [TimeOfDay] form of the reminder time.
  TimeOfDay get notificationTime =>
      TimeOfDay(hour: notificationHour, minute: notificationMinute);

  /// The translation id understood by the Free Use Bible API.
  String get translationId => translation.translationId;

  UserPreferences copyWith({
    double? fontSizeMultiplier,
    BibleTranslation? translation,
    AppThemeMode? themeMode,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return UserPreferences(
      prefs: prefs,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      translation: translation ?? this.translation,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
    );
  }
}
