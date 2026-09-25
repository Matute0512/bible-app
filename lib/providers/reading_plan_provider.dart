import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bible_chapter.dart';
import '../services/reading_plan_service.dart';
import 'bible_api_provider.dart';
import 'notification_provider.dart';
import 'shared_preferences_provider.dart';
import 'user_preferences_provider.dart';

final readingPlanProvider = Provider<ReadingPlanService>((ref) {
  final api = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return ReadingPlanService(api: api, prefs: prefs);
});

sealed class DailyReadingState {}

class LoadingPlan extends DailyReadingState {}

class Loaded extends DailyReadingState {
  Loaded({
    required this.plan,
    required this.currentIndex,
    required this.chapter,
  });

  final List<ReadingPlanEntry> plan;
  final int currentIndex;
  final BibleChapter chapter;
}

class FreeReadingLoaded extends DailyReadingState {
  FreeReadingLoaded({required this.chapter});

  final BibleChapter chapter;
}

class Navigating extends DailyReadingState {
  Navigating({required this.previousChapter, this.targetIndex, this.plan});

  final BibleChapter previousChapter;
  final int? targetIndex;
  final List<ReadingPlanEntry>? plan;
}

class DailyReadingError extends DailyReadingState {
  DailyReadingError({required this.message});

  final String message;
}

class DailyReadingNotifier extends AsyncNotifier<DailyReadingState> {
  @override
  Future<DailyReadingState> build() async {
    return _loadInitialState();
  }

  Future<DailyReadingState> _loadInitialState() async {
    try {
      // [FIX] Use ref.read (not ref.watch) inside non-build async method.
      // ref.watch here would register a persistent listener, causing double
      // rebuilds if userPreferencesProvider emits after the initial load.
      final userPrefs = await ref.read(userPreferencesProvider.future);
      final readingPlanService = ref.read(readingPlanProvider);
      final apiService = ref.read(apiServiceProvider);

      final plan = await readingPlanService.buildPlan(userPrefs.translation);

      // [FIX] Guard against an empty plan (e.g. API returns 0 books) to
      // prevent an IntegerDivisionByZeroException on `elapsed % plan.length`.
      if (plan.isEmpty) {
        return DailyReadingError(
          message: 'No se pudo construir el plan de lectura.',
        );
      }

      final elapsed = await readingPlanService.daysElapsed();
      final todayIndex = elapsed % plan.length;

      final entry = plan[todayIndex];
      final chapter = await apiService.fetchChapter(
        translationId: userPrefs.translationId,
        bookId: entry.bookId,
        bookName: entry.bookName,
        chapterNumber: entry.chapterNumber,
      );

      final loadedState = Loaded(
        plan: plan,
        currentIndex: todayIndex,
        chapter: chapter,
      );

      // Reschedule notification now that we have the plan.
      final notificationService = ref.read(notificationServiceProvider);
      if (userPrefs.notificationsEnabled) {
        final now = DateTime.now();
        final nowMinutes = now.hour * 60 + now.minute;
        final reminder = userPrefs.notificationTime;
        final reminderMinutes = reminder.hour * 60 + reminder.minute;

        final notificationIndex = nowMinutes >= reminderMinutes
            ? (todayIndex + 1) % plan.length
            : todayIndex;

        // [FIX] Renamed inner variable to avoid shadowing the outer `entry`.
        final notificationEntry = plan[notificationIndex];
        notificationService
            .scheduleDailyNotification(
              time: userPrefs.notificationTime,
              passageReference: notificationEntry.reference,
            )
            .catchError((Object e) {
          // Log scheduling errors instead of silently discarding them.
          debugPrint('[reading_plan] Notification scheduling failed: $e');
          return false;
        });
      }

      return loadedState;
    } catch (e) {
      return DailyReadingError(message: e.toString());
    }
  }

  Future<void> loadFreeChapter(
    String bookId,
    String bookName,
    int chapterNumber,
  ) async {
    final currentState = state.value;
    final previousChapter = (currentState is Loaded)
        ? currentState.chapter
        : (currentState is FreeReadingLoaded ? currentState.chapter : null);

    if (previousChapter != null) {
      state = AsyncData(Navigating(previousChapter: previousChapter));
    } else {
      state = AsyncData(LoadingPlan());
    }

    try {
      final userPrefs = await ref.read(userPreferencesProvider.future);
      final apiService = ref.read(apiServiceProvider);

      final newChapter = await apiService.fetchChapter(
        translationId: userPrefs.translationId,
        bookId: bookId,
        bookName: bookName,
        chapterNumber: chapterNumber,
      );

      state = AsyncData(FreeReadingLoaded(chapter: newChapter));
    } catch (e) {
      state = AsyncData(DailyReadingError(message: e.toString()));
    }
  }

  Future<void> goToChapter(int delta) async {
    final currentState = state.value;
    if (currentState is! Loaded) return;

    final nextIndex =
        (currentState.currentIndex + delta + currentState.plan.length) %
        currentState.plan.length;
    await goToPlanIndex(nextIndex);
  }

  Future<void> goToPlanIndex(int index) async {
    final currentState = state.value;
    if (currentState is! Loaded) return;

    // Emit navigating state
    state = AsyncData(
      Navigating(
        previousChapter: currentState.chapter,
        targetIndex: index,
        plan: currentState.plan,
      ),
    );

    try {
      final entry = currentState.plan[index];
      final userPrefs = await ref.read(userPreferencesProvider.future);
      final apiService = ref.read(apiServiceProvider);

      final newChapter = await apiService.fetchChapter(
        translationId: userPrefs.translationId,
        bookId: entry.bookId,
        bookName: entry.bookName,
        chapterNumber: entry.chapterNumber,
      );

      state = AsyncData(
        Loaded(
          plan: currentState.plan,
          currentIndex: index,
          chapter: newChapter,
        ),
      );
    } catch (e) {
      state = AsyncData(DailyReadingError(message: e.toString()));
    }
  }

  Future<bool> rescheduleNotification() async {
    final currentState = state.value;
    if (currentState is! Loaded) return false;

    final userPrefs = await ref.read(userPreferencesProvider.future);
    final notificationService = ref.read(notificationServiceProvider);

    if (!userPrefs.notificationsEnabled) {
      return false;
    }

    try {
      final now = DateTime.now();
      final nowMinutes = now.hour * 60 + now.minute;
      final reminder = userPrefs.notificationTime;
      final reminderMinutes = reminder.hour * 60 + reminder.minute;

      final index = nowMinutes >= reminderMinutes
          ? (currentState.currentIndex + 1) % currentState.plan.length
          : currentState.currentIndex;

      final entry = currentState.plan[index];

      return await notificationService.scheduleDailyNotification(
        time: userPrefs.notificationTime,
        passageReference: entry.reference,
      );
    } catch (e) {
      return false;
    }
  }
}

final dailyReadingProvider =
    AsyncNotifierProvider<DailyReadingNotifier, DailyReadingState>(
      DailyReadingNotifier.new,
    );
