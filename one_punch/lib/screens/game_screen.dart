import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/one_punch_game.dart';
import '../models/game_result.dart';
import '../providers/player_provider.dart';
import '../utils/constants.dart';
import 'result_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  OnePunchGame? _game;
  bool _showReviveDialog = false;
  GameResult? _pendingResult;

  // 게임 위젯 재생성을 강제하기 위한 키
  Key _gameKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _buildGame();
  }

  void _buildGame() {
    final player = ref.read(playerProvider);
    _game = OnePunchGame(
      playerData: player,
      onGameOver: _handleGameOver,
      onReviveRequested: _handleReviveRequested,
    );
    _gameKey = UniqueKey();
    _showReviveDialog = false;
    _pendingResult = null;
  }

  void _handleGameOver(GameResult result) {
    if (!mounted) return;
    setState(() {
      _pendingResult = result;
      _showReviveDialog = true;
    });
  }

  void _handleReviveRequested() {}

  Future<void> _onRevive() async {
    final player = ref.read(playerProvider);
    if (!player.canWatchAd) {
      _goToResult();
      return;
    }
    setState(() => _showReviveDialog = false);
    _game?.revive();
    ref.read(playerProvider.notifier).addStamina(0);
  }

  void _goToResult() {
    if (_pendingResult == null) return;
    setState(() => _showReviveDialog = false);

    final result = _pendingResult!;
    ref.read(playerProvider.notifier).saveGameResult(
      stage: result.stage,
      combo: result.maxCombo,
      coins: result.coinsEarned,
      perfectCount: result.perfectCount,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  // 결과 화면 대신 바로 재시작 (스태미나 1 추가 소모)
  Future<void> _restartGame() async {
    final used = await ref.read(playerProvider.notifier).useStamina();
    if (!used) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚡ 스태미나가 부족해요!')),
      );
      _goToResult();
      return;
    }
    if (!mounted) return;
    setState(() => _buildGame());
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Flame 게임 캔버스 ────────────────────
          if (_game != null)
            GameWidget(
              key: _gameKey,
              game: _game!,
              overlayBuilderMap: {
                'pause': (context, game) => _PauseOverlay(
                  onResume: () {
                    (_game as OnePunchGame).togglePause();
                    _game!.overlays.remove('pause');
                  },
                  onQuit: () => Navigator.of(context).pop(),
                ),
              },
            ),

          // ── 부활/재시작 다이얼로그 ────────────────
          if (_showReviveDialog && _pendingResult != null)
            _ReviveDialog(
              stage: _pendingResult!.stage,
              onRevive: _onRevive,
              onRestart: _restartGame,
              onGiveUp: _goToResult,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 부활 다이얼로그
// ─────────────────────────────────────────────────
class _ReviveDialog extends StatelessWidget {
  final int stage;
  final VoidCallback onRevive;
  final VoidCallback onRestart;
  final VoidCallback onGiveUp;

  const _ReviveDialog({
    required this.stage,
    required this.onRevive,
    required this.onRestart,
    required this.onGiveUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: AppColors.backgroundAlt,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💀', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 10),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Stage $stage 도달',
                style: const TextStyle(color: AppColors.textLight, fontSize: 15),
              ),
              const SizedBox(height: 20),
              // 광고 부활
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRevive,
                  icon: const Text('📺', style: TextStyle(fontSize: 18)),
                  label: const Text('광고 보고 부활!',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 다시 시작 (스태미나 소모)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Text('🔄', style: TextStyle(fontSize: 18)),
                  label: const Text('다시 시작 (⚡1)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onGiveUp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDim,
                    side: const BorderSide(color: AppColors.textDim),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('결과 확인'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 일시정지 오버레이
// ─────────────────────────────────────────────────
class _PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onQuit;

  const _PauseOverlay({required this.onResume, required this.onQuit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.65),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('계속하기', style: TextStyle(fontSize: 17)),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onQuit,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('나가기', style: TextStyle(fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}
