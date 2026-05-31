import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../features/challenges/presentation/challenges_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../widgets/app_shell.dart';

/// Definicja nawigacji aplikacji.
///
/// Używamy [StatefulShellRoute] z czterema gałęziami (zakładkami), aby każda
/// zakładka zachowywała swój stan przy przełączaniu (np. pozycję na mapie).
final class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: HomeScreen.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: HomeScreen.path,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MapScreen.path,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ChallengesScreen.path,
                builder: (context, state) => const ChallengesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProfileScreen.path,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context).notFound(state.uri.toString())),
      ),
    ),
  );
}
