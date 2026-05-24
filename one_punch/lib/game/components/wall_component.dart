import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

// ── 6.png 벽 스프라이트 좌표 맵 ───────────────────────
// 8개 벽 타입 × 6개 데미지 상태, 균일 70×80px
// Y축 90px 간격: 50, 140, 230, 320, 410, 500, 590, 680
// X축: 30, 130, 230, 330, 430, 550 (frame 1→6)
class _W {
  static const fw = 70.0;
  static const fh = 80.0;
  static const stateX = [30.0, 130.0, 230.0, 330.0, 430.0, 550.0];

  // 벽 타입 → Y 시작
  static double rowY(WallType t) {
    switch (t) {
      case WallType.wood:  return 50.0;   // 일반 벽돌
      case WallType.stone: return 140.0;  // 강화 콘크리트
      case WallType.iron:  return 230.0;  // 철제
      case WallType.steel: return 320.0;  // 마법 장벽
      case WallType.boss:  return 680.0;  // 독가시
    }
  }

  // HP 비율(0~1) → 프레임 인덱스(0~5)
  static int stateIndex(double hpRatio) {
    if (hpRatio > 0.83) return 0;
    if (hpRatio > 0.66) return 1;
    if (hpRatio > 0.50) return 2;
    if (hpRatio > 0.33) return 3;
    if (hpRatio > 0.16) return 4;
    return 5;
  }
}

class WallComponent extends PositionComponent with HasGameRef {
  final WallType wallType;
  int hp;
  final int maxHp;
  final double speed;

  ui.Image? _sheet;
  double _shakeX    = 0;
  double _flashTimer = 0;
  bool   _isDestroyed = false;
  double _elapsed   = 0;

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
  Future<void> onLoad() async {
    try {
      _sheet = await gameRef.images.load('6.png');
    } catch (_) {}
  }

  @override
  void update(double dt) {
    if (_isDestroyed) return;
    _elapsed += dt;
    position.x -= speed * dt;
    _shakeX   *= 0.75;
    if (_flashTimer > 0) _flashTimer -= dt;
  }

  @override
  void render(Canvas canvas) {
    if (_isDestroyed) return;
    final sx = _shakeX;

    canvas.drawRect(
      Rect.fromLTWH(sx + 6, 6, size.x, size.y),
      Paint()..color = Colors.black.withOpacity(0.4),
    );

    if (_sheet != null) {
      _renderSprite(canvas, sx);
    } else {
      _renderFallback(canvas, sx);
    }

    _drawHpBar(canvas, sx);
    if (position.x < gameRef.size.x * 0.55) {
      _drawWarningPulse(canvas, sx);
    }
  }

  void _renderSprite(Canvas canvas, double sx) {
    final sheet = _sheet!;
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    final si  = _W.stateIndex(hpRatio);
    final src = Rect.fromLTWH(_W.stateX[si], _W.rowY(wallType), _W.fw, _W.fh);
    final dst  = Rect.fromLTWH(sx, 0, size.x, size.y);
    final paint = Paint()..filterQuality = FilterQuality.low;

    if (_flashTimer > 0) {
      canvas.saveLayer(null, paint);
      canvas.drawImageRect(sheet, src, dst, paint);
      canvas.drawRect(dst, Paint()..color = Colors.white.withOpacity(_flashTimer * 4));
      canvas.restore();
    } else {
      canvas.drawImageRect(sheet, src, dst, paint);
    }

    final glowColor = _wallGlowColor();
    canvas.drawRect(
      Rect.fromLTWH(sx, 0, size.x, size.y),
      Paint()
        ..color = glowColor.withOpacity(0.25 + sin(_elapsed * 3) * 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  void _renderFallback(Canvas canvas, double sx) {
    final wallColor = _wallColor();
    final bodyColor = _flashTimer > 0
        ? Color.lerp(wallColor, Colors.white, _flashTimer * 3)!
        : wallColor;

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [bodyColor.withOpacity(0.8), bodyColor, bodyColor.withOpacity(0.7)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(sx, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(sx, 0, size.x, size.y), bodyPaint);

    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    if (hpRatio < 0.8) _drawFallbackCracks(canvas, sx, 1 - hpRatio);

    canvas.drawRect(
      Rect.fromLTWH(sx, 0, size.x, size.y),
      Paint()
        ..color = wallColor.withOpacity(0.3 + sin(_elapsed * 3) * 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  void _drawFallbackCracks(Canvas canvas, double sx, double progress) {
    final rng = Random(99);
    final crackPaint = Paint()
      ..color = Colors.black.withOpacity(0.7 * progress)
      ..strokeWidth = progress * 2.5
      ..style = PaintingStyle.stroke;

    final cx = size.x / 2 + sx;
    final cy = size.y / 2;
    final count = (6 * progress).toInt() + 2;

    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * pi * 2;
      final length = 10 + rng.nextDouble() * 28 * progress;
      double x = cx, y = cy;
      final path = Path()..moveTo(x, y);
      for (int j = 0; j < 4; j++) {
        final jitter = (rng.nextDouble() - 0.5) * 0.3;
        x += cos(angle + jitter) * length / 4;
        y += sin(angle + jitter) * length / 4;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, crackPaint);
    }
  }

  void _drawHpBar(Canvas canvas, double sx) {
    const barH = 8.0, padH = 5.0, barY = -16.0;
    final ratio = (hp / maxHp).clamp(0.0, 1.0);
    final barW  = size.x - padH * 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(sx + padH, barY, barW, barH), const Radius.circular(4)),
      Paint()..color = Colors.black.withOpacity(0.7),
    );

    if (ratio > 0) {
      final hpColor = Color.lerp(Colors.red, const Color(0xFF00E676), ratio)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(sx + padH, barY, barW * ratio, barH), const Radius.circular(4)),
        Paint()..color = hpColor,
      );
    }

    final tp = TextPainter(
      text: TextSpan(text: '$hp', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(sx + size.x / 2 - tp.width / 2, barY - tp.height - 1));
  }

  void _drawWarningPulse(Canvas canvas, double sx) {
    final pulse = (sin(_elapsed * 8) + 1) / 2;
    canvas.drawRect(
      Rect.fromLTWH(sx, 0, size.x, size.y),
      Paint()..color = _wallGlowColor().withOpacity(0.12 * pulse),
    );
  }

  bool takeDamage(int damage) {
    hp -= damage;
    _shakeX     = 14;
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

  Color _wallGlowColor() {
    switch (wallType) {
      case WallType.wood:  return const Color(0xFFCD853F);
      case WallType.stone: return const Color(0xFF90A4AE);
      case WallType.iron:  return const Color(0xFF78909C);
      case WallType.steel: return const Color(0xFF5C6BC0);
      case WallType.boss:  return const Color(0xFFEF5350);
    }
  }

  @override
  int get priority => 4;
}
