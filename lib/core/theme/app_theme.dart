import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7FAFA),
      primaryColor: const Color(0xFF008C8C),
      fontFamily: 'Cairo',

      colorScheme: const ColorScheme.light(
        primary: Color(0xFF008C8C),
        secondary: Color(0xFFFF8A1F),
        surface: Color(0xFFFFFFFF),
        error: Color(0xFFE54848),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF172124),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF172124),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF172124)),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE1EEEE), width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE7F0F0),
        thickness: 1,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF172124)),
        bodyMedium: TextStyle(color: Color(0xFF172124)),
        titleLarge: TextStyle(color: Color(0xFF172124)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF008C8C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF101718),
      primaryColor: const Color(0xFF20B8B8),
      fontFamily: 'Cairo',

      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF20B8B8),
        secondary: Color(0xFFFFA64D),
        surface: Color(0xFF172224),
        error: Color(0xFFE54848),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF172224),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1D2B2D),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2E4245), width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF263A3D),
        thickness: 1,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF20B8B8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
