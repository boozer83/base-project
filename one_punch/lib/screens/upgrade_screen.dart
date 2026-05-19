import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../utils/constants.dart';

class UpgradeScreen extends ConsumerWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return SafeArea(
      child: Column(
        children: [
          const _ScreenTitle(title: '⚔️ 강화'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _UpgradeCard(
                  icon: '💥',
                  label: 'ATK',
                  description: '벽에 주는 데미지',
                  level: player.atkLevel,
                  maxLevel: 50,
                  currentValue: '${player.atkValue} 데미지',
                  cost: UpgradeCost.atk(player.atkLevel),
                  coins: player.coins,
                  color: AppColors.primary,
                  onUpgrade: () async {
                    final ok = await ref.read(playerProvider.notifier).upgradeAtk();
                    if (!ok && context.mounted) {
                      _showToast(context, '코인이 부족하거나 최대 레벨입니다');
                    }
                  },
                ),
                const SizedBox(height: 12),
                _UpgradeCard(
                  icon: '⚡',
                  label: 'SPD',
                  description: '판정 타이밍 범위 보너스',
                  level: player.spdLevel,
                  maxLevel: 30,
                  currentValue: '+${(player.spdBonus * 100).toStringAsFixed(1)}% 범위',
                  cost: UpgradeCost.spd(player.spdLevel),
                  coins: player.coins,
                  color: AppColors.great,
                  onUpgrade: () async {
                    final ok = await ref.read(playerProvider.notifier).upgradeSpd();
                    if (!ok && context.mounted) {
                      _showToast(context, '코인이 부족하거나 최대 레벨입니다');
                    }
                  },
                ),
                const SizedBox(height: 12),
                _UpgradeCard(
                  icon: '🔥',
                  label: 'COMBO',
                  description: '연속 히트 추가 데미지',
                  level: player.comboLevel,
                  maxLevel: 30,
                  currentValue: '+${(player.comboMultiplierBonus * 100).toStringAsFixed(1)}% 보너스',
                  cost: UpgradeCost.combo(player.comboLevel),
                  coins: player.coins,
                  color: AppColors.perfect,
                  onUpgrade: () async {
                    final ok = await ref.read(playerProvider.notifier).upgradeCombo();
                    if (!ok && context.mounted) {
                      _showToast(context, '코인이 부족하거나 최대 레벨입니다');
                    }
                  },
                ),
                const SizedBox(height: 12),
                _UpgradeCard(
                  icon: '❤️',
                  label: 'HP',
                  description: '최대 하트 수',
                  level: player.hpLevel,
                  maxLevel: 20,
                  currentValue: '하트 ${player.maxHearts}개',
                  cost: UpgradeCost.hp(player.hpLevel),
                  coins: player.coins,
                  color: AppColors.heartFull,
                  onUpgrade: () async {
                    final ok = await ref.read(playerProvider.notifier).upgradeHp();
                    if (!ok && context.mounted) {
                      _showToast(context, '코인이 부족하거나 최대 레벨입니다');
                    }
                  },
                ),
                const SizedBox(height: 24),
                // 보유 코인
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                    ),
                    child: Text(
                      '⭐ 보유 코인: ${player.coins}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final String icon;
  final String label;
  final String description;
  final int level;
  final int maxLevel;
  final String currentValue;
  final int cost;
  final int coins;
  final Color color;
  final VoidCallback onUpgrade;

  const _UpgradeCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.level,
    required this.maxLevel,
    required this.currentValue,
    required this.cost,
    required this.coins,
    required this.color,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isMax = level >= maxLevel;
    final canAfford = coins >= cost;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Lv.$level',
                            style: TextStyle(color: color, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      description,
                      style: const TextStyle(color: AppColors.textDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // 강화 버튼
              ElevatedButton(
                onPressed: isMax ? null : onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMax
                      ? Colors.grey[700]
                      : canAfford
                          ? color
                          : Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isMax ? 'MAX' : '강화',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 레벨 진행 바
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: level / maxLevel,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentValue,
                style: const TextStyle(color: AppColors.textLight, fontSize: 13),
              ),
              if (!isMax)
                Text(
                  '⭐ $cost',
                  style: TextStyle(
                    color: canAfford ? AppColors.gold : AppColors.miss,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                const Text('최대 레벨', style: TextStyle(color: AppColors.textDim, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScreenTitle extends StatelessWidget {
  final String title;
  const _ScreenTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
