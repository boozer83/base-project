import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../one_punch_game.dart';

class HudComponent extends Component with HasGameRef {
  final OnePunchGame game;
  double _comboScaleAnim = 1.0;
  int _lastCombo = 0;
  double _elapsed = 0;

  HudComponent({required this.game});

  @override
  void update(double dt) {
    _elapsed += dt;
    if (game.currentCombo != _lastCombo) {
      _comboScaleAnim = 1.5;
      _lastCombo = game.currentCombo;
    }
    if (_comboScaleAnim > 1.0) {
      _comboScaleAnim -= dt * 5;
      if (_comboScaleAnim < 1.0) _comboScaleAnim = 1.0;
    }
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;

    _drawTopHudBg(canvas, size);
    _drawHearts(canvas, size);
    _drawStage(canvas, size);
    _drawCoins(canvas, size);
    _drawPauseButton(canvas, size);

    if (game.currentCombo >= 2) _drawCombo(canvas, size);
    if (game.judgeDisplayTimer > 0) _drawJudgeText(canvas, size);

    // 벽 접근 시 화면 가장자리 펄스 (타이밍 바 대체)
    _drawProximityAlert(canvas, size);
  }

  void _drawTopHudBg(Canvas canvas, Vector2 size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black.withOpacity(0.85), Colors.black.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.x, 52));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 52), paint);
  }

  void _drawHearts(Canvas canvas, Vector2 size) {
    const heartSize = 20.0;
    const startX = 14.0;
    const y = 16.0;

    for (int i = 0; i < game.maxHearts; i++) {
      final isFull = i < game.currentHearts;
      _drawHeart(
        canvas,
        Offset(startX + i * (heartSize + 5), y),
        heartSize,
        isFull ? AppColors.heartFull : AppColors.heartEmpty,
        isFull,
      );
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double sz, Color color, bool glow) {
    final path = Path();
    final s = sz / 2;
    path.moveTo(center.dx, center.dy + s * 0.8);
    path.cubicTo(
      center.dx - s * 1.2, center.dy - s * 0.2,
      center.dx - s * 1.2, center.dy - s * 0.9,
      center.dx, center.dy - s * 0.4,
    );
    path.cubicTo(
      center.dx + s * 1.2, center.dy - s * 0.9,
      center.dx + s * 1.2, center.dy - s * 0.2,
      center.dx, center.dy + s * 0.8,
    );
    if (glow) {
      canvas.drawPath(path, Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawStage(Canvas canvas, Vector2 size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.x / 2, 20), width: 110, height: 32),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.black.withOpacity(0.5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.x / 2, 20), width: 110, height: 32),
        const Radius.circular(8),
      ),
      Paint()
        ..color = AppColors.primary.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final tp = TextPainter(
      text: TextSpan(children: [
        TextSpan(
          text: 'STAGE ',
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500, letterSpacing: 1.5),
        ),
        TextSpan(
          text: '${game.currentStage}',
          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ]),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, 10));
  }

  void _drawCoins(Canvas canvas, Vector2 size) {
    final tp = TextPainter(
      text: TextSpan(
        text: '⭐ ${game.coinsEarned}',
        style: const TextStyle(fontSize: 13, color: AppColors.gold,
            fontWeight: FontWeight.bold, shadows: [Shadow(color: AppColors.gold, blurRadius: 6)]),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.x - tp.width - 54, 12));
  }

  void _drawPauseButton(Canvas canvas, Vector2 size) {
    const btnSize = 28.0;
    final btnX = size.x - btnSize - 12;
    const btnY = 10.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(btnX, btnY, btnSize, btnSize), const Radius.circular(7)),
      Paint()..color = Colors.white.withOpacity(0.15),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(btnX, btnY, btnSize, btnSize), const Radius.circular(7)),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final barP = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(btnX + 7, btnY + 7, 4, 14), const Radius.circular(2)), barP);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(btnX + 15, btnY + 7, 4, 14), const Radius.circular(2)), barP);
  }

  void _drawCombo(Canvas canvas, Vector2 size) {
    final scale = _comboScaleAnim;
    final comboColor = game.currentCombo >= 30
        ? AppColors.gold
        : game.currentCombo >= 20
            ? AppColors.perfect
            : game.currentCombo >= 10
                ? AppColors.great
                : Colors.white;

    canvas.save();
    final cx = size.x * 0.88;
    final cy = size.y * 0.38;
    canvas.translate(cx, cy);
    canvas.scale(scale, scale);

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-35, -30, 70, 60), const Radius.circular(10)),
      Paint()..color = Colors.black.withOpacity(0.55),
    );

    final tp = TextPainter(
      text: TextSpan(children: [
        TextSpan(
          text: '${game.currentCombo}',
          style: TextStyle(fontSize: 34, color: comboColor, fontWeight: FontWeight.bold,
              shadows: [Shadow(color: comboColor.withOpacity(0.7), blurRadius: 10)]),
        ),
        TextSpan(
          text: '\nCOMBO',
          style: TextStyle(fontSize: 10, color: comboColor.withOpacity(0.8), letterSpacing: 2),
        ),
      ]),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  void _drawJudgeText(Canvas canvas, Vector2 size) {
    final judge = game.lastJudge;
    String text;
    Color color;
    double fontSize;

    switch (judge) {
      case JudgeResult.perfect:
        text = '✦ PERFECT ✦';
        color = AppColors.perfect;
        fontSize = 32;
        break;
      case JudgeResult.great:
        text = '▶ GREAT';
        color = AppColors.great;
        fontSize = 26;
        break;
      case JudgeResult.good:
        text = '• GOOD';
        color = AppColors.good;
        fontSize = 22;
        break;
      case JudgeResult.miss:
        text = '✕ MISS';
        color = AppColors.miss;
        fontSize = 26;
        break;
      default:
        return;
    }

    final progress = 1 - (game.judgeDisplayTimer / 1.2);
    final opacity = sin(progress * pi).clamp(0.0, 1.0);
    final yOffset = -30 * progress;

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color.withOpacity(opacity),
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: color.withOpacity(opacity * 0.8), blurRadius: 16),
            Shadow(color: Colors.black.withOpacity(opacity * 0.6), blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, size.y * 0.35 + yOffset));
  }

  // 벽 근접 시 화면 가장자리를 붉게 펄스 (타이밍 힌트)
  void _drawProximityAlert(Canvas canvas, Vector2 size) {
    final dist = game.distanceToWall;
    if (dist == null) return;

    const perfectDist = 45.0;
    const greatDist = 110.0;
    const goodDist = 190.0;

    Color alertColor;
    double intensity;

    if (dist <= perfectDist) {
      alertColor = AppColors.perfect;
      intensity = 0.55 + sin(_elapsed * 20) * 0.2;
    } else if (dist <= greatDist) {
      alertColor = AppColors.great;
      intensity = 0.35 + sin(_elapsed * 14) * 0.15;
    } else if (dist <= goodDist) {
      alertColor = AppColors.good;
      intensity = 0.15 + sin(_elapsed * 8) * 0.1;
    } else {
      return;
    }

    // TAP 텍스트
    final tapOpacity = (intensity * 1.4).clamp(0.0, 1.0);
    final tapTp = TextPainter(
      text: TextSpan(
        text: 'TAP!',
        style: TextStyle(
          fontSize: 20 + (1 - dist / goodDist) * 8,
          color: alertColor.withOpacity(tapOpacity),
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
          shadows: [Shadow(color: alertColor.withOpacity(tapOpacity * 0.6), blurRadius: 12)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tapTp.paint(canvas, Offset(size.x / 2 - tapTp.width / 2, size.y * 0.78));

    // 좌측 테두리 강조 (캐릭터 쪽)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 6, size.y),
      Paint()
        ..color = alertColor.withOpacity(intensity * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  int get priority => 30;
}
