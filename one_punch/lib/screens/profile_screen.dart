import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 프로필 헤더
          _ProfileHeader(
            nickname: player.nickname.isEmpty ? '용사' : player.nickname,
            onEditNickname: () => _showNicknameDialog(context, ref),
          ),
          const SizedBox(height: 20),

          // 게임 기록
          _StatCard(
            title: '📊 게임 기록',
            stats: [
              _StatRow('🏆 최고 스테이지', '${player.highestStage}'),
              _StatRow('🔥 최대 콤보', '${player.maxCombo}'),
              _StatRow('🎮 총 게임 수', '${player.totalGamesPlayed}'),
              _StatRow('👊 총 PERFECT 수', '${player.totalPerfectCount}'),
            ],
          ),
          const SizedBox(height: 12),

          // 강화 현황
          _StatCard(
            title: '⚔️ 강화 현황',
            stats: [
              _StatRow('💥 ATK 레벨', 'Lv.${player.atkLevel}  (${player.atkValue} 데미지)'),
              _StatRow('⚡ SPD 레벨', 'Lv.${player.spdLevel}'),
              _StatRow('🔥 COMBO 레벨', 'Lv.${player.comboLevel}'),
              _StatRow('❤️ HP 레벨', 'Lv.${player.hpLevel}  (하트 ${player.maxHearts}개)'),
            ],
          ),
          const SizedBox(height: 12),

          // 랭킹 (더미)
          _RankingSection(),
          const SizedBox(height: 12),

          // 업적
          _AchievementSection(player: player),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showNicknameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(playerProvider).nickname,
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundAlt,
        title: const Text('닉네임 변경', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLength: 10,
          decoration: InputDecoration(
            hintText: '닉네임 입력 (최대 10자)',
            hintStyle: const TextStyle(color: AppColors.textDim),
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            counterStyle: const TextStyle(color: AppColors.textDim),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.textDim)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(playerProvider.notifier).setNickname(name);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String nickname;
  final VoidCallback onEditNickname;
  const _ProfileHeader({required this.nickname, required this.onEditNickname});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.accent,
              child: const Text('👤', style: TextStyle(fontSize: 40)),
            ),
            GestureDetector(
              onTap: onEditNickname,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onEditNickname,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nickname,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit, color: AppColors.textDim, size: 14),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final List<_StatRow> stats;
  const _StatCard({required this.title, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...stats.map((s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.label, style: const TextStyle(color: AppColors.textDim, fontSize: 13)),
                Text(s.value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _StatRow {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);
}

class _RankingSection extends StatelessWidget {
  final List<_RankEntry> _dummy = const [
    _RankEntry(rank: 1, name: '원펀왕',   stage: 234, combo: 312),
    _RankEntry(rank: 2, name: '퍼펙트머신', stage: 198, combo: 290),
    _RankEntry(rank: 3, name: '달리기신',  stage: 177, combo: 245),
    _RankEntry(rank: 4, name: '마법사킹',  stage: 155, combo: 210),
    _RankEntry(rank: 5, name: '철벽파괴',  stage: 133, combo: 180),
  ];

  _RankingSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏆 스테이지 랭킹', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._dummy.map((e) => _RankRow(entry: e)),
        ],
      ),
    );
  }
}

class _RankEntry {
  final int rank;
  final String name;
  final int stage;
  final int combo;
  const _RankEntry({required this.rank, required this.name, required this.stage, required this.combo});
}

class _RankRow extends StatelessWidget {
  final _RankEntry entry;
  const _RankRow({required this.entry});

  Color get _rankColor {
    if (entry.rank == 1) return AppColors.gold;
    if (entry.rank == 2) return AppColors.silver;
    if (entry.rank == 3) return const Color(0xFFCD7F32);
    return AppColors.textDim;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(color: _rankColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(entry.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          Text('Stage ${entry.stage}', style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
          const SizedBox(width: 12),
          Text('콤보 ${entry.combo}', style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AchievementSection extends StatelessWidget {
  final dynamic player;
  const _AchievementSection({required this.player});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      _Achievement(icon: '🏅', name: '첫 번째 벽',    desc: '첫 벽 파괴',               done: player.totalGamesPlayed >= 1),
      _Achievement(icon: '🏅', name: '퍼펙트 머신',  desc: 'PERFECT 100회',             done: player.totalPerfectCount >= 100),
      _Achievement(icon: '🏅', name: '콤보 마스터',  desc: '콤보 50 달성',              done: player.maxCombo >= 50),
      _Achievement(icon: '🏅', name: '마라토너',     desc: '게임 50회 플레이',           done: player.totalGamesPlayed >= 50),
      _Achievement(icon: '🏅', name: 'Stage 클리어', desc: 'Stage 10 돌파',             done: player.highestStage >= 10),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏅 업적', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...achievements.map((a) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Text(a.icon, style: TextStyle(fontSize: 20, color: a.done ? null : const Color(0x44FFFFFF))),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.name, style: TextStyle(color: a.done ? Colors.white : AppColors.textDim, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(a.desc, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
                    ],
                  ),
                ),
                Icon(a.done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: a.done ? AppColors.great : AppColors.textDim, size: 20),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _Achievement {
  final String icon;
  final String name;
  final String desc;
  final bool done;
  const _Achievement({required this.icon, required this.name, required this.desc, required this.done});
}
