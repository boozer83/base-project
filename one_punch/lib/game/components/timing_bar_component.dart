import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class TimingBarComponent extends Component with HasGameRef {
  final Vector2 gameSize;

  double _progress = 0.5; // 중앙에서 시작
  double _speed = 1.6;
  bool _goingRight = true;
  double _elapsed = 0;

  static const _barHeight = 24.0;
  static const _barPadH = 28.0;
  double get _barWidth => gameSize.x - _barPadH * 2;
  double get _barY => gameSize.y * 0.87;

  TimingBarComponent({required this.gameSize});

  @override
  void update(double dt) {
    _elapsed += dt;
    _speed = 1.6 + _elapsed * 0.12;

    if (_goingRight) {
      _progress += _speed * dt;
      if (_progress >= 1.0) {
        _progress = 1.0;
        _goingRight = false;
      }
    } else {
      _progress -= _speed * dt;
      if (_progress <= 0.0) {
        _progress = 0.0;
        _goingRight = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final barLeft = _barPadH;
    final barTop = _barY;

    // ── 전체 배경 어둡게 ──────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, barTop - 12, gameSize.x, _barHeight + 24),
        const Radius.circular(0),
      ),
      Paint()..color = Colors.black.withOpacity(0.5),
    );

    // ── 배경 바 ───────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, barTop, _barWidth, _barHeight),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF0A0A1A),
    );

    // ── 판정 구간 ─────────────────────────────────
    final cx = barLeft + _barWidth / 2;

    void drawZone(double halfW, Color color, double opacity) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - halfW, barTop, halfW * 2, _barHeight),
          const Radius.circular(12),
        ),
        Paint()..color = color.withOpacity(opacity),
      );
    }

    drawZone(_barWidth * 0.40, AppColors.good, 0.25);
    drawZone(_barWidth * 0.25, AppColors.great, 0.35);
    drawZone(_barWidth * 0.10, AppColors.perfect, 0.55);

    // PERFECT 중앙 빛
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - _barWidth * 0.10, barTop, _barWidth * 0.20, _barHeight),
        const Radius.circular(12),
      ),
      Paint()
        ..color = AppColors.perfect.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // ── 테두리 ────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barLeft, barTop, _barWidth, _barHeight),
        const Radius.circular(12),
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ── 마커 ──────────────────────────────────────
    final markerX = barLeft + _barWidth * _progress;
    const mW = 5.0;

    // 마커 글로우
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(markerX - mW * 1.5, barTop - 2, mW * 3, _barHeight + 4),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 마커 본체
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(markerX - mW / 2, barTop, mW, _barHeight),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white,
    );

    // ── 판정 레이블 ──────────────────────────────
    void drawLabel(String text, double x, Color color) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 9,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, barTop + _barHeight + 3));
    }

    drawLabel('GOOD', cx - _barWidth * 0.30, AppColors.good);
    drawLabel('GREAT', cx - _barWidth * 0.175, AppColors.great);
    drawLabel('PERFECT', cx, AppColors.perfect);
    drawLabel('GREAT', cx + _barWidth * 0.175, AppColors.great);
    drawLabel('GOOD', cx + _barWidth * 0.30, AppColors.good);

    // ── TAP! 텍스트 ──────────────────────────────
    final pulse = (sin(_elapsed * 7) + 1) / 2;
    final tapTp = TextPainter(
      text: TextSpan(
        text: 'TAP!',
        style: TextStyle(
          fontSize: 13 + pulse * 3,
          color: Colors.white.withOpacity(0.6 + pulse * 0.4),
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
          shadows: [Shadow(color: Colors.white.withOpacity(0.3), blurRadius: 8)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tapTp.paint(
      canvas,
      Offset(gameSize.x / 2 - tapTp.width / 2, barTop - tapTp.height - 6),
    );
  }

  double get currentOffset => (_progress - 0.5).abs();

  @override
  int get priority => 20;
}
