import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CharacterData {
  final int id;
  final String name;
  final String emoji;
  final String description;
  final Color color;
  final int atkBonus;       // % 보너스
  final double spdBonus;    // 판정창 추가 보너스
  final double comboBonus;  // 콤보 데미지 배율 추가
  final int hpBonus;        // 추가 하트 수
  final bool isGacha;
  final int unlockStage;    // 0이면 기본 해금

  const CharacterData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
    this.atkBonus = 0,
    this.spdBonus = 0,
    this.comboBonus = 0,
    this.hpBonus = 0,
    this.isGacha = false,
    this.unlockStage = 0,
  });
}

const List<CharacterData> allCharacters = [
  CharacterData(
    id: 0,
    name: '원펀남',
    emoji: '🥋',
    description: '균형잡힌 스타트 캐릭터',
    color: Color(0xFF4FC3F7),
    unlockStage: 0,
  ),
  CharacterData(
    id: 1,
    name: '마법사',
    emoji: '🧙',
    description: '스킬 게이지가 빠르게 찬다',
    color: Color(0xFFCE93D8),
    spdBonus: 0.05,
    unlockStage: 10,
  ),
  CharacterData(
    id: 2,
    name: '사이보그',
    emoji: '🤖',
    description: 'ATK 최강, 콤보는 약함',
    color: Color(0xFF80CBC4),
    atkBonus: 30,
    comboBonus: -0.1,
    isGacha: true,
  ),
  CharacterData(
    id: 3,
    name: '괴물',
    emoji: '👹',
    description: '콤보 특화, 스킬 없음',
    color: Color(0xFFEF9A9A),
    comboBonus: 0.2,
    isGacha: true,
  ),
  CharacterData(
    id: 4,
    name: '전설의 용사',
    emoji: '💫',
    description: '모든 스탯 최상급 + 전용 이펙트',
    color: AppColors.gold,
    atkBonus: 50,
    spdBonus: 0.08,
    comboBonus: 0.15,
    hpBonus: 1,
    isGacha: true,
  ),
];
