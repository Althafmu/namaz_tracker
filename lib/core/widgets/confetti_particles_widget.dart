import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum ParticleShape { circle, square, triangle, cross, star }

class ConfettiParticle {
  Offset position;
  Offset velocity;
  double rotation;
  double rotationSpeed;
  double scale;
  Color color;
  ParticleShape shape;
  double life; // 1.0 down to 0.0

  ConfettiParticle({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.scale,
    required this.color,
    required this.shape,
    required this.life,
  });
}

class ConfettiController extends ChangeNotifier {
  Offset? _pendingBurstPosition;
  Offset? get pendingBurstPosition => _pendingBurstPosition;

  void burst({Offset? position}) {
    _pendingBurstPosition = position;
    notifyListeners();
  }

  void clear() {
    _pendingBurstPosition = null;
  }
}

class ConfettiParticlesWidget extends StatefulWidget {
  final ConfettiController controller;

  const ConfettiParticlesWidget({
    super.key,
    required this.controller,
  });

  @override
  State<ConfettiParticlesWidget> createState() => ConfettiParticlesState();
}

class ConfettiParticlesState extends State<ConfettiParticlesWidget>
    with SingleTickerProviderStateMixin {
  final List<ConfettiParticle> _particles = [];
  late final Ticker _ticker;
  final Random _random = Random();

  final List<Color> _neoColors = const [
    Color(0xFFFFDE59), // Yellow
    Color(0xFF38B6FF), // Blue
    Color(0xFFFF5757), // Red
    Color(0xFFFF914D), // Orange
    Color(0xFF7ED957), // Green
    Color(0xFFC77DFF), // Purple
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onBurstRequested);
    _ticker = createTicker(_updateParticles);
    _ticker.start();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onBurstRequested);
    _ticker.dispose();
    super.dispose();
  }

  void _onBurstRequested() {
    final pos = widget.controller.pendingBurstPosition;
    widget.controller.clear();
    _spawnBurst(pos);
  }

  void _spawnBurst(Offset? position) {
    if (!mounted) return;
    
    final Size size = MediaQuery.of(context).size;
    final double defaultX = position?.dx ?? size.width / 2;
    final double defaultY = position?.dy ?? size.height * 0.35; // slightly higher than center

    // Spawn 35-45 particles per burst
    final count = _random.nextInt(15) + 30;
    
    setState(() {
      for (int i = 0; i < count; i++) {
        // Random velocity vector
        final angle = _random.nextDouble() * 2 * pi;
        final speed = _random.nextDouble() * 12 + 4;
        final vx = cos(angle) * speed;
        // Tendency to shoot slightly upwards
        final vy = sin(angle) * speed - 3.0;

        _particles.add(
          ConfettiParticle(
            position: Offset(defaultX, defaultY),
            velocity: Offset(vx, vy),
            rotation: _random.nextDouble() * 2 * pi,
            rotationSpeed: (_random.nextDouble() - 0.5) * 0.3,
            scale: _random.nextDouble() * 8 + 6,
            color: _neoColors[_random.nextInt(_neoColors.length)],
            shape: ParticleShape.values[_random.nextInt(ParticleShape.values.length)],
            life: 1.0,
          ),
        );
      }
    });
  }

  void _updateParticles(Duration elapsed) {
    if (_particles.isEmpty) return;

    setState(() {
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        
        // Apply velocity & gravity
        p.position += p.velocity;
        p.velocity = Offset(p.velocity.dx * 0.98, p.velocity.dy * 0.98 + 0.3); // gravity + air resistance
        
        // Spin
        p.rotation += p.rotationSpeed;
        
        // Decay life
        p.life -= 0.02; // lasts about 50 frames (~0.8 seconds)
        
        if (p.life <= 0) {
          _particles.removeAt(i);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_particles.isEmpty) return const SizedBox.shrink();
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(particles: _particles),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFF2B2D42) // Border color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final p in particles) {
      final fillPaint = Paint()
        ..color = p.color.withValues(alpha: p.life)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.rotation);

      final r = p.scale;
      final path = Path();

      switch (p.shape) {
        case ParticleShape.circle:
          canvas.drawCircle(Offset.zero, r, fillPaint);
          canvas.drawCircle(Offset.zero, r, borderPaint..color = const Color(0xFF2B2D42).withValues(alpha: p.life));
          break;

        case ParticleShape.square:
          final rect = Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 2);
          canvas.drawRect(rect, fillPaint);
          canvas.drawRect(rect, borderPaint..color = const Color(0xFF2B2D42).withValues(alpha: p.life));
          break;

        case ParticleShape.triangle:
          path.moveTo(0, -r);
          path.lineTo(r, r);
          path.lineTo(-r, r);
          path.close();
          canvas.drawPath(path, fillPaint);
          canvas.drawPath(path, borderPaint..color = const Color(0xFF2B2D42).withValues(alpha: p.life));
          break;

        case ParticleShape.cross:
          final w = r * 0.4;
          path.moveTo(-r, -w);
          path.lineTo(-r, w);
          path.lineTo(-w, w);
          path.lineTo(-w, r);
          path.lineTo(w, r);
          path.lineTo(w, w);
          path.lineTo(r, w);
          path.lineTo(r, -w);
          path.lineTo(w, -w);
          path.lineTo(w, -r);
          path.lineTo(-w, -r);
          path.lineTo(-w, -w);
          path.close();
          canvas.drawPath(path, fillPaint);
          canvas.drawPath(path, borderPaint..color = const Color(0xFF2B2D42).withValues(alpha: p.life));
          break;

        case ParticleShape.star:
          for (int i = 0; i < 10; i++) {
            final angle = i * pi / 5 - pi / 2;
            final dist = (i % 2 == 0) ? r : r * 0.4;
            final x = dist * cos(angle);
            final y = dist * sin(angle);
            if (i == 0) {
              path.moveTo(x, y);
            } else {
              path.lineTo(x, y);
            }
          }
          path.close();
          canvas.drawPath(path, fillPaint);
          canvas.drawPath(path, borderPaint..color = const Color(0xFF2B2D42).withValues(alpha: p.life));
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return true; // Particles animate every frame
  }
}
