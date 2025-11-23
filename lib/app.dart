import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TennisApp extends ConsumerWidget {
  const TennisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Tennis Tournament Manager')),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Tennis Tournament Manager',
      theme: ThemeData.dark(useMaterial3: true),
      routerConfig: router,
    );
  }
}
