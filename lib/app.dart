import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/core/theme/app_theme.dart';
import 'package:tennis_tournament/core/widgets/scaffold_with_nav_bar.dart';
import 'package:tennis_tournament/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:tennis_tournament/features/admin/presentation/create_tournament_screen.dart';
import 'package:tennis_tournament/features/auth/data/auth_repository.dart';
import 'package:tennis_tournament/features/auth/presentation/login_screen.dart';
import 'package:tennis_tournament/features/auth/presentation/register_screen.dart';
import 'package:tennis_tournament/features/home/presentation/home_screen.dart';
import 'package:tennis_tournament/features/matches/presentation/schedule_screen.dart';
import 'package:tennis_tournament/features/players/presentation/edit_profile_screen.dart';
import 'package:tennis_tournament/features/players/presentation/profile_screen.dart';
import 'package:tennis_tournament/features/availability/presentation/availability_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/participant_management_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournament_detail_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournaments_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();


final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isAuthenticated = authState.asData?.value != null;

      final isLogin = state.uri.toString() == '/login';
      final isRegister = state.uri.toString() == '/register';

      if (isLoading || hasError) return null;

      if (!isAuthenticated && !isLogin && !isRegister) {
        return '/login';
      }

      if (isAuthenticated && (isLogin || isRegister)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
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
                    routes: [
                      GoRoute(
                        path: 'participants',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ParticipantManagementScreen(tournamentId: id);
                        },
                      ),
                    ],
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
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'availability',
                    builder: (context, state) => const AvailabilityScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'create-tournament',
            builder: (context, state) => const CreateTournamentScreen(),
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
