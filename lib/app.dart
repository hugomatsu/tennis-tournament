import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/core/theme/app_theme.dart';
import 'package:tennis_tournament/core/widgets/scaffold_with_nav_bar.dart';
import 'package:tennis_tournament/features/home/presentation/home_screen.dart';
import 'package:tennis_tournament/features/matches/presentation/schedule_screen.dart';
import 'package:tennis_tournament/features/players/presentation/profile_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournament_detail_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournaments_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();


final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tournaments',
                builder: (context, state) => const TournamentsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return TournamentDetailScreen(id: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                builder: (context, state) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class TennisApp extends ConsumerWidget {
  const TennisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Tennis Tournament Manager',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
