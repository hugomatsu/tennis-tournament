import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/app.dart';
import 'package:tennis_tournament/firebase_options.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  runApp(
    const ProviderScope(
      child: TennisApp(),
    ),
  );
}
