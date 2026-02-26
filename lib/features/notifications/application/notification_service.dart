import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/features/notifications/data/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;
  final String _userId;
  final GoRouter _router;

  NotificationService({
    required NotificationRepository repository,
    required String userId,
    required GoRouter router,
  })  : _repository = repository,
        _userId = userId,
        _router = router;

  Future<void> initialize() async {
    // Skip FCM setup on web (handled differently) or if not supported
    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS/macOS requires explicit request)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Notification permission denied');
      return;
    }

    // Get and save FCM token
    try {
      String? token;
      if (kIsWeb) {
        // For web, you need a VAPID key. Skip if not configured.
        // token = await messaging.getToken(vapidKey: 'YOUR_VAPID_KEY');
        debugPrint('Web FCM token retrieval skipped (VAPID key needed)');
      } else {
        token = await messaging.getToken();
      }

      if (token != null) {
        await _repository.saveFcmToken(_userId, token);
        debugPrint('FCM token saved: ${token.substring(0, 10)}...');
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // Listen for token refresh
    messaging.onTokenRefresh.listen((newToken) async {
      try {
        await _repository.saveFcmToken(_userId, newToken);
      } catch (e) {
        debugPrint('Error saving refreshed FCM token: $e');
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');
      // The in-app notification list will update automatically via Firestore stream
      // No need to show a local notification — the bell badge will increment
    });

    // Handle message tap when app is in background (but running)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageTap(message.data);
    });

    // Handle message tap when app was terminated (cold start)
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage.data);
    }
  }

  void _handleMessageTap(Map<String, dynamic> data) {
    final matchId = data['matchId'] as String?;
    final tournamentId = data['tournamentId'] as String?;

    if (matchId != null && matchId.isNotEmpty) {
      _router.push('/matches/$matchId');
    } else if (tournamentId != null && tournamentId.isNotEmpty) {
      _router.push('/tournaments/$tournamentId');
    }
  }
}
