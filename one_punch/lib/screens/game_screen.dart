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

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initGame();
  }

  void _initGame() {
    final player = ref.read(playerProvider);
    _game = OnePunchGame(
      playerData: player,
      onGameOver: _handleGameOver,
      onReviveRequested: _handleReviveRequested,
    );
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
    // 광고 시청 후 부활 (현재는 즉시 부활)
    final player = ref.read(playerProvider);
    if (!player.canWatchAd) {
      _goToResult();
      return;
    }
    setState(() => _showReviveDialog = false);
    _game?.revive();
    // 실제 앱에서는 여기서 광고 표시
    ref.read(playerProvider.notifier).addStamina(0); // 광고 카운트 증가용 트리거
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
      MaterialPageRoute(
        builder: (_) => ResultScreen(result: result),
      ),
    );
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

          // ── 부활 다이얼로그 ──────────────────────
          if (_showReviveDialog && _pendingResult != null)
            _ReviveDialog(
              stage: _pendingResult!.stage,
              onRevive: _onRevive,
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
  final VoidCallback onGiveUp;

  const _ReviveDialog({
    required this.stage,
    required this.onRevive,
    required this.onGiveUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
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
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💀', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stage $stage 도달',
                style: const TextStyle(color: AppColors.textLight, fontSize: 16),
              ),
              const SizedBox(height: 24),
              // 광고 부활 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRevive,
                  icon: const Text('📺', style: TextStyle(fontSize: 20)),
                  label: const Text(
                    '광고 보고 부활!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onGiveUp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDim,
                    side: const BorderSide(color: AppColors.textDim),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text('계속하기', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onQuit,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text('나가기', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
