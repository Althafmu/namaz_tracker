import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/prayer.dart';

/// Segmented ring painter that shows prayer completion status.
/// Used in both the hero streak ring and calendar cell rings.
class StreakRingPainter extends CustomPainter {
  final List<Prayer> prayers;
  final double strokeWidth;
  final double gapAngle;

  StreakRingPainter({
    required this.prayers,
    this.strokeWidth = 8.0,
    this.gapAngle = 0.08,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prayers.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth - 2;

    final totalSegments = prayers.length;

    // If only one prayer, draw a full circle without gaps
    if (totalSegments == 1) {
      final prayer = prayers.first;
      Color segmentColor = AppColors.statusNotLogged;

      if (prayer.isCompleted) {
        if (prayer.status == 'late') {
          segmentColor = AppColors.statusLate;
        } else if (prayer.status == 'missed') {
          segmentColor = AppColors.statusMissed;
        } else {
          segmentColor = prayer.inJamaat
              ? AppColors.statusGroup
              : AppColors.statusAlone;
        }
      }

      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi,
        false,
        paint,
      );
      return;
    }

    final visualGap = gapAngle;
    final visibleSweep = (2 * pi / totalSegments) - visualGap;

    // The round caps stick out on both sides by strokeWidth / 2 mathematically (along the stroke).
    // The angle they occupy is approximately (strokeWidth / radius) radians total (both caps).
    final capAngle = strokeWidth / radius;
    // We must draw a shorter mathematical arc so visual length (sweep + caps) == visibleSweep
    final sweepAngle = max(0.0, visibleSweep - capAngle);

    double startAngle = -pi / 2; // Start from top

    for (int i = 0; i < totalSegments; i++) {
      final prayer = prayers[i];
      Color segmentColor = AppColors.statusNotLogged;

      if (prayer.isCompleted) {
        if (prayer.status == 'late') {
          segmentColor = AppColors.statusLate;
        } else if (prayer.status == 'missed') {
          segmentColor = AppColors.statusMissed;
        } else {
          segmentColor = prayer.inJamaat
              ? AppColors.statusGroup
              : AppColors.statusAlone;
        }
      }

      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Shift the actual drawn arc start point forward by capAngle / 2 so the visible round
      // cap begins exactly at 'startAngle' instead of sticking backwards into the gap space.
      final drawStart = startAngle + capAngle / 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        drawStart,
        sweepAngle,
        false,
        paint,
      );

      startAngle += visibleSweep + visualGap;
    }
  }

  @override
  bool shouldRepaint(covariant StreakRingPainter oldDelegate) => true;
}
