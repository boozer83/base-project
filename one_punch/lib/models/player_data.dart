import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';

part 'player_data.g.dart';

@HiveType(typeId: 0)
class PlayerData extends HiveObject {
  @HiveField(0)
  String nickname;

  @HiveField(1)
  int coins;

  @HiveField(2)
  int gems;

  @HiveField(3)
  int stamina;

  @HiveField(4)
  DateTime lastStaminaTime;

  @HiveField(5)
  int atkLevel;

  @HiveField(6)
  int spdLevel;

  @HiveField(7)
  int comboLevel;

  @HiveField(8)
  int hpLevel;

  @HiveField(9)
  int highestStage;

  @HiveField(10)
  int maxCombo;

  @HiveField(11)
  int selectedCharacterIndex;

  @HiveField(12)
  List<int> unlockedCharacters;

  @HiveField(13)
  int totalGamesPlayed;

  @HiveField(14)
  int totalPerfectCount;

  @HiveField(15)
  int dailyAdWatchCount;

  @HiveField(16)
  DateTime lastAdDate;

  PlayerData({
    this.nickname = '',
    this.coins = 500,
    this.gems = 30,
    this.stamina = GameConfig.maxStamina,
    DateTime? lastStaminaTime,
    this.atkLevel = 1,
    this.spdLevel = 1,
    this.comboLevel = 1,
    this.hpLevel = 1,
    this.highestStage = 0,
    this.maxCombo = 0,
    this.selectedCharacterIndex = 0,
    List<int>? unlockedCharacters,
    this.totalGamesPlayed = 0,
    this.totalPerfectCount = 0,
    this.dailyAdWatchCount = 0,
    DateTime? lastAdDate,
  })  : lastStaminaTime = lastStaminaTime ?? DateTime.now(),
        unlockedCharacters = unlockedCharacters ?? [0],
        lastAdDate = lastAdDate ?? DateTime(2000);

  // ── 스탯 계산 ──────────────────────────────────────
  int get atkValue   => 100 + (atkLevel - 1) * 20;
  double get spdBonus => (spdLevel - 1) * 0.01; // 판정창 보너스
  double get comboMultiplierBonus => (comboLevel - 1) * 0.005;
  int get maxHearts  => GameConfig.baseHearts + (hpLevel - 1);

  // ── 스태미나 자동 회복 ──────────────────────────────
  void recoverStamina() {
    final now = DateTime.now();
    final diff = now.difference(lastStaminaTime).inMinutes;
    final recovered = (diff ~/ GameConfig.staminaRechargeMin);
    if (recovered > 0) {
      stamina = (stamina + recovered).clamp(0, GameConfig.maxStamina);
      lastStaminaTime = lastStaminaTime.add(
        Duration(minutes: recovered * GameConfig.staminaRechargeMin),
      );
    }
  }

  int get minutesUntilNextStamina {
    if (stamina >= GameConfig.maxStamina) return 0;
    final elapsed = DateTime.now().difference(lastStaminaTime).inMinutes;
    return GameConfig.staminaRechargeMin - (elapsed % GameConfig.staminaRechargeMin);
  }

  // ── 광고 횟수 초기화 확인 ─────────────────────────
  bool get canWatchAd {
    final now = DateTime.now();
    if (now.day != lastAdDate.day ||
        now.month != lastAdDate.month ||
        now.year != lastAdDate.year) {
      dailyAdWatchCount = 0;
    }
    return dailyAdWatchCount < 5;
  }
}
