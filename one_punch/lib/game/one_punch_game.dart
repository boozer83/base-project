import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../models/player_data.dart';
import '../models/game_result.dart';
import '../utils/constants.dart';
import '../services/audio_manager.dart';
import 'components/runner_component.dart';
import 'components/wall_component.dart';
import 'components/background_component.dart';
import 'components/ground_component.dart';
import 'components/particle_component.dart';
import 'components/hud_component.dart';
import 'components/screen_effect_component.dart';

enum GameState { waiting, running, wallApproaching, judging, gameOver, paused }
enum JudgeResult { perfect, great, good, miss, none }

class OnePunchGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final PlayerData playerData;
  final void Function(GameResult) onGameOver;
  final void Function() onReviveRequested;

  GameState gameState = GameState.running;
  int currentStage = 1;
  int currentHearts = 3;
  int maxHearts = 3;
  int currentCombo = 0;
  int maxCombo = 0;
  int perfectCount = 0;
  int greatCount = 0;
  int goodCount = 0;
  int missCount = 0;
  int coinsEarned = 0;
  bool _revived = false;

  WallComponent? _currentWall;

  late RunnerComponent _runner;
  // ignore: unused_field
  late HudComponent _hud;
  // ignore: unused_field
  late BackgroundComponent _background;
  late ScreenEffectComponent _screenEffect;

  JudgeResult _lastJudge = JudgeResult.none;
  double _judgeDisplayTimer = 0;

  double _wallSpawnTimer = 0;
  double _wallSpawnInterval = 2.5;

  // 터치 잠금: 한 벽당 한 번만 판정
  bool _touched = false;

  OnePunchGame({
    required this.playerData,
    required this.onGameOver,
    required this.onReviveRequested,
  });

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioManager().init();
    AudioManager().play('game_start');

    currentHearts = playerData.maxHearts;
    maxHearts = playerData.maxHearts;

    _background = BackgroundComponent();
    await add(_background);

    await add(GroundComponent());

    _runner = RunnerComponent(characterIndex: playerData.selectedCharacterIndex);
    await add(_runner);

    _hud = HudComponent(game: this);
    await add(_hud);

    _screenEffect = ScreenEffectComponent();
    await add(_screenEffect);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState == GameState.paused || gameState == GameState.gameOver) return;
    if (_screenEffect.isHitstop) return;

    if (_judgeDisplayTimer > 0) {
      _judgeDisplayTimer -= dt;
      if (_judgeDisplayTimer <= 0) _lastJudge = JudgeResult.none;
    }

    // 벽 스폰
    if (_currentWall == null && gameState == GameState.running) {
      _wallSpawnTimer += dt;
      if (_wallSpawnTimer >= _wallSpawnInterval) {
        _spawnWall();
        _wallSpawnTimer = 0;
      }
    }

    // 벽 접근 감지: 캐릭터에 닿으면 자동 MISS
    if (_currentWall != null && gameState == GameState.wallApproaching) {
      final wallX = _currentWall!.position.x;
      final runnerRightX = _runner.position.x + _runner.size.x;

      if (wallX <= runnerRightX + 5) {
        if (!_touched) _processHit(JudgeResult.miss);
      }
    }
  }

  void _spawnWall() {
    final wallData = WallConfig.forStage(currentStage);
    final hp = (wallData.baseHp * (1 + currentStage * 0.05)).toInt();
    final speed = wallData.baseSpeed + currentStage * 8.0;

    _currentWall = WallComponent(
      wallType: wallData.type,
      hp: hp,
      speed: speed,
      gameSize: size,
    );
    add(_currentWall!);
    gameState = GameState.wallApproaching;
    _touched = false;
    _wallSpawnInterval = (2.5 - currentStage * 0.03).clamp(0.6, 2.5);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapPos = event.canvasPosition;

    // 일시정지 버튼 (우상단)
    final btnX = size.x - 46;
    const btnY = 14.0;
    const btnSize = 32.0;
    if (tapPos.x >= btnX && tapPos.x <= btnX + btnSize &&
        tapPos.y >= btnY && tapPos.y <= btnY + btnSize) {
      togglePause();
      if (gameState == GameState.paused) {
        overlays.add('pause');
      } else {
        overlays.remove('pause');
      }
      return;
    }

    if (gameState == GameState.wallApproaching && !_touched) {
      _touched = true;
      _judgeByDistance();
    }
  }

  // ── 거리 기반 판정 ──────────────────────────────────
  void _judgeByDistance() {
    if (_currentWall == null) return;

    final wallLeftX = _currentWall!.position.x;
    final characterRightX = _runner.position.x + _runner.size.x;
    final distance = wallLeftX - characterRightX;

    // spdBonus(0~0.29)를 픽셀로 변환해 판정 창 확장
    final extra = playerData.spdBonus * 120;

    JudgeResult result;
    if (distance < -5) {
      result = JudgeResult.miss; // 벽이 이미 지나침
    } else if (distance <= 45 + extra) {
      result = JudgeResult.perfect;
    } else if (distance <= 110 + extra) {
      result = JudgeResult.great;
    } else if (distance <= 190 + extra) {
      result = JudgeResult.good;
    } else {
      result = JudgeResult.miss; // 너무 일찍
    }

    _processHit(result);
  }

  void _processHit(JudgeResult result) {
    _lastJudge = result;
    _judgeDisplayTimer = 1.2;

    if (result == JudgeResult.miss) {
      _onMiss();
      return;
    }

    double mult;
    switch (result) {
      case JudgeResult.perfect:
        mult = GameConfig.perfectMult;
        perfectCount++;
        _addCombo();
        coinsEarned += GameConfig.perfectCoinBonus;
        break;
      case JudgeResult.great:
        mult = GameConfig.greatMult;
        greatCount++;
        _addCombo();
        break;
      case JudgeResult.good:
        mult = GameConfig.goodMult;
        goodCount++;
        _addCombo();
        break;
      default:
        mult = 0;
    }

    final comboDmgBonus = _comboDamageBonus();
    final baseDmg = playerData.atkValue * (1 + playerData.atkBonus);
    final damage = (baseDmg * mult * (1 + comboDmgBonus)).toInt();

    final wallBroken = _currentWall!.takeDamage(damage);

    switch (result) {
      case JudgeResult.perfect:
        AudioManager().play('perfect');
        _screenEffect.onPerfect();
        break;
      case JudgeResult.great:
        AudioManager().play('great');
        _screenEffect.onGreat();
        break;
      case JudgeResult.good:
        AudioManager().play('good');
        break;
      default: break;
    }

    _spawnParticle(result);
    _runner.punch(result);

    if (wallBroken) {
      AudioManager().play('wall_break');
      _screenEffect.onWallBreak();
      _onWallBroken();
    } else {
      _onWallNotBroken();
    }
  }

  void _addCombo() {
    currentCombo++;
    if (currentCombo > maxCombo) maxCombo = currentCombo;
    if (currentCombo % 5 == 0 && _lastJudge == JudgeResult.perfect) {
      if (currentHearts < maxHearts) currentHearts++;
    }
  }

  double _comboDamageBonus() {
    if (currentCombo >= 30) return GameConfig.combo30Bonus + playerData.comboMultiplierBonus;
    if (currentCombo >= 20) return GameConfig.combo20Bonus + playerData.comboMultiplierBonus;
    if (currentCombo >= 10) return GameConfig.combo10Bonus + playerData.comboMultiplierBonus;
    return playerData.comboMultiplierBonus;
  }

  void _onMiss() {
    missCount++;
    currentCombo = 0;
    currentHearts--;
    AudioManager().play('miss');
    _screenEffect.onMiss();
    _runner.hurt();

    _currentWall?.removeFromParent();
    _currentWall = null;
    gameState = GameState.running;

    if (currentHearts <= 0) _triggerGameOver();
  }

  void _onWallBroken() {
    currentStage++;
    coinsEarned += GameConfig.baseCoinPerStage +
        (currentCombo * GameConfig.comboCoinMultiplier * GameConfig.baseCoinPerStage).toInt();
    _currentWall = null;
    gameState = GameState.running;
  }

  void _onWallNotBroken() {
    _currentWall?.removeFromParent();
    _currentWall = null;
    _triggerGameOver();
  }

  void _spawnParticle(JudgeResult result) {
    if (_currentWall == null) return;
    final pos = Vector2(_currentWall!.position.x, _currentWall!.position.y + _currentWall!.size.y / 2);
    add(ParticleComponent(position: pos, judge: result));
  }

  void _triggerGameOver() {
    gameState = GameState.gameOver;
    _runner.die();

    Future.delayed(const Duration(milliseconds: 800), () {
      onGameOver(GameResult(
        stage: currentStage,
        maxCombo: maxCombo,
        perfectCount: perfectCount,
        greatCount: greatCount,
        goodCount: goodCount,
        missCount: missCount,
        coinsEarned: coinsEarned,
        isRevived: _revived,
      ));
    });
  }

  void revive() {
    if (_revived) return;
    _revived = true;
    currentHearts = 1;
    gameState = GameState.running;
    _runner.revive();
  }

  void togglePause() {
    if (gameState == GameState.running || gameState == GameState.wallApproaching) {
      gameState = GameState.paused;
      pauseEngine();
    } else if (gameState == GameState.paused) {
      gameState = GameState.running;
      resumeEngine();
    }
  }

  // HUD에서 참조
  JudgeResult get lastJudge => _lastJudge;
  double get judgeDisplayTimer => _judgeDisplayTimer;

  // 벽까지 남은 거리 (HUD 표시용)
  double? get distanceToWall {
    if (_currentWall == null) return null;
    final d = _currentWall!.position.x - (_runner.position.x + _runner.size.x);
    return d.clamp(0.0, double.infinity);
  }
}

extension PlayerDataGameExt on PlayerData {
  double get atkBonus => 0.0;
}
