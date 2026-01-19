import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final Color color;
  final int numberOfParticles;
  final Widget? child;

  const ParticleBackground({
    super.key,
    required this.color,
    this.numberOfParticles = 30,
    this.child,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    _particles = List.generate(widget.numberOfParticles, (index) {
      return _Particle(
        position: Offset(
          _random.nextDouble(), // 0.0 to 1.0 (normalized)
          _random.nextDouble(),
        ),
        speed: _random.nextDouble() * 0.2 + 0.05,
        theta: _random.nextDouble() * 2 * pi,
        radius: _random.nextDouble() * 30 + 10,
        opacity: _random.nextDouble() * 0.3 + 0.1,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                color: widget.color,
                animValue: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Particle {
  Offset position;
  double speed;
  double theta;
  double radius;
  double opacity;

  _Particle({
    required this.position,
    required this.speed,
    required this.theta,
    required this.radius,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final double animValue;

  _ParticlePainter({
    required this.particles,
    required this.color,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Move particle
      double dx = cos(particle.theta) * particle.speed * 0.005;
      double dy = sin(particle.theta) * particle.speed * 0.005;

      particle.position += Offset(dx, dy);

      // Wrap around screen
      if (particle.position.dx < 0) particle.position += const Offset(1, 0);
      if (particle.position.dx > 1) particle.position -= const Offset(1, 0);
      if (particle.position.dy < 0) particle.position += const Offset(0, 1);
      if (particle.position.dy > 1) particle.position -= const Offset(0, 1);

      // Draw
      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      // Absolute coordinates
      final center = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );

      // Pulse effect based on animation value
      final pulse = sin(animValue * 2 * pi + particle.radius) * 0.1 + 0.9;

      canvas.drawCircle(center, particle.radius * pulse, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
