import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/bible_theme.dart';

/// Top-level application shell with an editorial 4-tab bottom navigation bar:
/// 1. Inicio (/dashboard)
/// 2. Biblia (/explore)
/// 3. Guardados (/saved)
/// 4. Estudio (/study)
///
/// Implemented via [StatefulNavigationShell] so each tab preserves its
/// respective scroll position and view hierarchy independently.
class AppShellScreen extends StatelessWidget {
  const AppShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: readingStyle.surfaceColor,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          backgroundColor: readingStyle.surfaceColor,
          indicatorColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
              tooltip: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Biblia',
              tooltip: 'Explorar libros y capítulos',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: 'Guardados',
              tooltip: 'Favoritos, resaltados y notas',
            ),
            NavigationDestination(
              icon: Icon(Icons.hub_outlined),
              selectedIcon: Icon(Icons.hub_rounded),
              label: 'Estudio',
              tooltip: 'Red de conexiones y estudio',
            ),
          ],
        ),
      ),
    );
  }
}
