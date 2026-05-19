import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../one_punch_game.dart';

class BackgroundComponent extends Component with HasGameRef {
  final List<_Building> _farBuildings = [];
  final List<_Building> _midBuildings = [];
  final List<_Particle> _particles = [];
  double _elapsed = 0;

  @override
  Future<void> onLoad() async {
    final w = gameRef.size.x;
    final h = gameRef.size.y;
    final rng = Random(77);

    for (int i = 0; i < 12; i++) {
      _farBuildings.add(_Building(
        x: rng.nextDouble() * w,
        y: h * 0.60,
        width: 30 + rng.nextDouble() * 50,
        height: 60 + rng.nextDouble() * 100,
        speed: 60,
        color: const Color(0xFF0D0D1A),
        windowColor: const Color(0xFF1A3A6A),
        screenW: w,
        seed: i,
      ));
    }

    for (int i = 0; i < 8; i++) {
      _midBuildings.add(_Building(
        x: rng.nextDouble() * w,
        y: h * 0.68,
        width: 40 + rng.nextDouble() * 60,
        height: 80 + rng.nextDouble() * 120,
        speed: 160,
        color: const Color(0xFF111122),
        windowColor: const Color(0xFF2A2A5A),
        screenW: w,
        seed: i + 100,
      ));
    }

    for (int i = 0; i < 25; i++) {
      _particles.add(_Particle(
        x: rng.nextDouble() * w,
        y: h * 0.3 + rng.nextDouble() * h * 0.4,
        speed: 15 + rng.nextDouble() * 30,
        size: 1.0 + rng.nextDouble() * 2.0,
        color: rng.nextBool() ? const Color(0xFFFF6600) : const Color(0xFF4444AA),
        screenW: w,
      ));
    }
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    // 스테이지에 따라 배경 속도 동적 조정
    final stage = (gameRef as dynamic).currentStage as int? ?? 1;
    final speedMult = 1.0 + (stage * 0.04).clamp(0.0, 4.0);
    for (final b in _farBuildings) b.update(dt, speedMult * 0.3);
    for (final b in _midBuildings) b.update(dt, speedMult);
    for (final p in _particles) p.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final w = size.x;
    final h = size.y;

    // 하늘 그라디언트
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF020208),
          Color(0xFF0A0A1F),
          Color(0xFF12122E),
          Color(0xFF1A1230),
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 달
    final moonGlowPaint = Paint()
      ..color = const Color(0x22DDCCAA)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(Offset(w * 0.88, h * 0.14), 32, moonGlowPaint);
    final moonPaint = Paint()..color = const Color(0xFFDDCCAA);
    canvas.drawCircle(Offset(w * 0.88, h * 0.14), 22, moonPaint);

    // 별
    final rng = Random(42);
    for (int i = 0; i < 70; i++) {
      final sx = rng.nextDouble() * w;
      final sy = rng.nextDouble() * h * 0.55;
      final sr = 0.5 + rng.nextDouble() * 1.2;
      final twinkle = (sin(_elapsed * (1 + rng.nextDouble()) + i) + 1) / 2;
      canvas.drawCircle(
        Offset(sx, sy),
        sr,
        Paint()..color = Colors.white.withOpacity(0.3 + twinkle * 0.5),
      );
    }

    // 원거리 건물
    for (final b in _farBuildings) b.render(canvas, h);

    // 안개
    final fogPaint = Paint()
      ..color = const Color(0x33111133)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.45, w, h * 0.25), fogPaint);

    // 중거리 건물
    for (final b in _midBuildings) b.render(canvas, h);

    // 파티클
    for (final p in _particles) p.render(canvas);

    // 바닥 네온
    final neon1 = Paint()
      ..color = const Color(0x33E94560)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.73, w, 8), neon1);
    final neon2 = Paint()
      ..color = const Color(0x220F3460)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.75, w, 5), neon2);
  }

  @override
  int get priority => 0;
}

class _Building {
  double x;
  final double y;
  final double width;
  final double height;
  final double speed;
  final Color color;
  final Color windowColor;
  final double screenW;
  final Random _rng;

  _Building({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
    required this.color,
    required this.windowColor,
    required this.screenW,
    required int seed,
  }) : _rng = Random(seed);

  void update(double dt, [double mult = 1.0]) {
    x -= speed * mult * dt;
    if (x + width < 0) x = screenW + width;
  }

  void render(Canvas canvas, double screenH) {
    final top = y - height;
    canvas.drawRect(Rect.fromLTWH(x, top, width, height), Paint()..color = color);
    canvas.drawRect(
      Rect.fromLTWH(x, top, width, height),
      Paint()
        ..color = windowColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final winPaint = Paint()..color = windowColor.withOpacity(0.7);
    for (double wy = top + 8; wy < y - 8; wy += 14) {
      for (double wx = x + 5; wx < x + width - 8; wx += 12) {
        if (_rng.nextBool()) {
          canvas.drawRect(Rect.fromLTWH(wx, wy, 5, 6), winPaint);
        }
      }
    }
  }
}

class _Particle {
  double x;
  double y;
  final double speed;
  final double size;
  final Color color;
  final double screenW;
  double _life = 0;
  final double _maxLife;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.screenW,
  }) : _maxLife = 2.0 + Random().nextDouble() * 3.0;

  void update(double dt) {
    x -= speed * dt;
    y -= 6 * dt;
    _life += dt;
    if (_life >= _maxLife) {
      _life = 0;
      x = screenW + 10;
      y = 50 + Random().nextDouble() * 150;
    }
  }

  void render(Canvas canvas) {
    final alpha = (1.0 - (_life / _maxLife)).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(x, y),
      size,
      Paint()..color = color.withOpacity(alpha * 0.5),
    );
  }
}
