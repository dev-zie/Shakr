import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary400,
      surface: AppColors.backgroundLight,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimaryLight, size: 24),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryLight,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      showCheckmark: false,
      backgroundColor: AppColors.primary50,
      selectedColor: AppColors.primary,
      labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary300,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimaryDark, size: 24),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryDark,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1, color: Colors.white),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5, color: Colors.white),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      titleSmall: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      showCheckmark: false,
      backgroundColor: AppColors.primary900,
      selectedColor: AppColors.primary,
      labelStyle: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w600),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
    ),
  );
}