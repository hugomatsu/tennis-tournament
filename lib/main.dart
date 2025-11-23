import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TennisApp(),
    ),
  );
}
