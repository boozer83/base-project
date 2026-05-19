import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class WallComponent extends PositionComponent with HasGameRef {
  final WallType wallType;
  int hp;
  final int maxHp;
  final double speed;

  double _crackProgress = 0;
  double _shakeX = 0;
  double _flashTimer = 0;
  bool _isDestroyed = false;
  double _elapsed = 0;

  WallComponent({
    required this.wallType,
    required this.hp,
    required this.speed,
    required Vector2 gameSize,
  })  : maxHp = hp,
        super(
          size: Vector2(70, gameSize.y * 0.52),
          position: Vector2(
            gameSize.x + 20,
            gameSize.y * 0.75 - gameSize.y * 0.52,
          ),
        );

  @override
  void update(double dt) {
    if (_isDestroyed) return;
    _elapsed += dt;
    position.x -= speed * dt;
    _shakeX *= 0.75;
    if (_flashTimer > 0) _flashTimer -= dt;
  }

  @override
  void render(Canvas canvas) {
    if (_isDestroyed) return;

    final wallColor = _wallColor();
    final sx = _shakeX;

    // ── 그림자 ────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(sx + 6, 6, size.x, size.y),
      Paint()..color = Colors.black.withOpacity(0.4),
    );

    // ── 벽 본체 ────────────────────────────────────
    final bodyColor = _flashTimer > 0
        ? Color.lerp(wallColor, Colors.white, _flashTimer * 3)!
        : wallColor;

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          bodyColor.withOpacity(0.8),
          bodyColor,
          bodyColor.withOpacity(0.7),
        ],
      ).createShader(Rect.fromLTWH(sx, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(sx, 0, size.x, size.y), bodyPaint);

    // ── 벽돌 패턴 ─────────────────────────────────
    _drawBrickPattern(canvas, sx);

    // ── 균열 ──────────────────────────────────────
    if (_crackProgress > 0.1) _drawCracks(canvas, sx);

    // ── 테두리 글로우 ──────────────────────────────
    _drawGlow(canvas, sx, wallColor);

    // ── HP 바 ──────────────────────────────────────
    _drawHpBar(canvas, sx);

    // ── 아이콘 ────────────────────────────────────
    _drawWallIcon(canvas, sx);

    // ── 경고 펄스 ──────────────────────────────────
    if (position.x < gameRef.size.x * 0.5) {
      _drawWarningPulse(canvas, sx, wallColor);
    }
  }

  void _drawBrickPattern(Canvas canvas, double sx) {
    final brickPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const bH = 18.0;
    const bW = 32.0;
    for (double y = 0; y < size.y; y += bH) {
      final off = (y ~/ bH % 2 == 0) ? 0.0 : bW / 2;
      for (double x = -off; x < size.x; x += bW) {
        canvas.drawRect(Rect.fromLTWH(x + sx, y, bW, bH), brickPaint);
      }
    }
  }

  void _drawCracks(Canvas canvas, double sx) {
    final rng = Random(99);
    final crackPaint = Paint()
      ..color = Colors.black.withOpacity(0.7 * _crackProgress)
      ..strokeWidth = _crackProgress * 2.5
      ..style = PaintingStyle.stroke;

    final cx = size.x / 2 + sx;
    final cy = size.y / 2;
    final count = (8 * _crackProgress).toInt() + 3;

    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * pi * 2;
      final length = 15 + rng.nextDouble() * 35 * _crackProgress;
      final path = Path();
      path.moveTo(cx, cy);
      double x = cx, y = cy;
      for (int j = 0; j < 5; j++) {
        final segLen = length / 5;
        final jitter = (rng.nextDouble() - 0.5) * 0.3;
        x += cos(angle + jitter) * segLen;
        y += sin(angle + jitter) * segLen;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, crackPaint);
    }

    // 깨지는 파편 (70% 이상)
    if (_crackProgress > 0.7) {
      final fragPaint = Paint()..color = _wallColor().withOpacity(0.6);
      for (int i = 0; i < 6; i++) {
        final angle = i * pi / 3;
        final dist = 20 * (_crackProgress - 0.7) / 0.3;
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(cx + cos(angle) * dist, cy + sin(angle) * dist),
            width: 8,
            height: 8,
          ),
          fragPaint,
        );
      }
    }
  }

  void _drawGlow(Canvas canvas, double sx, Color wallColor) {
    final glowPaint = Paint()
      ..color = wallColor.withOpacity(0.3 + sin(_elapsed * 3) * 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRect(Rect.fromLTWH(sx, 0, size.x, size.y), glowPaint);
  }

  void _drawHpBar(Canvas canvas, double sx) {
    const barH = 8.0;
    const padH = 5.0;
    const barY = -barH - 8;
    final ratio = (hp / maxHp).clamp(0.0, 1.0);
    final barW = size.x - padH * 2;

    // 배경
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sx + padH, barY, barW, barH),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black.withOpacity(0.7),
    );

    // HP
    if (ratio > 0) {
      final hpColor = Color.lerp(Colors.red, const Color(0xFF00E676), ratio)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx + padH, barY, barW * ratio, barH),
          const Radius.circular(4),
        ),
        Paint()..color = hpColor,
      );
      // HP 글로우
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(sx + padH, barY, barW * ratio, barH),
          const Radius.circular(4),
        ),
        Paint()
          ..color = hpColor.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // HP 수치
    final tp = TextPainter(
      text: TextSpan(
        text: '$hp',
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(sx + size.x / 2 - tp.width / 2, barY - tp.height - 2));
  }

  void _drawWallIcon(Canvas canvas, double sx) {
    final label = _wallLabel();
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 26,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(sx + size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2),
    );
  }

  void _drawWarningPulse(Canvas canvas, double sx, Color wallColor) {
    final pulse = (sin(_elapsed * 8) + 1) / 2;
    canvas.drawRect(
      Rect.fromLTWH(sx, 0, size.x, size.y),
      Paint()
        ..color = wallColor.withOpacity(0.15 * pulse)
        ..style = PaintingStyle.fill,
    );
  }

  bool takeDamage(int damage) {
    hp -= damage;
    _crackProgress = 1 - (hp / maxHp).clamp(0.0, 1.0);
    _shakeX = 14;
    _flashTimer = 0.15;

    if (hp <= 0) {
      _isDestroyed = true;
      removeFromParent();
      return true;
    }
    return false;
  }

  Color _wallColor() {
    switch (wallType) {
      case WallType.wood:  return const Color(0xFF8B4513);
      case WallType.stone: return const Color(0xFF607D8B);
      case WallType.iron:  return const Color(0xFF37474F);
      case WallType.steel: return const Color(0xFF1A237E);
      case WallType.boss:  return const Color(0xFF8B0000);
    }
  }

  String _wallLabel() {
    switch (wallType) {
      case WallType.wood:  return '🪵';
      case WallType.stone: return '🪨';
      case WallType.iron:  return '⚙️';
      case WallType.steel: return '🔩';
      case WallType.boss:  return '💀';
    }
  }

  @override
  int get priority => 4;
}
