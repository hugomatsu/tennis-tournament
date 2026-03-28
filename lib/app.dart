import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/core/theme/app_theme.dart';
import 'package:tennis_tournament/core/theme/theme_provider.dart';
import 'package:tennis_tournament/core/widgets/scaffold_with_nav_bar.dart';
import 'package:tennis_tournament/features/admin/presentation/create_tournament_screen.dart';
import 'package:tennis_tournament/features/locations/presentation/location_management_screen.dart';
import 'package:tennis_tournament/features/auth/data/auth_repository.dart';
import 'package:tennis_tournament/features/auth/presentation/login_screen.dart';
import 'package:tennis_tournament/features/auth/presentation/register_screen.dart';

import 'package:tennis_tournament/features/matches/presentation/schedule_screen.dart';
import 'package:tennis_tournament/features/matches/presentation/match_detail_screen.dart';
import 'package:tennis_tournament/features/players/presentation/edit_profile_screen.dart';
import 'package:tennis_tournament/features/players/presentation/profile_screen.dart';
import 'package:tennis_tournament/features/players/presentation/player_profile_screen.dart';
import 'package:tennis_tournament/features/players/presentation/privacy_policy_screen.dart';
import 'package:tennis_tournament/features/media/presentation/media_library_screen.dart';
import 'package:tennis_tournament/features/availability/presentation/availability_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/participant_management_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournament_detail_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/schedule_settings_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/tournaments_screen.dart';
import 'package:tennis_tournament/features/tournaments/presentation/manage_admins_screen.dart';
import 'package:tennis_tournament/features/monetization/presentation/subscription_screen.dart';
import 'package:tennis_tournament/features/tournaments/domain/tournament.dart';
import 'package:tennis_tournament/features/debug/presentation/simulation_screen.dart';
import 'package:tennis_tournament/features/score/presentation/score_counter_screen.dart';

import 'package:tennis_tournament/features/home/presentation/help_screen.dart';
import 'package:tennis_tournament/features/splash/presentation/splash_screen.dart';
import 'package:tennis_tournament/features/notifications/presentation/notifications_screen.dart';
import 'package:tennis_tournament/features/notifications/presentation/notification_settings_screen.dart';
import 'package:tennis_tournament/features/notifications/application/notification_providers.dart';

import 'package:tennis_tournament/core/analytics/analytics_service.dart';
import 'package:tennis_tournament/features/tutorial/presentation/welcome_screen.dart';
import 'package:tennis_tournament/features/tutorial/data/tutorial_repository.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: [ref.watch(analyticsServiceProvider).observer],
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isAuthenticated = authState.asData?.value != null;

      final isSplash = state.uri.toString() == '/splash';
      if (isSplash) return null;

      final path = state.uri.toString();
      final isLogin = path == '/login';
      final isRegister = path == '/register';
      final isWelcome = path == '/welcome';

      if (isLoading || hasError) return null;

      if (!isAuthenticated && !isLogin && !isRegister) {
        return '/login';
      }

      if (isAuthenticated && isWelcome) {
        return null; // Let them stay on welcome
      }

      if (isAuthenticated && (isLogin || isRegister)) {
        // Check if welcome screen has been seen; if not, show it first
        final welcomeSeen = await TutorialRepository().isWelcomeSeen();
        if (!welcomeSeen) {
          return '/welcome';
        }
        return '/tournaments';
      }

      return null;
    },
    routes: [
      GoRoute(
        name: 'SplashScreen',
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: 'LoginScreen',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: 'RegisterScreen',
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: 'WelcomeScreen',
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'TournamentsScreen',
                path: '/tournaments',
                builder: (context, state) => const TournamentsScreen(),
                routes: [
                  GoRoute(
                    name: 'TournamentDetailScreen',
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return TournamentDetailScreen(id: id);
                    },
                    routes: [
                      GoRoute(
                        name: 'ParticipantManagementScreen',
                        path: 'participants',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ParticipantManagementScreen(tournamentId: id);
                        },
                      ),
                      GoRoute(
                        name: 'ScheduleSettingsScreen',
                        path: 'schedule-settings',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ScheduleSettingsScreen(tournamentId: id);
                        },
                      ),
                      GoRoute(
                        name: 'ManageAdminsScreen',
                        path: 'manage-admins',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          // We need the tournament object or fetch it. 
                          // Since we are traversing, we might not have it passed easily.
                          // It's better if the screen fetches it or we pass it via extra.
                          // For now, let's fetch it in the screen or pass via extra. 
                          // The screen I wrote takes `Tournament`. 
                          // Let's change the screen to take ID and fetch it? Or pass properties?
                          // Standardize: Screen takes ID and refetches or we pass extra. 
                          // Let's pass extra for now as it is eager.
                          final tournament = state.extra as Tournament; 
                          return ManageAdminsScreen(tournament: tournament);
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
                name: 'ScheduleScreen',
                path: '/schedule',
                builder: (context, state) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'ScoreCounterScreen',
                path: '/score',
                builder: (context, state) => const ScoreCounterScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'ProfileScreen',
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    name: 'EditProfileScreen',
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    name: 'AvailabilityScreen',
                    path: 'availability',
                    builder: (context, state) => const AvailabilityScreen(),
                  ),
                  GoRoute(
                    name: 'PrivacyPolicyScreen',
                    path: 'privacy',
                    builder: (context, state) => const PrivacyPolicyScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        name: 'SubscriptionScreen',
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        name: 'CreateTournamentScreen',
        path: '/admin/create-tournament',
        builder: (context, state) => const CreateTournamentScreen(),
      ),
      GoRoute(
        name: 'SimulationScreen',
        path: '/admin/simulation',
        builder: (context, state) => const SimulationScreen(),
      ),
      GoRoute(
        name: 'LocationManagementScreen',
        path: '/admin/locations',
        builder: (context, state) => const LocationManagementScreen(),
      ),
      GoRoute(
        name: 'MediaLibraryScreen',
        path: '/media-library',
        builder: (context, state) => const MediaLibraryScreen(),
      ),
      GoRoute(
        name: 'MatchDetailScreen',
        path: '/matches/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MatchDetailScreen(matchId: id);
        },
      ),
      GoRoute(
        name: 'HelpScreen',
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        name: 'NotificationsScreen',
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
        routes: [
          GoRoute(
            name: 'NotificationSettingsScreen',
            path: 'settings',
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        name: 'PlayerProfileScreen',
        path: '/players/:id',
        builder: (context, state) {
           final id = state.pathParameters['id']!;
           return PlayerProfileScreen(playerId: id);
        },
      ),
      GoRoute(
        name: 'TournamentDynamicLinkRedirect',
        path: '/t/:id',
        redirect: (context, state) {
          final id = state.pathParameters['id'];
          return '/tournaments/$id';
        },
      ),
    ],
  );
});



class TennisApp extends ConsumerWidget {
  const TennisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Eagerly initialize FCM push notifications when user is authenticated
    ref.watch(notificationServiceProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ColoredBox(
          color: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFD6D6D6),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child!,
            ),
          ),
        );
      },
    );
  }
}
