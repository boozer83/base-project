import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../one_punch_game.dart';

enum RunnerState { running, punching, hurting, dying, reviving }

// ── 7.png 원펀남 스프라이트 좌표 (캐릭터 0 전용) ────────
// 이미지: 1264×842 (설계 기준 1280×800), 크로마키 제거 완료
class _C7 {
  // RUN: 8프레임, y=60, 70×85
  static const runY  = 60.0;
  static const runH  = 85.0;
  static const runW  = 70.0;
  static const runX  = [20.0, 120.0, 220.0, 320.0, 420.0, 560.0, 660.0, 760.0];

  // HURT: 5프레임, y=250, 70×85
  static const hurtY = 250.0;
  static const hurtH = 85.0;
  static const hurtW = 70.0;
  static const hurtX = [20.0, 120.0, 220.0, 320.0, 420.0];

  // DEAD: 6프레임, y=400, h=85, 가변 폭 [x, w]
  static const deadY = 400.0;
  static const deadH = 85.0;
  static const deadFrames = [
    [20.0,  70.0],  // 충격
    [120.0, 80.0],  // 공중
    [220.0, 85.0],  // 낙하
    [320.0, 95.0],  // 바닥1
    [430.0, 100.0], // 바닥2
    [540.0, 100.0], // 완전 사망
  ];

  // FINISH(스테이지 클리어): 8프레임, y=580, 가변 폭×90
  static const finishY = 580.0;
  static const finishH = 90.0;
  static const finishFrames = [
    [20.0,  75.0],
    [120.0, 75.0],
    [220.0, 75.0],
    [320.0, 75.0],
    [430.0, 75.0],
    [550.0, 85.0],
    [660.0, 80.0],
    [760.0, 85.0],
  ];

  // COMBO(펀치 연타): 10프레임, y=740, 가변 폭×85
  static const comboY = 740.0;
  static const comboH = 85.0;
  static const comboFrames = [
    [20.0,  75.0],
    [120.0, 75.0],
    [220.0, 75.0],
    [320.0, 75.0],
    [430.0, 75.0],
    [540.0, 75.0],
    [650.0, 80.0],
    [760.0, 75.0],
    [860.0, 75.0],
    [960.0, 75.0],
  ];
}

class RunnerComponent extends PositionComponent with HasGameRef<OnePunchGame> {
  final int characterIndex;
  RunnerState _state = RunnerState.running;

  ui.Image? _sheet;
  double _animTimer  = 0;
  double _stateTimer = 0;
  int    _runFrame   = 0;
  double _shakeX = 0;
  double _shakeY = 0;

  RunnerComponent({required this.characterIndex});

  @override
  Future<void> onLoad() async {
    final gs = gameRef.size;
    final groundY = gs.y * 0.75;
    size = Vector2(88, 104);
    position = Vector2(gs.x * 0.13, groundY - size.y);

    try {
      // 캐릭터 0(원펀남)은 4.png, 나머지는 폴백
      _sheet = characterIndex == 0
          ? await gameRef.images.load('7.png')
          : null;
    } catch (_) {}
  }

  @override
  void update(double dt) {
    _animTimer  += dt;
    _stateTimer += dt;
    _shakeX *= 0.78;
    _shakeY *= 0.78;

    // 달리기 프레임 순환 (0.13초마다, 8프레임)
    if (_state == RunnerState.running) {
      _runFrame = (_animTimer / 0.13).floor() % _C7.runX.length;
    }

    switch (_state) {
      case RunnerState.punching:
        if (_stateTimer > 0.35) _state = RunnerState.running;
        break;
      case RunnerState.hurting:
        if (_stateTimer > 0.45) _state = RunnerState.running;
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

    if (_sheet != null) {
      _renderSprite(canvas);
    } else {
      _renderFallback(canvas);
    }

    // 이펙트는 항상 캔버스로
    if (_state == RunnerState.punching)  _drawPunchEffect(canvas);
    if (_state == RunnerState.hurting)   _drawHurtFlash(canvas);
    if (_state == RunnerState.reviving)  _drawReviveRing(canvas);

    canvas.restore();
  }

  // ── 7.png 스프라이트 렌더링 (캐릭터 0 전용) ──────────
  void _renderSprite(Canvas canvas) {
    final sheet = _sheet!;
    double srcX, srcY, srcW, srcH;

    switch (_state) {
      case RunnerState.running:
        srcX = _C7.runX[_runFrame % _C7.runX.length];
        srcY = _C7.runY; srcW = _C7.runW; srcH = _C7.runH;
        break;
      case RunnerState.punching:
        final pIdx = ((_stateTimer / 0.35) * _C7.comboFrames.length).floor()
            .clamp(0, _C7.comboFrames.length - 1);
        srcX = _C7.comboFrames[pIdx][0];
        srcY = _C7.comboY; srcW = _C7.comboFrames[pIdx][1]; srcH = _C7.comboH;
        break;
      case RunnerState.hurting:
        final hIdx = ((_stateTimer / 0.45) * _C7.hurtX.length).floor()
            .clamp(0, _C7.hurtX.length - 1);
        srcX = _C7.hurtX[hIdx];
        srcY = _C7.hurtY; srcW = _C7.hurtW; srcH = _C7.hurtH;
        break;
      case RunnerState.dying:
        final dIdx = (_stateTimer * 3).floor().clamp(0, _C7.deadFrames.length - 1);
        srcX = _C7.deadFrames[dIdx][0];
        srcY = _C7.deadY; srcW = _C7.deadFrames[dIdx][1]; srcH = _C7.deadH;
        break;
      case RunnerState.reviving:
        final cIdx = ((_stateTimer / 0.6) * _C7.finishFrames.length).floor()
            .clamp(0, _C7.finishFrames.length - 1);
        srcX = _C7.finishFrames[cIdx][0];
        srcY = _C7.finishY; srcW = _C7.finishFrames[cIdx][1]; srcH = _C7.finishH;
        break;
    }

    final src = Rect.fromLTWH(srcX, srcY, srcW, srcH);
    final dst = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()..filterQuality = FilterQuality.low;

    if (_state == RunnerState.dying) {
      final alpha = (1.0 - (_stateTimer * 1.2)).clamp(0.0, 1.0);
      canvas.saveLayer(null, Paint()..color = Color.fromARGB((alpha * 255).toInt(), 255, 255, 255));
      canvas.drawImageRect(sheet, src, dst, paint);
      canvas.restore();
    } else {
      canvas.drawImageRect(sheet, src, dst, paint);
    }
  }

  // ── 폴백 렌더링 (스프라이트 없을 때 단순 사각형) ──────
  void _renderFallback(Canvas canvas) {
    final color = _fallbackColor();
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(8, 0, size.x - 16, size.y - 4), const Radius.circular(8)),
      Paint()..color = color,
    );
    // 텍스트로 캐릭터 번호 표시
    final tp = TextPainter(
      text: TextSpan(text: '${characterIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 30)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2));
  }

  Color _fallbackColor() {
    const colors = [
      Color(0xFFCC8844),
      Color(0xFF6633AA),
      Color(0xFF3366CC),
      Color(0xFF336633),
      Color(0xFF8B0000),
    ];
    return colors[characterIndex.clamp(0, colors.length - 1)];
  }

  // ── 이펙트 오버레이 ──────────────────────────────────
  void _drawPunchEffect(Canvas canvas) {
    final t = (_stateTimer / 0.35).clamp(0.0, 1.0);
    final hitX = size.x + 10.0;
    final hitY = size.y * 0.35;
    final r    = 14 + t * 40;
    final alpha = (1.0 - t).clamp(0.0, 1.0);
    final color = _accentColor();

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(hitX, hitY),
        r - i * 10,
        Paint()
          ..color = color.withOpacity(alpha * (0.85 - i * 0.25))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 - i * 0.5,
      );
    }
    // 스파크
    final sp = Paint()..color = Colors.white.withOpacity(alpha * 0.9)..strokeWidth = 2;
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3 + t * pi * 0.4;
      final sr = r * 0.6;
      canvas.drawLine(
        Offset(hitX + cos(angle) * sr * 0.3, hitY + sin(angle) * sr * 0.3),
        Offset(hitX + cos(angle) * sr,        hitY + sin(angle) * sr),
        sp,
      );
    }
  }

  void _drawHurtFlash(Canvas canvas) {
    final t = (_stateTimer / 0.45).clamp(0.0, 1.0);
    final alpha = ((1.0 - t * 2).clamp(0.0, 0.5));
    if (alpha > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.red.withOpacity(alpha),
      );
    }
  }

  void _drawReviveRing(Canvas canvas) {
    final t = (_stateTimer / 0.6).clamp(0.0, 1.0);
    final color = _accentColor();
    for (int i = 0; i < 3; i++) {
      final r   = 30.0 + i * 15 + t * 30;
      final alp = (1.0 - t) * (0.65 - i * 0.18);
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        r,
        Paint()
          ..color = color.withOpacity(alp.clamp(0, 1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  Color _accentColor() {
    const colors = [
      Color(0xFFFF8C00),
      Color(0xFF9933FF),
      Color(0xFF00BFFF),
      Color(0xFF66FF00),
      Color(0xFFFF6600),
    ];
    return colors[characterIndex.clamp(0, colors.length - 1)];
  }

  // ── 외부 호출 ─────────────────────────────────────
  void punch(JudgeResult judge) {
    _state = RunnerState.punching;
    _stateTimer = 0;
    if (judge == JudgeResult.perfect) {
      _shakeX = 8;
      _shakeY = -5;
    }
  }

  void hurt() {
    _state = RunnerState.hurting;
    _stateTimer = 0;
    _shakeX = -16;
    _shakeY = 4;
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
