import 'dart:convert';

/// Represents a single day's reading assignment within a curated plan.
class ReadingPlanDay {
  final int dayNumber;
  final String title;
  final String bookId;
  final String bookName;
  final int chapter;
  final String theme;

  const ReadingPlanDay({
    required this.dayNumber,
    required this.title,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.theme,
  });

  /// Canonical reference string, e.g. "Salmos 23"
  String get reference => '$bookName $chapter';

  factory ReadingPlanDay.fromJson(Map<String, dynamic> json) {
    return ReadingPlanDay(
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String,
      bookId: json['bookId'] as String,
      bookName: json['bookName'] as String,
      chapter: json['chapter'] as int,
      theme: json['theme'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'title': title,
        'bookId': bookId,
        'bookName': bookName,
        'chapter': chapter,
        'theme': theme,
      };
}

/// Metadata and day definitions for a curated thematic reading plan.
class ReadingPlanDefinition {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final int durationDays;
  final String iconName;
  final String accentColorHex;
  final List<ReadingPlanDay> days;

  const ReadingPlanDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.durationDays,
    required this.iconName,
    required this.accentColorHex,
    required this.days,
  });

  ReadingPlanDay? getDay(int dayNumber) {
    for (final day in days) {
      if (day.dayNumber == dayNumber) return day;
    }
    return null;
  }

  factory ReadingPlanDefinition.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List<dynamic>? ?? [];
    return ReadingPlanDefinition(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      durationDays: json['durationDays'] as int? ?? rawDays.length,
      iconName: json['iconName'] as String? ?? 'auto_stories',
      accentColorHex: json['accentColorHex'] as String? ?? '#8B5E34',
      days: rawDays
          .map((d) => ReadingPlanDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'category': category,
        'durationDays': durationDays,
        'iconName': iconName,
        'accentColorHex': accentColorHex,
        'days': days.map((d) => d.toJson()).toList(),
      };
}

/// User's real-time progress state for a specific plan.
class ThematicPlanProgress {
  final String planId;
  final String status; // 'pending' | 'active' | 'completed'
  final int startedAtMs;
  final int? completedAtMs;
  final Set<int> completedDays;

  const ThematicPlanProgress({
    required this.planId,
    required this.status,
    required this.startedAtMs,
    this.completedAtMs,
    required this.completedDays,
  });

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';

  int get completedCount => completedDays.length;

  double fraction(int totalDays) {
    if (totalDays <= 0) return 0.0;
    return (completedDays.length / totalDays).clamp(0.0, 1.0);
  }

  double percentage(int totalDays) => fraction(totalDays) * 100;

  bool isDayCompleted(int dayNumber) => completedDays.contains(dayNumber);

  int? nextPendingDay(int totalDays) {
    for (int day = 1; day <= totalDays; day++) {
      if (!completedDays.contains(day)) return day;
    }
    return null;
  }

  ThematicPlanProgress copyWith({
    String? status,
    int? startedAtMs,
    int? completedAtMs,
    Set<int>? completedDays,
  }) {
    return ThematicPlanProgress(
      planId: planId,
      status: status ?? this.status,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      completedAtMs: completedAtMs ?? this.completedAtMs,
      completedDays: completedDays ?? this.completedDays,
    );
  }

  static Set<int> parseCompletedDaysJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.whereType<int>().toSet();
      }
    } catch (_) {}
    return <int>{};
  }

  static String encodeCompletedDays(Set<int> days) {
    final list = days.toList()..sort();
    return jsonEncode(list);
  }
}
