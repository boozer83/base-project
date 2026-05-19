import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/character_data.dart';
import '../one_punch_game.dart';

enum RunnerState { running, punching, hurting, dying, reviving }

class RunnerComponent extends PositionComponent with HasGameRef {
  final int characterIndex;
  RunnerState _state = RunnerState.running;

  double _animTimer = 0;
  double _stateTimer = 0;
  double _legPhase = 0;
  double _shakeX = 0;
  double _shakeY = 0;

  late CharacterData _character;

  RunnerComponent({required this.characterIndex});

  @override
  Future<void> onLoad() async {
    _character = allCharacters[characterIndex.clamp(0, allCharacters.length - 1)];
    final gs = gameRef.size;
    final groundY = gs.y * 0.75;
    size = Vector2(72, 84);
    position = Vector2(gs.x * 0.15, groundY - size.y);
  }

  @override
  void update(double dt) {
    _animTimer += dt;
    _stateTimer += dt;
    _legPhase = sin(_animTimer * 18) * 12;
    _shakeX *= 0.8;
    _shakeY *= 0.8;

    switch (_state) {
      case RunnerState.punching:
        if (_stateTimer > 0.35) _state = RunnerState.running;
        break;
      case RunnerState.hurting:
        if (_stateTimer > 0.4) _state = RunnerState.running;
        break;
      case RunnerState.reviving:
        if (_stateTimer > 0.6) _state = RunnerState.running;
        break;
      default:
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(_shakeX, _shakeY);

    switch (_state) {
      case RunnerState.running:
        _drawRunning(canvas);
        break;
      case RunnerState.punching:
        _drawPunching(canvas);
        break;
      case RunnerState.hurting:
        _drawHurting(canvas);
        break;
      case RunnerState.dying:
        _drawDying(canvas);
        break;
      case RunnerState.reviving:
        _drawReviving(canvas);
        break;
    }

    canvas.restore();
  }

  // ── 캐릭터별 색상 팔레트 ──────────────────────────
  Color get _skinColor {
    switch (characterIndex) {
      case 0: return const Color(0xFFD4956A); // 원펀남 - 피부
      case 1: return const Color(0xFF7B3FA0); // 마법사 - 보라
      case 2: return const Color(0xFF4A9EBF); // 사이보그 - 하늘
      case 3: return const Color(0xFF4A7A2E); // 괴물 - 초록
      case 4: return const Color(0xFFBF6030); // 전설의 용사 - 동
      default: return const Color(0xFFD4956A);
    }
  }

  Color get _outfitColor {
    switch (characterIndex) {
      case 0: return const Color(0xFF1A1A2E); // 원펀남 - 흰 수트(어둡게)
      case 1: return const Color(0xFF2A1540); // 마법사 - 망토
      case 2: return const Color(0xFF1A3A4A); // 사이보그 - 메탈
      case 3: return const Color(0xFF2A4A1A); // 괴물 - 진녹색
      case 4: return const Color(0xFF6A3010); // 전설의 용사 - 갑옷
      default: return const Color(0xFF1A1A2E);
    }
  }

  Color get _accentColor {
    switch (characterIndex) {
      case 0: return const Color(0xFFFFD700); // 원펀남 - 골드
      case 1: return const Color(0xFFAA44FF); // 마법사 - 마나
      case 2: return const Color(0xFF00CFFF); // 사이보그 - 사이버
      case 3: return const Color(0xFF88FF44); // 괴물 - 독
      case 4: return const Color(0xFFFF6600); // 전설의 용사 - 불꽃
      default: return const Color(0xFFFFD700);
    }
  }

  void _drawRunning(Canvas canvas) {
    _drawShadow(canvas);
    _drawLegsRunning(canvas);
    _drawBody(canvas, _skinColor, _outfitColor);
    _drawHead(canvas, _skinColor);
    _drawArmLeft(canvas, _skinColor, _outfitColor, _legPhase * 0.4);
    _drawArmRight(canvas, _skinColor, _outfitColor, -_legPhase * 0.4);
    _drawEffect(canvas);
  }

  void _drawPunching(Canvas canvas) {
    _drawShadow(canvas);
    _drawLegsStance(canvas);
    _drawBody(canvas, _skinColor, _outfitColor);
    _drawHead(canvas, _skinColor);
    // 뒤쪽 팔
    _drawArmLeft(canvas, _skinColor, _outfitColor, -8);
    // 앞으로 뻗은 주먹
    _drawPunchArm(canvas);
    _drawPunchEffect(canvas);
  }

  void _drawHurting(Canvas canvas) {
    _drawShadow(canvas);
    _drawLegsStance(canvas);
    canvas.save();
    canvas.translate(-4, 2);
    _drawBody(canvas, Colors.red.shade800, Colors.red.shade900);
    _drawHead(canvas, Colors.red.shade700);
    canvas.restore();
    _drawHurtEffect(canvas);
  }

  void _drawDying(Canvas canvas) {
    canvas.save();
    final t = (_stateTimer * 2).clamp(0.0, 1.0);
    canvas.translate(size.x / 2, size.y * 0.8);
    canvas.rotate(t * pi / 2);
    canvas.translate(-size.x / 2, -size.y * 0.8);
    _drawBody(canvas, Colors.grey.shade700, Colors.grey.shade900);
    _drawHead(canvas, Colors.grey.shade600);
    canvas.restore();
  }

  void _drawReviving(Canvas canvas) {
    final opacity = (_stateTimer / 0.6).clamp(0.0, 1.0);
    canvas.saveLayer(null, Paint()..color = Color.fromARGB((opacity * 255).toInt(), 255, 255, 255));
    _drawLegsStance(canvas);
    _drawBody(canvas, _skinColor, _outfitColor);
    _drawHead(canvas, _skinColor);
    canvas.restore();

    // 부활 링 이펙트
    for (int i = 0; i < 3; i++) {
      final r = 30.0 + i * 15 + opacity * 30;
      final a = (1 - opacity) * (0.8 - i * 0.2);
      canvas.drawCircle(
        Offset(size.x / 2, size.y * 0.5),
        r,
        Paint()
          ..color = _accentColor.withOpacity(a.clamp(0, 1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  // ── 그림자 ───────────────────────────────────────
  void _drawShadow(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 4),
        width: size.x * 0.7,
        height: 8,
      ),
      Paint()..color = Colors.black.withOpacity(0.3),
    );
  }

  // ── 다리 (달리기) ─────────────────────────────────
  void _drawLegsRunning(Canvas canvas) {
    final legColor = _outfitColor;
    final shoeColor = Colors.black87;

    // 왼다리
    final lLegRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * 0.3 - 6, size.y * 0.55 + _legPhase, 12, 26),
      const Radius.circular(4),
    );
    canvas.drawRRect(lLegRect, Paint()..color = legColor);
    // 왼발
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.3 - 8, size.y * 0.55 + _legPhase + 22, 16, 8),
        const Radius.circular(3),
      ),
      Paint()..color = shoeColor,
    );

    // 오른다리
    final rLegRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * 0.6 - 6, size.y * 0.55 - _legPhase, 12, 26),
      const Radius.circular(4),
    );
    canvas.drawRRect(rLegRect, Paint()..color = legColor);
    // 오른발
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.6 - 8, size.y * 0.55 - _legPhase + 22, 16, 8),
        const Radius.circular(3),
      ),
      Paint()..color = shoeColor,
    );
  }

  // ── 다리 (스탠스) ─────────────────────────────────
  void _drawLegsStance(Canvas canvas) {
    final legColor = _outfitColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.25, size.y * 0.55, 12, 28),
        const Radius.circular(4),
      ),
      Paint()..color = legColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.55, size.y * 0.52, 12, 28),
        const Radius.circular(4),
      ),
      Paint()..color = legColor,
    );
  }

  // ── 몸통 ─────────────────────────────────────────
  void _drawBody(Canvas canvas, Color skinColor, Color outfitColor) {
    // 몸통
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.2, size.y * 0.3, size.x * 0.6, size.y * 0.28),
        const Radius.circular(8),
      ),
      Paint()..color = outfitColor,
    );
    // 가슴 디테일
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.28, size.y * 0.32, size.x * 0.44, size.y * 0.10),
        const Radius.circular(4),
      ),
      Paint()..color = _accentColor.withOpacity(0.2),
    );
    // 벨트
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.2, size.y * 0.54, size.x * 0.6, 6),
        const Radius.circular(3),
      ),
      Paint()..color = _accentColor.withOpacity(0.6),
    );
  }

  // ── 머리 ─────────────────────────────────────────
  void _drawHead(Canvas canvas, Color skinColor) {
    final cx = size.x / 2;
    final cy = size.y * 0.17;
    final r = size.x * 0.22;

    // 머리
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = skinColor);
    // 머리 윤곽
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 캐릭터별 머리 특징
    switch (characterIndex) {
      case 0: // 원펀남 - 민머리 + 무표정
        // 눈 (작고 무표정)
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 5, cy), width: 7, height: 5),
          Paint()..color = Colors.black87,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 5, cy), width: 7, height: 5),
          Paint()..color = Colors.black87,
        );
        break;
      case 1: // 마법사 - 눈이 빛남
        canvas.drawCircle(Offset(cx - 5, cy), 4, Paint()..color = const Color(0xFFAA44FF));
        canvas.drawCircle(Offset(cx + 5, cy), 4, Paint()..color = const Color(0xFFAA44FF));
        // 마법 후드
        _drawHood(canvas, cx, cy, r, const Color(0xFF2A1540));
        break;
      case 2: // 사이보그 - 바이저
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 10, cy - 3, 20, 7),
            const Radius.circular(3),
          ),
          Paint()..color = const Color(0xFF00CFFF).withOpacity(0.8),
        );
        break;
      case 3: // 괴물 - 뿔 + 큰 눈
        canvas.drawCircle(Offset(cx - 6, cy), 5, Paint()..color = const Color(0xFFFF4400));
        canvas.drawCircle(Offset(cx + 6, cy), 5, Paint()..color = const Color(0xFFFF4400));
        // 뿔
        final hornPath = Path()
          ..moveTo(cx - 8, cy - r)
          ..lineTo(cx - 12, cy - r - 14)
          ..lineTo(cx - 4, cy - r);
        canvas.drawPath(hornPath, Paint()..color = const Color(0xFF2A4A1A));
        final hornPath2 = Path()
          ..moveTo(cx + 8, cy - r)
          ..lineTo(cx + 12, cy - r - 14)
          ..lineTo(cx + 4, cy - r);
        canvas.drawPath(hornPath2, Paint()..color = const Color(0xFF2A4A1A));
        break;
      case 4: // 전설의 용사 - 투구
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - r, cy - r - 2, r * 2, r + 4),
            Radius.circular(r),
          ),
          Paint()..color = const Color(0xFF6A3010),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 5, cy + 2), width: 7, height: 5),
          Paint()..color = Colors.white70,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 5, cy + 2), width: 7, height: 5),
          Paint()..color = Colors.white70,
        );
        break;
    }
  }

  void _drawHood(Canvas canvas, double cx, double cy, double r, Color color) {
    final path = Path()
      ..moveTo(cx - r * 1.1, cy)
      ..lineTo(cx, cy - r * 1.8)
      ..lineTo(cx + r * 1.1, cy)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withOpacity(0.85));
  }

  // ── 팔 ───────────────────────────────────────────
  void _drawArmLeft(Canvas canvas, Color skinColor, Color outfitColor, double angle) {
    canvas.save();
    canvas.translate(size.x * 0.18, size.y * 0.35);
    canvas.rotate(angle * pi / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, 0, 10, 22),
        const Radius.circular(4),
      ),
      Paint()..color = outfitColor,
    );
    canvas.drawCircle(const Offset(0, 22), 5, Paint()..color = skinColor);
    canvas.restore();
  }

  void _drawArmRight(Canvas canvas, Color skinColor, Color outfitColor, double angle) {
    canvas.save();
    canvas.translate(size.x * 0.82, size.y * 0.35);
    canvas.rotate(angle * pi / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, 0, 10, 22),
        const Radius.circular(4),
      ),
      Paint()..color = outfitColor,
    );
    canvas.drawCircle(const Offset(0, 22), 5, Paint()..color = skinColor);
    canvas.restore();
  }

  // ── 주먹 뻗기 ─────────────────────────────────────
  void _drawPunchArm(Canvas canvas) {
    // 팔
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.65, size.y * 0.3, 30, 10),
        const Radius.circular(4),
      ),
      Paint()..color = _outfitColor,
    );
    // 주먹
    canvas.drawCircle(
      Offset(size.x * 0.65 + 34, size.y * 0.35),
      10,
      Paint()..color = _skinColor,
    );
    // 주먹 윤곽
    canvas.drawCircle(
      Offset(size.x * 0.65 + 34, size.y * 0.35),
      10,
      Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  // ── 이펙트들 ─────────────────────────────────────
  void _drawEffect(Canvas canvas) {
    // 속도선 (캐릭터 뒤)
    final rng = Random(7);
    for (int i = 0; i < 8; i++) {
      final yOff = size.y * 0.2 + rng.nextDouble() * size.y * 0.6;
      final len = 14.0 + rng.nextDouble() * 30;
      final opacity = 0.2 + sin(_animTimer * 10 + i) * 0.15;
      final speedPaint = Paint()
        ..color = _accentColor.withOpacity(opacity.clamp(0.05, 0.4))
        ..strokeWidth = 1.0 + rng.nextDouble();
      canvas.drawLine(Offset(-len, yOff), Offset(-2, yOff), speedPaint);
    }
    // 발 먼지
    final dustPaint = Paint()
      ..color = Colors.white.withOpacity(0.08 + sin(_animTimer * 14) * 0.05);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 6),
        width: 30 + sin(_animTimer * 14) * 10,
        height: 6,
      ),
      dustPaint,
    );
  }

  void _drawPunchEffect(Canvas canvas) {
    final t = _stateTimer / 0.35;
    final r = 18 + t * 40;
    final alpha = (1.0 - t).clamp(0.0, 1.0);
    final cx = size.x * 0.65 + 34;
    final cy = size.y * 0.35;

    // 충격파 링들
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(cx, cy),
        r - i * 10,
        Paint()
          ..color = _accentColor.withOpacity(alpha * (0.8 - i * 0.25))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 - i.toDouble(),
      );
    }

    // 스파크
    final sparkPaint = Paint()
      ..color = Colors.white.withOpacity(alpha)
      ..strokeWidth = 2;
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 + t * pi;
      final sr = r * 0.6;
      canvas.drawLine(
        Offset(cx + cos(angle) * sr * 0.5, cy + sin(angle) * sr * 0.5),
        Offset(cx + cos(angle) * sr, cy + sin(angle) * sr),
        sparkPaint,
      );
    }
  }

  void _drawHurtEffect(Canvas canvas) {
    final t = _stateTimer / 0.4;
    for (int i = 0; i < 5; i++) {
      final angle = Random(i).nextDouble() * pi * 2;
      final dist = 15 + t * 25;
      canvas.drawCircle(
        Offset(
          size.x / 2 + cos(angle) * dist,
          size.y / 2 + sin(angle) * dist,
        ),
        3 - t * 2,
        Paint()..color = Colors.red.withOpacity((1 - t).clamp(0, 1)),
      );
    }
  }

  // ── 외부 호출 ─────────────────────────────────────
  void punch(JudgeResult judge) {
    _state = RunnerState.punching;
    _stateTimer = 0;
    if (judge == JudgeResult.perfect) {
      _shakeX = 6;
      _shakeY = -4;
    }
  }

  void hurt() {
    _state = RunnerState.hurting;
    _stateTimer = 0;
    _shakeX = -14;
    _shakeY = 3;
  }

  void die() {
    _state = RunnerState.dying;
    _stateTimer = 0;
  }

  void revive() {
    _state = RunnerState.reviving;
    _stateTimer = 0;
  }

  @override
  int get priority => 5;
}
