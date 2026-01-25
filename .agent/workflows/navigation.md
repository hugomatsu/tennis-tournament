---
description: GoRouter navigation - enforces consistent navigation patterns with StatefulShellRoute
---

# Navigation Skill (GoRouter)

All navigation uses GoRouter with consistent patterns for deep linking and bottom navigation.

## Structure

All routes defined in `lib/app.dart`.

## Route Configuration

```dart
// app.dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Auth redirects
      final isAuthenticated = authState.asData?.value != null;
      final isAuthRoute = state.uri.toString() == '/login' || 
                          state.uri.toString() == '/register';
      
      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/tournaments';
      return null;
    },
    routes: [
      // Public routes
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      
      // Bottom nav shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tournaments',
              builder: (_, __) => const TournamentsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    return TournamentDetailScreen(id: state.pathParameters['id']!);
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/schedule', builder: (_, __) => const ScheduleScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
      
      // Modal/overlay routes
      GoRoute(path: '/subscription', builder: (_, __) => const SubscriptionScreen()),
    ],
  );
});
```

## Navigation Methods

| Method | Behavior | Use Case |
|--------|----------|----------|
| `context.go('/path')` | Replace current | Tab navigation, after login |
| `context.push('/path')` | Add to stack | Detail screens, modals |
| `context.pop()` | Go back | Close current screen |
| `context.pushReplacement('/path')` | Replace current in stack | Wizard step forward |

## Rules

### MUST DO
1. Define all routes in `app.dart`
2. Use `context.go()` for replacement navigation
3. Use `context.push()` for stacking screens
4. Use path parameters for IDs: `/:id`
5. Use `state.extra` for complex objects
6. Create short URL redirects for sharing

### MUST NOT
- Use Navigator.push directly
- Define routes outside app.dart
- Pass large objects via path (use extra)
- Forget to handle deep links

## Patterns

### Path Parameters
```dart
GoRoute(
  path: 'tournaments/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return TournamentDetailScreen(id: id);
  },
)

// Navigate
context.push('/tournaments/abc123');
```

### Passing Objects via Extra
```dart
GoRoute(
  path: 'manage-admins',
  builder: (context, state) {
    final tournament = state.extra as Tournament;
    return ManageAdminsScreen(tournament: tournament);
  },
)

// Navigate
context.push('/tournaments/$id/manage-admins', extra: tournament);
```

### Short URL Redirects
```dart
// Short shareable URL
GoRoute(
  path: '/t/:id',
  redirect: (context, state) {
    final id = state.pathParameters['id'];
    return '/tournaments/$id';
  },
)
```

### Nested Routes
```dart
GoRoute(
  path: '/tournaments',
  builder: (_, __) => const TournamentsScreen(),
  routes: [
    GoRoute(
      path: ':id',
      builder: (context, state) => TournamentDetailScreen(id: state.pathParameters['id']!),
      routes: [
        GoRoute(path: 'participants', builder: ...),
        GoRoute(path: 'schedule-settings', builder: ...),
      ],
    ),
  ],
)
```

## Bottom Navigation Shell

```dart
// core/widgets/scaffold_with_nav_bar.dart
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Tournaments'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```
