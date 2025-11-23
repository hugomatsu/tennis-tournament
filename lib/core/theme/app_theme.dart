import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFCCFF00), // Tennis Ball Neon
      secondary: Color(0xFF2979FF), // Electric Blue
      surface: Color(0xFF1E1E1E),

      onPrimary: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFFCCFF00),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E).withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -1.0),
      displayMedium: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}
