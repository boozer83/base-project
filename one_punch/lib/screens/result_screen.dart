import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_result.dart';
import '../utils/constants.dart';
import 'game_screen.dart';
import 'lobby_screen.dart';

class ResultScreen extends ConsumerWidget {
  final GameResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 등급
              _GradeBadge(grade: result.grade),
              const SizedBox(height: 24),

              // 결과 카드
              _ResultCard(result: result),
              const SizedBox(height: 32),

              // 획득 코인
              _CoinEarnedBanner(coins: result.coinsEarned),
              const SizedBox(height: 32),

              const Spacer(),

              // 버튼들
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentLight,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '🔄 다시 하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LobbyScreen()),
                    (route) => false,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textLight,
                    side: const BorderSide(color: AppColors.textDim),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '로비로 돌아가기',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final String grade;
  const _GradeBadge({required this.grade});

  Color _gradeColor() {
    switch (grade) {
      case 'S': return AppColors.gold;
      case 'A': return AppColors.great;
      case 'B': return AppColors.good;
      case 'C': return Colors.orange;
      default:  return AppColors.textDim;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor();
    return Column(
      children: [
        Text(
          'RESULT',
          style: TextStyle(
            color: AppColors.textDim,
            fontSize: 13,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20)],
          ),
          child: Center(
            child: Text(
              grade,
              style: TextStyle(
                color: color,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final GameResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _Row('🗺️ 도달 스테이지', '${result.stage}'),
          const Divider(color: Colors.white12),
          _Row('🔥 최대 콤보', '${result.maxCombo}'),
          const Divider(color: Colors.white12),
          _Row('👊 PERFECT', '${result.perfectCount}', color: AppColors.perfect),
          _Row('✊ GREAT',   '${result.greatCount}',   color: AppColors.great),
          _Row('🤜 GOOD',   '${result.goodCount}',    color: AppColors.good),
          _Row('❌ MISS',   '${result.missCount}',    color: AppColors.miss),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Row(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 15)),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinEarnedBanner extends StatelessWidget {
  final int coins;
  const _CoinEarnedBanner({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gold.withOpacity(0.15), AppColors.gold.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            '+$coins 코인 획득!',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
