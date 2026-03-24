import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// The app's ThemeData with Neo-brutalist defaults.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.jamaat,
          tertiary: AppColors.streak,
          surface: AppColors.surface,
          onSurface: AppColors.textDark,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          centerTitle: false,
          foregroundColor: AppColors.textDark,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.muted,
          type: BottomNavigationBarType.fixed,
        ),
      );
}
