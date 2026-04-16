import 'package:flutter/material.dart';

/// Neo-brutalist design system colors.
///
/// Static constants remain available for default values in const constructors.
/// For theme-aware usage, use `AppColors.of(context)` which returns the
/// appropriate palette based on the current brightness.
class AppColors {
  AppColors._();

  // ── Semantic accessors (theme-aware) ──

  /// Returns a theme-aware color palette based on the current brightness.
  static AppColorPalette of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }

  /// Light theme color palette.
  static const light = AppColorPalette(
    primary: Color(0xFFFF6B6B),
    background: Color(0xFFF4F1DE),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF2B2D42),
    textSecondary: Color(0xFF8D99AE),
    border: Color(0xFF2B2D42),
    accentFocus: Color(0xFFFFE66D),
    jamaat: Color(0xFF4ECDC4),
    streak: Color(0xFFF9C74F),
    success: Color(0xFF4ECDC4),
    error: Color(0xFFFF6B6B),
    statusGroup: Color(0xFF4ECDC4),
    statusAlone: Color(0xFFF9C74F),
    statusLate: Color(0xFFF4845F),
    statusMissed: Color(0xFFFF6B6B),
    statusQada: Color(0xFF6366F1), // Phase 2: Qada (makeup prayer) - Indigo
    statusExcused: Color(0xFF9CA3AF), // Phase 2: Excused - Muted gray
    statusNotLogged: Color(0xFFE2DADA),
  );

  /// Dark theme color palette.
  static const dark = AppColorPalette(
    // ── Surfaces ──
    // True black base for OLED screens; surface lifted just enough
    // to see NeoCard edges without competing with accent colors.
    primary: Color(0xFFFF8585), // Slightly softer red – easier on dark bg
    background: Color(0xFF121218), // Near-black with a hint of indigo
    surface: Color(0xFF1E1E2A), // Elevated cards – visible against bg
    // ── Typography ──
    textPrimary: Color(
      0xFFE8E6DF,
    ), // Warm off-white, matches light theme warmth
    textSecondary: Color(0xFF7A839A), // Dimmed slate – won't wash out
    // ── Neo-brutalist structure ──
    // Border is the most critical color: it drives card/button outlines
    // AND the solid 4px drop-shadows. Must be visible yet not blinding.
    border: Color(0xFF3D3D52), // Muted slate – visible shadow on #121218
    // ── Accent / Brand ──
    accentFocus: Color(0xFFFFE066), // Slightly toned-down gold
    jamaat: Color(0xFF5AD8CF), // Brighter teal pops on dark surface
    streak: Color(0xFFFACC4D), // Warm gold – streak banner
    success: Color(0xFF5AD8CF), // Matches jamaat for consistency
    error: Color(0xFFFF8585), // Matches primary
    // ── Status ring / heatmap colors ──
    // Slightly desaturated so they glow instead of burn on dark bg.
    statusGroup: Color(0xFF5AD8CF), // Jamaat / prayed
    statusAlone: Color(0xFFFACC4D), // Alone
    statusLate: Color(0xFFF0825A), // Orange-red
    statusMissed: Color(0xFFFF8585), // Softer red
    statusQada: Color(0xFF818CF8), // Phase 2: Qada - Lighter indigo for dark theme
    statusExcused: Color(0xFF9CA3AF), // Phase 2: Excused - Muted gray for dark theme
    statusNotLogged: Color(0xFF2A2A3A), // Subtle ring – blends into surface
  );

  // ── Legacy static constants (kept for const constructor defaults) ──

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
  static const Color statusGroup = Color(
    0xFF4ECDC4,
  ); // In Jamaat / Prayed (Female)
  static const Color statusAlone = Color(
    0xFFF9C74F,
  ); // Alone (Male) / Excused (Female)
  static const Color statusLate = Color(0xFFF4845F); // Late
  static const Color statusMissed = Color(0xFFFF6B6B); // Missed
  static const Color statusQada = Color(0xFF6366F1); // Phase 2: Qada
  static const Color statusExcused = Color(0xFF9CA3AF); // Phase 2: Excused
  static const Color statusNotLogged = Color(
    0xFFE2DADA,
  ); // Base gray ring or unlogged dots

  // Opacity helpers
  static Color primaryLight = primary.withValues(alpha: 0.1);
  static Color jamaatLight = jamaat.withValues(alpha: 0.2);
  static Color streakLight = streak.withValues(alpha: 0.2);
}

/// An immutable bundle of colors that adapts to light / dark mode.
class AppColorPalette {
  final Color primary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color accentFocus;
  final Color jamaat;
  final Color streak;
  final Color success;
  final Color error;
  final Color statusGroup;
  final Color statusAlone;
  final Color statusLate;
  final Color statusMissed;
  final Color statusQada; // Phase 2: Qada (makeup prayer)
  final Color statusExcused; // Phase 2: Excused (travel/sickness/women's period)
  final Color statusNotLogged;

  const AppColorPalette({
    required this.primary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.accentFocus,
    required this.jamaat,
    required this.streak,
    required this.success,
    required this.error,
    required this.statusGroup,
    required this.statusAlone,
    required this.statusLate,
    required this.statusMissed,
    required this.statusQada,
    required this.statusExcused,
    required this.statusNotLogged,
  });

  // Convenience getters matching old API names or expected semantic names
  Color get primaryLight => primary.withValues(alpha: 0.1);
  Color get jamaatLight => jamaat.withValues(alpha: 0.2);
  Color get streakLight => streak.withValues(alpha: 0.2);

  /// Text/icon color for use on accent-colored backgrounds (streak gold,
  /// jamaat teal, accent-focus yellow). Always dark for contrast on bright
  /// surfaces in both light and dark themes.
  Color get onAccent => const Color(0xFF2B2D42);

  /// Neutral color for toggle inactive state and similar "off" UI elements.
  /// Not alarming — distinct from accent colors but clearly "off".
  Color get inactive => const Color(0xFFB0B3C6);

  Color get statusOnTime => success;
  Color get statusNight => const Color(0xFF6366F1);
  Color get borderPrimary => border;
}
