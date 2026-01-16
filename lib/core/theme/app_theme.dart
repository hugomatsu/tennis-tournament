import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6B8E23), // Olive Green (Tennis court inspired) - adjusted for contrast
      secondary: Color(0xFF2979FF),
      surface: Colors.white,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF6B8E23),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
    ),
     cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -1.0, color: Colors.black),
      displayMedium: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.black),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    dividerColor: Colors.grey[300],
  );

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
    dividerColor: Colors.grey[800],
  );
}
