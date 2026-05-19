import 'package:flutter/material.dart';

// ── 색상 ──────────────────────────────────────────
class AppColors {
  static const background    = Color(0xFF1A1A2E);
  static const backgroundAlt = Color(0xFF16213E);
  static const primary       = Color(0xFFE94560);
  static const primaryDark   = Color(0xFFC73652);
  static const accent        = Color(0xFF0F3460);
  static const accentLight   = Color(0xFF533483);
  static const gold          = Color(0xFFFFD700);
  static const silver        = Color(0xFFC0C0C0);
  static const white         = Color(0xFFFFFFFF);
  static const textLight     = Color(0xFFE0E0E0);
  static const textDim       = Color(0xFF9E9E9E);

  // 판정 색상
  static const perfect = Color(0xFFFFD700);
  static const great   = Color(0xFF00E676);
  static const good    = Color(0xFF40C4FF);
  static const miss    = Color(0xFFFF5252);

  // 벽 색상
  static const wallWood  = Color(0xFF8B4513);
  static const wallStone = Color(0xFF808080);
  static const wallIron  = Color(0xFF4682B4);
  static const wallSteel = Color(0xFF2F4F4F);
  static const wallBoss  = Color(0xFF8B0000);

  // HP 하트
  static const heartFull  = Color(0xFFE94560);
  static const heartEmpty = Color(0xFF444444);
}

// ── 게임 수치 ──────────────────────────────────────
class GameConfig {
  // 타이밍 판정 (초 단위)
  static const perfectWindow = 0.10;
  static const greatWindow   = 0.25;
  static const goodWindow    = 0.40;

  // 데미지 배율
  static const perfectMult = 2.00;
  static const greatMult   = 1.30;
  static const goodMult    = 0.80;

  // 기본 HP (하트 수)
  static const baseHearts = 3;
  static const maxHearts  = 5;

  // 콤보 데미지 보너스
  static const combo10Bonus = 0.10;
  static const combo20Bonus = 0.20;
  static const combo30Bonus = 0.30;

  // 스태미나
  static const maxStamina          = 30;
  static const staminaPerGame      = 1;
  static const staminaRechargeMin  = 5; // 분

  // 코인
  static const baseCoinPerStage    = 100;
  static const perfectCoinBonus    = 10;
  static const comboCoinMultiplier = 0.01; // 콤보 × 1%
}

// ── 벽 설정 ────────────────────────────────────────
class WallConfig {
  static const stages = [
    WallStageData(minStage:  1, maxStage: 10, type: WallType.wood,  baseHp: 100,  baseSpeed: 160),
    WallStageData(minStage: 11, maxStage: 25, type: WallType.stone, baseHp: 300,  baseSpeed: 200),
    WallStageData(minStage: 26, maxStage: 50, type: WallType.iron,  baseHp: 700,  baseSpeed: 260),
    WallStageData(minStage: 51, maxStage: 999,type: WallType.steel, baseHp: 1500, baseSpeed: 340),
  ];

  static WallStageData forStage(int stage) {
    for (final s in stages) {
      if (stage >= s.minStage && stage <= s.maxStage) return s;
    }
    return stages.last;
  }
}

enum WallType { wood, stone, iron, steel, boss }

class WallStageData {
  final int minStage;
  final int maxStage;
  final WallType type;
  final int baseHp;
  final double baseSpeed; // px/sec

  const WallStageData({
    required this.minStage,
    required this.maxStage,
    required this.type,
    required this.baseHp,
    required this.baseSpeed,
  });
}

// ── 강화 비용 테이블 ────────────────────────────────
class UpgradeCost {
  static int atk(int level)   => (100 * (level * 1.5)).toInt();
  static int spd(int level)   => (80  * (level * 1.5)).toInt();
  static int combo(int level) => (80  * (level * 1.5)).toInt();
  static int hp(int level)    => (120 * (level * 1.5)).toInt();
}
