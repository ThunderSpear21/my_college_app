import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colours.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.lightPrimary,
    cardColor: AppColors.lightCard,
    textTheme: GoogleFonts.concertOneTextTheme().copyWith(
      bodyLarge: const TextStyle(color: AppColors.lightText),
      bodyMedium: const TextStyle(color: AppColors.lightText),
      bodySmall: const TextStyle(color: AppColors.lightText),
      labelSmall: const TextStyle(color: AppColors.lightText),
      displaySmall: const TextStyle(color: AppColors.lightText),
      displayMedium: const TextStyle(color: AppColors.lightText),
      labelMedium: const TextStyle(color: AppColors.lightText),
      headlineMedium: const TextStyle(color: AppColors.lightText),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: GoogleFonts.concertOne(
        color: Colors.grey[600],
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightAccent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary, // universal background color
        foregroundColor: Colors.white, // text/icon color
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        elevation: 2,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkPrimary,
    cardColor: AppColors.darkCard,
    textTheme: GoogleFonts.concertOneTextTheme().copyWith(
      bodyLarge: const TextStyle(color: AppColors.darkText),
      bodyMedium: const TextStyle(color: AppColors.darkText),
      bodySmall: const TextStyle(color: AppColors.darkText),
      labelSmall: const TextStyle(color: AppColors.darkText),
      displaySmall: const TextStyle(color: AppColors.darkText),
      displayMedium: const TextStyle(color: AppColors.darkText),
      labelMedium: const TextStyle(color: AppColors.darkText),
      headlineMedium: const TextStyle(color: AppColors.darkText),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: GoogleFonts.concertOne(
        color: Colors.white60,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkAccent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkButton,
        foregroundColor: AppColors.darkButtonText,
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        elevation: 2,
      ),
    ),
  );
}
