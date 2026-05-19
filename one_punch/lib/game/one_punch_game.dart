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
import 'components/timing_bar_component.dart';
import 'components/hud_component.dart';
import 'components/screen_effect_component.dart';

enum GameState { waiting, running, wallApproaching, judging, gameOver, paused }
enum JudgeResult { perfect, great, good, miss, none }

class OnePunchGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  // ── 외부에서 주입되는 플레이어 데이터 ──────────────
  final PlayerData playerData;
  final void Function(GameResult) onGameOver;
  final void Function() onReviveRequested;

  // ── 게임 상태 ───────────────────────────────────
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

  // ── 현재 벽 ────────────────────────────────────
  WallComponent? _currentWall;
  TimingBarComponent? _timingBar;

  // ── 컴포넌트 참조 ─────────────────────────────────
  late RunnerComponent _runner;
  // ignore: unused_field
  late HudComponent _hud;
  // ignore: unused_field
  late BackgroundComponent _background;
  late ScreenEffectComponent _screenEffect;

  // ── 판정 표시 타이머 ──────────────────────────────
  JudgeResult _lastJudge = JudgeResult.none;
  double _judgeDisplayTimer = 0;

  // ── 벽 스케줄 ─────────────────────────────────────
  double _wallSpawnTimer = 0;
  double _wallSpawnInterval = 2.5; // 초기 2.5초 (느리게 시작)

  OnePunchGame({
    required this.playerData,
    required this.onGameOver,
    required this.onReviveRequested,
  });

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 오디오 초기화
    await AudioManager().init();
    AudioManager().play('game_start');

    currentHearts = playerData.maxHearts;
    maxHearts = playerData.maxHearts;

    // 배경
    _background = BackgroundComponent();
    await add(_background);

    // 지면
    await add(GroundComponent());

    // 캐릭터
    _runner = RunnerComponent(
      characterIndex: playerData.selectedCharacterIndex,
    );
    await add(_runner);

    // HUD
    _hud = HudComponent(game: this);
    await add(_hud);

    // 스크린 이펙트 (최상위)
    _screenEffect = ScreenEffectComponent();
    await add(_screenEffect);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState == GameState.paused || gameState == GameState.gameOver) return;

    // 히트스탑 중엔 게임 로직 일시 정지
    if (_screenEffect.isHitstop) return;

    // 판정 표시 타이머
    if (_judgeDisplayTimer > 0) {
      _judgeDisplayTimer -= dt;
      if (_judgeDisplayTimer <= 0) _lastJudge = JudgeResult.none;
    }

    // 벽 스폰 스케줄링
    if (_currentWall == null && gameState == GameState.running) {
      _wallSpawnTimer += dt;
      if (_wallSpawnTimer >= _wallSpawnInterval) {
        _spawnWall();
        _wallSpawnTimer = 0;
      }
    }

    // 벽 접근 감지
    if (_currentWall != null && gameState == GameState.wallApproaching) {
      final wallX = _currentWall!.position.x;
      final runnerX = _runner.position.x + _runner.size.x;

      // 타이밍 바 등장: 벽이 화면 오른쪽 끝에서 나타나면
      if (wallX < size.x * 0.75 && _timingBar == null) {
        _showTimingBar();
      }

      // 벽이 캐릭터에 닿으면 → 자동 MISS 처리
      if (wallX <= runnerX + 10) {
        _processHit(JudgeResult.miss);
      }
    }
  }

  // ── 벽 생성 ────────────────────────────────────
  void _spawnWall() {
    final wallData = WallConfig.forStage(currentStage);
    final hp = (wallData.baseHp * (1 + currentStage * 0.05)).toInt();
    // 스테이지마다 속도 가속: 1스테이지 ~160, 50스테이지 ~560, 100스테이지 ~960
    final speed = wallData.baseSpeed + currentStage * 8.0;

    _currentWall = WallComponent(
      wallType: wallData.type,
      hp: hp,
      speed: speed,
      gameSize: size,
    );
    add(_currentWall!);
    gameState = GameState.wallApproaching;

    // 스테이지가 오를수록 스폰 간격 약간 감소
    // 스테이지 오를수록 간격 감소: 1→2.5s, 25→1.5s, 50→1.0s, 100→0.6s
    _wallSpawnInterval = (2.5 - currentStage * 0.03).clamp(0.6, 2.5);
  }

  // ── 타이밍 바 표시 ──────────────────────────────
  void _showTimingBar() {
    _timingBar = TimingBarComponent(gameSize: size);
    add(_timingBar!);
  }

  // ── 터치 처리 ────────────────────────────────────
  @override
  void onTapDown(TapDownEvent event) {
    final tapPos = event.canvasPosition;

    // 일시정지 버튼 탭 체크 (우상단 영역)
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

    if (gameState == GameState.wallApproaching) {
      _judgeTouch();
    }
  }

  void _judgeTouch() {
    if (_timingBar == null || _currentWall == null) return;

    final offset = _timingBar!.currentOffset; // 0에 가까울수록 PERFECT
    JudgeResult result;
    final spdBonus = playerData.spdBonus;

    if (offset.abs() <= GameConfig.perfectWindow + spdBonus) {
      result = JudgeResult.perfect;
    } else if (offset.abs() <= GameConfig.greatWindow + spdBonus) {
      result = JudgeResult.great;
    } else if (offset.abs() <= GameConfig.goodWindow + spdBonus) {
      result = JudgeResult.good;
    } else {
      result = JudgeResult.miss;
    }

    _processHit(result);
  }

  void _processHit(JudgeResult result) {
    _lastJudge = result;
    _judgeDisplayTimer = 1.2;

    // 타이밍 바 제거
    _timingBar?.removeFromParent();
    _timingBar = null;

    if (result == JudgeResult.miss) {
      _onMiss();
      return;
    }

    // 데미지 계산
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

    // 판정 사운드 + 화면 이펙트
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

    // 파티클 이펙트
    _spawnParticle(result);

    // 캐릭터 펀치 애니메이션
    _runner.punch(result);

    if (wallBroken) {
      AudioManager().play('wall_break');
      _screenEffect.onWallBreak();
      _onWallBroken();
    } else {
      // 데미지 부족 → 즉시 게임오버
      _onWallNotBroken();
    }
  }

  void _addCombo() {
    currentCombo++;
    if (currentCombo > maxCombo) maxCombo = currentCombo;

    // PERFECT 5연속이면 하트 회복
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

    if (currentHearts <= 0) {
      _triggerGameOver();
    }
  }

  void _onWallBroken() {
    currentStage++;
    coinsEarned += GameConfig.baseCoinPerStage +
        (currentCombo * GameConfig.comboCoinMultiplier * GameConfig.baseCoinPerStage).toInt();
    _currentWall = null;
    gameState = GameState.running;
  }

  void _onWallNotBroken() {
    // 데미지 부족 → 즉시 게임오버
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

  // ── 부활 처리 ────────────────────────────────────
  void revive() {
    if (_revived) return;
    _revived = true;
    currentHearts = 1;
    gameState = GameState.running;
    _runner.revive();
  }

  // ── 일시정지 ─────────────────────────────────────
  void togglePause() {
    if (gameState == GameState.running || gameState == GameState.wallApproaching) {
      gameState = GameState.paused;
      pauseEngine();
    } else if (gameState == GameState.paused) {
      gameState = GameState.running;
      resumeEngine();
    }
  }

  // ── HUD에서 참조할 getter ─────────────────────────
  JudgeResult get lastJudge => _lastJudge;
  double get judgeDisplayTimer => _judgeDisplayTimer;
}

extension PlayerDataGameExt on PlayerData {
  double get atkBonus => 0.0; // 추후 캐릭터별 보너스 적용
}
