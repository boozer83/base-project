import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../utils/constants.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return SafeArea(
      child: Column(
        children: [
          const _ScreenTitle(title: '🛒 상점'),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  // 탭 바
                  const TabBar(
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textDim,
                    tabs: [
                      Tab(text: '💎 젬 구매'),
                      Tab(text: '🎰 가챠'),
                      Tab(text: '🎁 패키지'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _GemTab(coins: player.coins, gems: player.gems),
                        _GachaTab(gems: player.gems, ref: ref),
                        _PackageTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 젬 구매 탭 ─────────────────────────────────
class _GemTab extends StatelessWidget {
  final int coins;
  final int gems;
  const _GemTab({required this.coins, required this.gems});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 보유 재화 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CurrencyBadge(icon: '⭐', label: '코인', value: '$coins'),
            const SizedBox(width: 16),
            _CurrencyBadge(icon: '💎', label: '젬', value: '$gems'),
          ],
        ),
        const SizedBox(height: 20),
        // 상품 목록
        const _ShopItem(
          icon: '💎',
          name: '젬 소량팩',
          desc: '젬 60개',
          price: '₩1,100',
          badge: null,
        ),
        const _ShopItem(
          icon: '💎💎',
          name: '젬 중량팩',
          desc: '젬 320개 (+20 보너스)',
          price: '₩5,500',
          badge: '인기',
        ),
        const _ShopItem(
          icon: '💎💎💎',
          name: '젬 대량팩',
          desc: '젬 700개 (+100 보너스)',
          price: '₩11,000',
          badge: null,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Text('📺', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('무료 젬 획득', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('광고 시청 1회당 젬 2개 (하루 5회)', style: TextStyle(color: AppColors.textDim, fontSize: 12)),
                  ],
                ),
              ),
              Text('광고 보기', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 가챠 탭 ────────────────────────────────────
class _GachaTab extends StatelessWidget {
  final int gems;
  final WidgetRef ref;
  const _GachaTab({required this.gems, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 가챠 일러스트
        Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accentLight, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎰', style: TextStyle(fontSize: 52)),
                SizedBox(height: 8),
                Text(
                  '캐릭터 & 장비 가챠',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '100회 내 SR 보장',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 확률 정보
        const _ProbabilityInfo(),
        const SizedBox(height: 16),
        // 뽑기 버튼
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pull(context, 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundAlt,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Column(
                  children: [
                    Text('1회 뽑기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('💎 100', style: TextStyle(color: AppColors.good, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pull(context, 10),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Column(
                  children: [
                    Text('10연 뽑기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('💎 900 (10%↓)', style: TextStyle(color: AppColors.gold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '주간 무료 뽑기 1회 (매주 월요일 초기화)',
            style: const TextStyle(color: AppColors.textDim, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _pull(BuildContext context, int count) {
    final cost = count == 1 ? 100 : 900;
    if (gems < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('💎 젬이 부족합니다!')),
      );
      return;
    }
    // TODO: 실제 가챠 로직 구현
    _showGachaResult(context, count);
  }

  void _showGachaResult(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundAlt,
        title: const Text('🎰 가챠 결과', style: TextStyle(color: Colors.white)),
        content: const Text(
          '🥋 원펀남 (R등급)',
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _ProbabilityInfo extends StatelessWidget {
  const _ProbabilityInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          _ProbRow('⭐⭐⭐ SR (전설)', '2.0%', AppColors.gold),
          _ProbRow('⭐⭐ R (희귀)',   '18.0%', AppColors.great),
          _ProbRow('⭐ N (일반)',     '80.0%', AppColors.textDim),
        ],
      ),
    );
  }
}

class _ProbRow extends StatelessWidget {
  final String label;
  final String prob;
  final Color color;
  const _ProbRow(this.label, this.prob, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 13)),
          Text(prob,  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─── 패키지 탭 ───────────────────────────────────
class _PackageTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PackageCard(
          title: '🌟 스타터팩',
          desc: 'SR 캐릭터 1개 + 💎100',
          price: '₩3,300',
          badge: '최초 1회',
          badgeColor: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _PackageCard(
          title: '👑 배틀패스',
          desc: '전용 스킨 + 2배 코인 + 매일 💎10',
          price: '₩9,900/월',
          badge: '인기',
          badgeColor: AppColors.gold,
        ),
        const SizedBox(height: 12),
        _PackageCard(
          title: '⚡ 스태미나팩',
          desc: '스태미나 MAX 회복권 ×5',
          price: '₩1,100',
          badge: null,
          badgeColor: Colors.transparent,
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String title;
  final String desc;
  final String price;
  final String? badge;
  final Color badgeColor;

  const _PackageCard({
    required this.title,
    required this.desc,
    required this.price,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textDim, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  final String icon;
  final String name;
  final String desc;
  final String price;
  final String? badge;

  const _ShopItem({required this.icon, required this.name, required this.desc, required this.price, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                          child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ],
                    ],
                  ),
                  Text(desc, style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyBadge extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _CurrencyBadge({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
      ),
    );
  }
}
