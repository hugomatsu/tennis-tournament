import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/app.dart';
import 'package:tennis_tournament/firebase_options.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Top-level handler for background FCM messages.
/// Must be a top-level function (not a class method) per Flutter/FCM requirements.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized (needed for background isolate)
  await Firebase.initializeApp();
  debugPrint('Background FCM message: ${message.notification?.title}');
  // In-app notifications are created server-side via Cloud Functions,
  // so no additional handling is needed here.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add Portuguese locale for timeago
  timeago.setLocaleMessages('pt', timeago.PtBrMessages());
  
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  final envFile = env == 'prod' ? 'assets/env.prod' : 'assets/env.dev';
  
  try {
    await dotenv.load(fileName: envFile);
  } catch (e) {
    // Fallback or error handling
    debugPrint('Error loading $envFile: $e');
    // Try loading default if specific not found, mostly for migration
    await dotenv.load(fileName: "assets/env"); 
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase may already be initialized on Android via google-services.json
    debugPrint('Firebase initialization: $e');
  }

  // Register background message handler for FCM push notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    const ProviderScope(
      child: TennisApp(),
    ),
  );
}
