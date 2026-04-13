import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// The app's ThemeData with Neo-brutalist defaults.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.light.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.light.primary,
          secondary: AppColors.light.jamaat,
          tertiary: AppColors.light.streak,
          surface: AppColors.light.surface,
          onSurface: AppColors.light.textPrimary,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme().apply(
          bodyColor: AppColors.light.textPrimary,
          displayColor: AppColors.light.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.light.background,
          elevation: 0,
          centerTitle: false,
          foregroundColor: AppColors.light.textPrimary,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.light.surface,
          selectedItemColor: AppColors.light.primary,
          unselectedItemColor: AppColors.light.textSecondary,
          type: BottomNavigationBarType.fixed,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dark.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.dark.primary,
          secondary: AppColors.dark.jamaat,
          tertiary: AppColors.dark.streak,
          surface: AppColors.dark.surface,
          onSurface: AppColors.dark.textPrimary,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.dark.textPrimary,
          displayColor: AppColors.dark.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.dark.background,
          elevation: 0,
          centerTitle: false,
          foregroundColor: AppColors.dark.textPrimary,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.dark.surface,
          selectedItemColor: AppColors.dark.primary,
          unselectedItemColor: AppColors.dark.textSecondary,
          type: BottomNavigationBarType.fixed,
        ),
        dividerColor: AppColors.dark.border.withValues(alpha: 0.2),
      );
}
