import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text styles using Space Grotesk from the Stitch mockups.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.spaceGrotesk(
        color: AppColors.textDark,
      );

  // Headlines
  static TextStyle get headlineLarge => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  // Prayer card title (uppercase, tracked)
  static TextStyle get prayerTitle => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      );

  // Body
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
      );

  // Section headers (uppercase, tracked)
  static TextStyle get sectionHeader => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: AppColors.muted,
      );

  // Bottom nav label
  static TextStyle get navLabel => _base.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      );

  // Badge / XP text
  static TextStyle get badge => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      );

  // Large number (streak display)
  static TextStyle get streakNumber => _base.copyWith(
        fontSize: 60,
        fontWeight: FontWeight.w700,
        height: 1.0,
      );
}
