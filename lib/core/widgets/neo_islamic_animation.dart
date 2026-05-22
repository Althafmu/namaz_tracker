import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NeoIslamicAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final bool animate;

  const NeoIslamicAnimation({
    super.key,
    this.size = 120,
    this.color,
    this.animate = true,
  });

  @override
  State<NeoIslamicAnimation> createState() => _NeoIslamicAnimationState();
}

class _NeoIslamicAnimationState extends State<NeoIslamicAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final themeColor = widget.color ?? colors.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _NeoIslamicPainter(
            rotation: _controller.value * 2 * pi,
            pulse: sin(_controller.value * 2 * pi * 2) * 0.08 + 1.0, // Breathing effect
            color: themeColor,
            borderColor: colors.border,
            shadowColor: const Color(0xFF2B2D42),
          ),
        );
      },
    );
  }
}

class _NeoIslamicPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final Color color;
  final Color borderColor;
  final Color shadowColor;

  _NeoIslamicPainter({
    required this.rotation,
    required this.pulse,
    required this.color,
    required this.borderColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) / 2.3;
    final starRadius = baseRadius * pulse;
    
    // 1. Create the path for the 8-pointed star (Rub el Hizb)
    final starPath = Path();
    final int points = 16;
    final double outerR = starRadius;
    // Perfect Rub el Hizb overlapping squares inner radius ratio
    final double innerR = starRadius * 0.7653; 

    for (int i = 0; i < points; i++) {
      final double angle = i * pi / 8 + rotation;
      final double r = (i % 2 == 0) ? outerR : innerR;
      final double x = center.dx + r * cos(angle);
      final double y = center.dy + r * sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    // Paints
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.miter;

    // 2. Draw Shadow for Star
    final shadowOffset = const Offset(4, 4);
    canvas.drawPath(starPath.shift(shadowOffset), shadowPaint);

    // 3. Draw Fill for Star
    canvas.drawPath(starPath, fillPaint);

    // 4. Draw Border for Star
    canvas.drawPath(starPath, borderPaint);

    // 5. Draw inner circle with border
    final innerCircleRadius = starRadius * 0.4;
    canvas.drawCircle(center + shadowOffset, innerCircleRadius, shadowPaint);
    canvas.drawCircle(center, innerCircleRadius, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(center, innerCircleRadius, borderPaint);

    // 6. Draw Crescent Moon inside the inner circle
    final crescentPath = Path();
    final double moonRadius = innerCircleRadius * 0.6;
    final double moonOffset = moonRadius * 0.35;
    
    // Outer arc of moon
    crescentPath.addArc(
      Rect.fromCircle(center: center, radius: moonRadius),
      -pi / 2,
      pi,
    );
    
    // Inner arc of moon
    crescentPath.arcTo(
      Rect.fromCircle(center: center + Offset(moonOffset, 0), radius: moonRadius * 0.95),
      pi / 2,
      -pi,
      false,
    );
    crescentPath.close();

    // Moon Shadow
    canvas.drawPath(crescentPath.shift(const Offset(1.5, 1.5)), shadowPaint);
    
    // Moon Fill & Border
    canvas.drawPath(crescentPath, Paint()..color = const Color(0xFFFFDE59)..style = PaintingStyle.fill); // Beautiful yellow moon
    canvas.drawPath(crescentPath, Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0);

    // 7. Draw a small decorative star next to the crescent
    final starX = center.dx + moonRadius * 0.3;
    final starY = center.dy - moonRadius * 0.3;
    _drawMiniStar(canvas, Offset(starX, starY), moonRadius * 0.25, borderPaint, shadowPaint);
  }

  void _drawMiniStar(Canvas canvas, Offset position, double radius, Paint borderPaint, Paint shadowPaint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = i * pi / 5 - pi / 2;
      final r = (i % 2 == 0) ? radius : radius * 0.4;
      final x = position.dx + r * cos(angle);
      final y = position.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Shadow
    canvas.drawPath(path.shift(const Offset(1, 1)), shadowPaint);
    // Fill
    canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.fill);
    // Border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _NeoIslamicPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
  }
}
