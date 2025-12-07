import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: Colors.green[700],
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(secondary: Colors.orangeAccent),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(backgroundColor: Colors.green[700], elevation: 2, titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, height: 1.4),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.symmetric(horizontal:12, vertical:10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.symmetric(horizontal:18, vertical:12), backgroundColor: Colors.green[700])),
  );
}
