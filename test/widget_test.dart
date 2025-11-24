import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tennis_tournament/app.dart';
import 'package:tennis_tournament/features/matches/data/match_repository.dart';
import 'package:tennis_tournament/features/matches/data/mock_match_repository.dart';
import 'package:tennis_tournament/features/tournaments/data/mock_tournament_repository.dart';
import 'package:tennis_tournament/features/tournaments/data/tournament_repository.dart';

import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await mockNetworkImagesFor(() async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            matchRepositoryProvider.overrideWithValue(MockMatchRepository()),
            tournamentRepositoryProvider.overrideWithValue(MockTournamentRepository()),
          ],
          child: const TennisApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the dashboard is shown.
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });
}
