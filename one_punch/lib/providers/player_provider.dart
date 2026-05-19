import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/player_data.dart';
import '../utils/constants.dart';

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerData>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<PlayerData> {
  static const _boxName = 'playerBox';
  late Box<PlayerData> _box;

  PlayerNotifier() : super(PlayerData()) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<PlayerData>(_boxName);
    if (_box.isEmpty) {
      final fresh = PlayerData();
      await _box.add(fresh);
      state = fresh;
    } else {
      state = _box.getAt(0)!;
      state.recoverStamina();
      await _save();
    }
  }

  Future<void> _save() async {
    state.save();
  }

  // ── 스태미나 ────────────────────────────────────
  Future<bool> useStamina() async {
    state.recoverStamina();
    if (state.stamina < GameConfig.staminaPerGame) return false;
    state.stamina -= GameConfig.staminaPerGame;
    state.lastStaminaTime = DateTime.now();
    await _save();
    state = PlayerData()
      ..nickname              = state.nickname
      ..coins                 = state.coins
      ..gems                  = state.gems
      ..stamina               = state.stamina
      ..lastStaminaTime       = state.lastStaminaTime
      ..atkLevel              = state.atkLevel
      ..spdLevel              = state.spdLevel
      ..comboLevel            = state.comboLevel
      ..hpLevel               = state.hpLevel
      ..highestStage          = state.highestStage
      ..maxCombo              = state.maxCombo
      ..selectedCharacterIndex= state.selectedCharacterIndex
      ..unlockedCharacters    = state.unlockedCharacters
      ..totalGamesPlayed      = state.totalGamesPlayed
      ..totalPerfectCount     = state.totalPerfectCount
      ..dailyAdWatchCount     = state.dailyAdWatchCount
      ..lastAdDate            = state.lastAdDate;
    return true;
  }

  Future<void> addStamina(int amount) async {
    state.stamina = (state.stamina + amount).clamp(0, GameConfig.maxStamina);
    await _save();
    _notify();
  }

  // ── 재화 ────────────────────────────────────────
  Future<void> addCoins(int amount) async {
    state.coins += amount;
    await _save();
    _notify();
  }

  Future<bool> spendCoins(int amount) async {
    if (state.coins < amount) return false;
    state.coins -= amount;
    await _save();
    _notify();
    return true;
  }

  Future<void> addGems(int amount) async {
    state.gems += amount;
    await _save();
    _notify();
  }

  Future<bool> spendGems(int amount) async {
    if (state.gems < amount) return false;
    state.gems -= amount;
    await _save();
    _notify();
    return true;
  }

  // ── 강화 ────────────────────────────────────────
  Future<bool> upgradeAtk() async {
    final cost = UpgradeCost.atk(state.atkLevel);
    if (state.coins < cost || state.atkLevel >= 50) return false;
    state.coins -= cost;
    state.atkLevel++;
    await _save();
    _notify();
    return true;
  }

  Future<bool> upgradeSpd() async {
    final cost = UpgradeCost.spd(state.spdLevel);
    if (state.coins < cost || state.spdLevel >= 30) return false;
    state.coins -= cost;
    state.spdLevel++;
    await _save();
    _notify();
    return true;
  }

  Future<bool> upgradeCombo() async {
    final cost = UpgradeCost.combo(state.comboLevel);
    if (state.coins < cost || state.comboLevel >= 30) return false;
    state.coins -= cost;
    state.comboLevel++;
    await _save();
    _notify();
    return true;
  }

  Future<bool> upgradeHp() async {
    final cost = UpgradeCost.hp(state.hpLevel);
    if (state.coins < cost || state.hpLevel >= 20) return false;
    state.coins -= cost;
    state.hpLevel++;
    await _save();
    _notify();
    return true;
  }

  // ── 게임 결과 저장 ────────────────────────────────
  Future<void> saveGameResult({
    required int stage,
    required int combo,
    required int coins,
    required int perfectCount,
  }) async {
    state.totalGamesPlayed++;
    state.totalPerfectCount += perfectCount;
    if (stage > state.highestStage) state.highestStage = stage;
    if (combo > state.maxCombo) state.maxCombo = combo;
    state.coins += coins;
    await _save();
    _notify();
  }

  // ── 캐릭터 선택 ──────────────────────────────────
  Future<void> selectCharacter(int index) async {
    if (!state.unlockedCharacters.contains(index)) return;
    state.selectedCharacterIndex = index;
    await _save();
    _notify();
  }

  // ── 닉네임 설정 ──────────────────────────────────
  Future<void> setNickname(String name) async {
    state.nickname = name;
    await _save();
    _notify();
  }

  void _notify() {
    // Hive 객체 변경 후 Riverpod 리빌드 트리거
    state = state;
  }
}
