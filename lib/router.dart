import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/app_providers.dart';
import 'screens/app_shell_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/reading_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/search_screen.dart';
import 'screens/study_screen.dart';
import 'services/reading_plan_service.dart';

/// Shared navigator key. Used by [NotificationService] to navigate from a
/// background tap without needing a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Immutable GoRouter provider for the application lifecycle.
final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _RouterRefreshListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: listenable,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'reading',
                    builder: (context, state) => const ReadingScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 1: Biblia (Exploración)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          // Branch 2: Guardados (Colección de estudio)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
          // Branch 3: Estudio (Grafo y conexiones)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/study',
                builder: (context, state) => const StudyScreen(),
              ),
            ],
          ),
        ],
      ),
      // Standalone Fullscreen Routes (hide the AppShell bottom navigation bar)
      GoRoute(
        path: '/reading',
        builder: (context, state) => const ReadingScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/plans',
        builder: (context, state) => const PlansScreen(),
      ),
    ],
    redirect: (context, state) {
      final prefsAsync = ref.read(sharedPreferencesProvider);
      if (!prefsAsync.hasValue) return null;

      final prefs = prefsAsync.requireValue;
      final hasInstallation = prefs.containsKey(
        ReadingPlanService.installationDateKey,
      );

      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!hasInstallation) {
        return isOnboarding ? null : '/onboarding';
      }

      if (isOnboarding) return '/dashboard';

      return null;
    },
  );
});

/// A [Listenable] that forwards notifications from a Riverpod provider
/// to GoRouter's refresh mechanism.
class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(Ref ref) {
    ref.listen<dynamic>(sharedPreferencesProvider, (_, _) => notifyListeners());
  }
}
