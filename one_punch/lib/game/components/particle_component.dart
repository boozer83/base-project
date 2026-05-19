import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../one_punch_game.dart';

class ParticleComponent extends PositionComponent {
  final JudgeResult judge;
  final List<_Particle> _particles = [];
  double _lifeTimer = 0;
  static const _duration = 0.8;

  ParticleComponent({required Vector2 position, required this.judge})
      : super(position: position) {
    _spawnParticles();
  }

  void _spawnParticles() {
    final rng = Random();
    final color = _judgeColor();
    final count = judge == JudgeResult.perfect ? 20 : judge == JudgeResult.great ? 14 : 8;

    for (int i = 0; i < count; i++) {
      final angle  = rng.nextDouble() * pi * 2;
      final speed  = rng.nextDouble() * 150 + 60;
      final radius = rng.nextDouble() * 6 + 3;
      _particles.add(_Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 80,
        radius: radius,
        color: Color.lerp(color, Colors.white, rng.nextDouble() * 0.4)!,
        rotSpeed: (rng.nextDouble() - 0.5) * 6,
      ));
    }

    // PERFECT일 때 충격파 링 추가
    if (judge == JudgeResult.perfect) {
      for (int i = 0; i < 3; i++) {
        _particles.add(_Particle.ring(
          radius: 10.0 + i * 8,
          expandSpeed: 180 + i * 40,
          color: AppColors.gold,
        ));
      }
    }
  }

  Color _judgeColor() {
    switch (judge) {
      case JudgeResult.perfect: return AppColors.perfect;
      case JudgeResult.great:   return AppColors.great;
      case JudgeResult.good:    return AppColors.good;
      default:                  return AppColors.miss;
    }
  }

  @override
  void update(double dt) {
    _lifeTimer += dt;
    if (_lifeTimer >= _duration) {
      removeFromParent();
      return;
    }

    final progress = _lifeTimer / _duration;
    for (final p in _particles) {
      p.update(dt, progress);
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _lifeTimer / _duration;
    for (final p in _particles) {
      p.render(canvas, progress);
    }
  }

  @override
  int get priority => 15;
}

class _Particle {
  double x = 0, y = 0;
  double vx, vy;
  double radius;
  Color color;
  double rotSpeed;
  double rotation = 0;
  bool isRing;
  double expandSpeed;

  _Particle({
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
    required this.rotSpeed,
    this.isRing = false,
    this.expandSpeed = 0,
  });

  factory _Particle.ring({
    required double radius,
    required double expandSpeed,
    required Color color,
  }) {
    return _Particle(
      vx: 0, vy: 0,
      radius: radius,
      color: color,
      rotSpeed: 0,
      isRing: true,
      expandSpeed: expandSpeed,
    );
  }

  void update(double dt, double progress) {
    if (!isRing) {
      x  += vx * dt;
      y  += vy * dt;
      vy += 300 * dt; // 중력
      rotation += rotSpeed * dt;
    } else {
      radius += expandSpeed * dt;
    }
  }

  void render(Canvas canvas, double progress) {
    final opacity = (1 - progress).clamp(0.0, 1.0);
    final paint = Paint()..color = color.withOpacity(opacity);

    if (isRing) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1 - progress) * 4;
      canvas.drawCircle(Offset(x, y), radius, paint);
    } else {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-radius, -radius, radius * 2, radius * 2),
          Radius.circular(radius * 0.3),
        ),
        paint,
      );
      canvas.restore();
    }
  }
}
