import 'package:flutter/material.dart';

/// Neo-brutalist design system colors extracted from Stitch mockups.
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFFFF6B6B);
  static const Color backgroundLight = Color(0xFFF4F1DE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2B2D42);
  static const Color muted = Color(0xFF8D99AE);

  // Accent colors
  static const Color accentFocus = Color(0xFFFFE66D);
  static const Color jamaat = Color(0xFF4ECDC4);
  static const Color streak = Color(0xFFF9C74F);

  // Neo-brutalist border color
  static const Color border = Color(0xFF2B2D42);

  // Status (Donut & Calendar Heatmap)
  static const Color success = Color(0xFF4ECDC4);
  static const Color error = Color(0xFFFF6B6B);
  static const Color statusGroup = Color(0xFF4ECDC4); // In Jamaat / Prayed (Female)
  static const Color statusAlone = Color(0xFFF9C74F); // Alone (Male) / Excused (Female)
  static const Color statusLate = Color(0xFFE07A5F); // Late
  static const Color statusMissed = Color(0xFFFF6B6B); // Missed
  static const Color statusNotLogged = Color(0xFFE2DADA); // Base gray ring or unlogged dots

  // Opacity helpers
  static Color primaryLight = primary.withValues(alpha: 0.1);
  static Color jamaatLight = jamaat.withValues(alpha: 0.2);
  static Color streakLight = streak.withValues(alpha: 0.2);
}
