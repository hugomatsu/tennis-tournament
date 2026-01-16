import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for the ThemeMode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  // Key for local storage
  static const String key = 'theme_mode';
  
  @override
  ThemeMode build() {
    // Start with system, load async
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(key);
      if (savedTheme != null) {
        state = _parseThemeMode(savedTheme);
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  ThemeMode _parseThemeMode(String modeString) {
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == modeString,
      orElse: () => ThemeMode.system,
    );
  }
}
