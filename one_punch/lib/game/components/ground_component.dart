import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../one_punch_game.dart';

class GroundComponent extends Component with HasGameRef<OnePunchGame> {
  double _scrollOffset = 0;
  static const _tileWidth = 80.0;

  @override
  void update(double dt) {
    // 현재 벽 속도와 연동해서 지면 스크롤 속도 동적 조정
    final stage = gameRef.currentStage;
    final wallData = WallConfig.forStage(stage);
    final currentSpeed = wallData.baseSpeed + stage * 8.0;
    _scrollOffset = (_scrollOffset + dt * currentSpeed * 0.55) % _tileWidth;
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final groundY = size.y * 0.75;
    final groundH = size.y - groundY;

    // 지면 베이스
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF1C1C2E), Color(0xFF0D0D1A)],
      ).createShader(Rect.fromLTWH(0, groundY, size.x, groundH));
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.x, groundH), basePaint);

    // 타일 패턴
    final tilePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double x = -_scrollOffset; x < size.x + _tileWidth; x += _tileWidth) {
      canvas.drawLine(Offset(x, groundY), Offset(x, groundY + groundH), tilePaint);
    }
    for (double y = groundY; y < size.y; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), tilePaint);
    }

    // 네온 라인
    canvas.drawLine(
      Offset(0, groundY), Offset(size.x, groundY),
      Paint()..color = AppColors.primary.withOpacity(0.8)..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(0, groundY), Offset(size.x, groundY),
      Paint()
        ..color = AppColors.primary.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..strokeWidth = 6,
    );

    // 속도선
    final speedPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.25)
      ..strokeWidth = 2;
    for (double x = -_scrollOffset; x < size.x + _tileWidth; x += _tileWidth) {
      canvas.drawLine(
        Offset(x, groundY + 6),
        Offset(x + _tileWidth * 0.5, groundY + 6),
        speedPaint,
      );
    }
  }

  @override
  int get priority => 1;
}
