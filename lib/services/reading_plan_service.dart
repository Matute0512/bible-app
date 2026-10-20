import 'package:shared_preferences/shared_preferences.dart';

import '../models/bible_book.dart';
import '../models/user_preferences.dart';
import 'bible_api_service.dart';

/// One step of the daily reading plan: a single chapter.
class ReadingPlanEntry {
  const ReadingPlanEntry({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
  });

  /// API id of the book (e.g. `LUK`).
  final String bookId;

  /// Display name of the book (e.g. `Lucas`).
  final String bookName;

  /// 1-based chapter number within the book.
  final int chapterNumber;

  /// Short reference for display and semantics, e.g. `Lucas 4`.
  String get reference => '$bookName $chapterNumber';
}

/// Builds and walks the daily reading plan.
///
/// The plan covers every chapter of the chosen canon in order. The chapter to
/// read on a given day is `daysElapsed % totalChapters`, where `daysElapsed`
/// is measured from the installation date, so the plan loops forever without
/// repeating a chapter on the same day across cycles.
class ReadingPlanService {
  ReadingPlanService({required this.api, required this.prefs});

  /// HTTP client for the Free Use Bible API.
  final BibleApiService api;

  /// Preferences store used to persist the installation date.
  final SharedPreferences prefs;

  /// SharedPreferences key holding the UTC installation timestamp.
  ///
  /// Exposed publicly so dependent components (e.g. the router's onboarding
  /// guard) can reference the same key without string duplication.
  static const String installationDateKey = 'installation_date_utc';

  /// The 66 book ids of the Protestant canon.
  static const Set<String> _protestantCanonBookIds = {
    'GEN',
    'EXO',
    'LEV',
    'NUM',
    'DEU',
    'JOS',
    'JDG',
    'RUT',
    '1SA',
    '2SA',
    '1KI',
    '2KI',
    '1CH',
    '2CH',
    'EZR',
    'NEH',
    'EST',
    'JOB',
    'PSA',
    'PRO',
    'ECC',
    'SNG',
    'ISA',
    'JER',
    'LAM',
    'EZK',
    'DAN',
    'HOS',
    'JOL',
    'AMO',
    'OBA',
    'JON',
    'MIC',
    'NAM',
    'HAB',
    'ZEP',
    'HAG',
    'ZEC',
    'MAL',
    'MAT',
    'MRK',
    'LUK',
    'JHN',
    'ACT',
    'ROM',
    '1CO',
    '2CO',
    'GAL',
    'EPH',
    'PHP',
    'COL',
    '1TH',
    '2TH',
    '1TI',
    '2TI',
    'TIT',
    'PHM',
    'HEB',
    'JAS',
    '1PE',
    '2PE',
    '1JN',
    '2JN',
    '3JN',
    'JUD',
    'REV',
  };

  /// The 7 deuterocanonical book ids of the Catholic canon.
  static const Set<String> _deuterocanonicalBookIds = {
    'TOB',
    'JDT',
    'WIS',
    'SIR',
    'BAR',
    '1MA',
    '2MA',
  };

  /// The 73 book ids of the standard Catholic canon.
  ///
  /// `spa_blm` serves 81 books; the 8 extra ones — Greek Esther (`ESG`),
  /// 3 and 4 Maccabees (`3MA`, `4MA`), 1 and 2 Esdras (`1ES`, `2ES`),
  /// Manasseh (`MAN`), Psalm 151 (`PS2`) and Greek Daniel (`DAG`) — fall
  /// outside the 73-book canon and must be filtered out.
  static const Set<String> catholicCanonBookIds = {
    ..._protestantCanonBookIds,
    ..._deuterocanonicalBookIds,
  };

  /// Returns the UTC date of the first launch, persisting it on first call.
  ///
  /// The installation date anchors the plan: every new user starts at
  /// Genesis 1 and reads one chapter per day from there.
  Future<DateTime> getInstallationDate() async {
    final stored = prefs.getString(installationDateKey);
    if (stored != null) {
      return DateTime.parse(stored).toUtc();
    }
    final now = DateTime.now().toUtc();
    await prefs.setString(installationDateKey, now.toIso8601String());
    return now;
  }

  /// Whether the installation date has been persisted (i.e. onboarding done).
  Future<bool> hasInstallationDate() async =>
      prefs.containsKey(installationDateKey);

  /// Number of whole days elapsed since installation (0 on day one).
  ///
  /// [now] is injectable for testing.
  Future<int> daysElapsed({DateTime? now}) async {
    final installationDate = await getInstallationDate();
    final reference = (now ?? DateTime.now()).toUtc();
    final days = reference.difference(installationDate).inDays;
    // [FIX] Clamp to 0: a device clock rollback or DST edge-case can produce
    // a negative value, which would cause `% plan.length` to throw a
    // RangeError when used as an index.
    return days < 0 ? 0 : days;
  }

  /// Builds the full reading plan for [translation].
  ///
  /// For the Catholic translation, books outside [catholicCanonBookIds] are
  /// dropped so the plan covers exactly the 73-book canon. The remaining
  /// books are ordered by their `order` field and flattened into one entry
  /// per chapter.
  Future<List<ReadingPlanEntry>> buildPlan(BibleTranslation translation) async {
    final books = await api.fetchBooks(translation.translationId);

    final canonical = translation == BibleTranslation.catholic
        ? books.where((b) => catholicCanonBookIds.contains(b.id)).toList()
        : List<BibleBook>.of(books);

    final ordered = List<BibleBook>.of(canonical)
      ..sort((a, b) => a.order.compareTo(b.order));

    return [
      for (final book in ordered)
        for (var chapter = 1; chapter <= book.chapterCount; chapter++)
          ReadingPlanEntry(
            bookId: book.id,
            bookName: book.name,
            chapterNumber: chapter,
          ),
    ];
  }

  /// Resolves the chapter to read today.
  ///
  /// Throws a [BibleApiException] when the plan cannot be built (no
  /// connectivity or an empty canon), so callers can reuse the same retry UI.
  Future<ReadingPlanEntry> chapterForToday(
    BibleTranslation translation, {
    DateTime? now,
  }) async => (await todayAndTomorrow(translation, now: now)).today;

  /// Resolves today's and tomorrow's chapters with a single plan build.
  ///
  /// Tomorrow's entry labels the scheduled daily notification, so the
  /// notification always advertises the passage the user is about to read.
  Future<({ReadingPlanEntry today, ReadingPlanEntry tomorrow})>
  todayAndTomorrow(BibleTranslation translation, {DateTime? now}) async {
    final plan = await buildPlan(translation);
    if (plan.isEmpty) {
      throw const BibleApiException(
        'No pudimos cargar el plan de lectura. Revisá tu conexión a internet.',
      );
    }
    final elapsed = await daysElapsed(now: now);
    return (
      today: plan[elapsed % plan.length],
      tomorrow: plan[(elapsed + 1) % plan.length],
    );
  }
}
