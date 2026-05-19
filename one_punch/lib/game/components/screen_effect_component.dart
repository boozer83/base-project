import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 화면 플래시 + 쉐이크 이펙트 컴포넌트
class ScreenEffectComponent extends Component with HasGameRef {
  // 플래시
  double _flashAlpha = 0.0;
  Color _flashColor = Colors.white;

  // 쉐이크
  double _shakeIntensity = 0.0;
  double _shakeDuration = 0.0;
  double _shakeElapsed = 0.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;

  // 히트스탑 (순간 정지)
  double _hitstopTimer = 0.0;

  final Random _rng = Random();

  bool get isHitstop => _hitstopTimer > 0;

  /// 벽 파괴 이펙트 (강한 쉐이크 + 흰 플래시)
  void onWallBreak() {
    _flash(Colors.white, 0.7);
    _shake(intensity: 16.0, duration: 0.35);
    _hitstopTimer = 0.06; // 0.06초 히트스탑
  }

  /// PERFECT 이펙트 (골드 플래시 + 중간 쉐이크)
  void onPerfect() {
    _flash(const Color(0xFFFFD700), 0.5);
    _shake(intensity: 8.0, duration: 0.2);
    _hitstopTimer = 0.04;
  }

  /// GREAT 이펙트
  void onGreat() {
    _flash(const Color(0xFF00E676), 0.3);
    _shake(intensity: 5.0, duration: 0.15);
  }

  /// MISS 이펙트 (빨간 플래시)
  void onMiss() {
    _flash(Colors.red, 0.4);
    _shake(intensity: 6.0, duration: 0.2);
  }

  void _flash(Color color, double alpha) {
    _flashColor = color;
    _flashAlpha = alpha;
  }

  void _shake({required double intensity, required double duration}) {
    _shakeIntensity = intensity;
    _shakeDuration = duration;
    _shakeElapsed = 0;
  }

  @override
  void update(double dt) {
    // 히트스탑
    if (_hitstopTimer > 0) {
      _hitstopTimer -= dt;
      return; // 히트스탑 중엔 업데이트 스킵 (게임 엔진에서 처리)
    }

    // 플래시 페이드아웃
    if (_flashAlpha > 0) {
      _flashAlpha -= dt * 4.0;
      if (_flashAlpha < 0) _flashAlpha = 0;
    }

    // 쉐이크
    if (_shakeElapsed < _shakeDuration) {
      _shakeElapsed += dt;
      final progress = _shakeElapsed / _shakeDuration;
      final decay = 1.0 - progress;
      final intensity = _shakeIntensity * decay;
      _offsetX = (_rng.nextDouble() * 2 - 1) * intensity;
      _offsetY = (_rng.nextDouble() * 2 - 1) * intensity * 0.6;
    } else {
      _offsetX = 0;
      _offsetY = 0;
    }

    // 카메라 오프셋 적용
    gameRef.camera.viewfinder.position = Vector2(_offsetX, _offsetY);
  }

  @override
  void render(Canvas canvas) {
    if (_flashAlpha <= 0) return;

    final size = gameRef.size;
    canvas.drawRect(
      Rect.fromLTWH(-size.x, -size.y, size.x * 3, size.y * 3),
      Paint()..color = _flashColor.withOpacity(_flashAlpha.clamp(0.0, 1.0)),
    );
  }

  @override
  int get priority => 100; // 가장 위에 렌더링
}
