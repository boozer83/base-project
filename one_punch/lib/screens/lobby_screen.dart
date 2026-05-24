import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../utils/constants.dart';
import '../models/character_data.dart';
import 'game_screen.dart';
import 'upgrade_screen.dart';
import 'shop_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen>
    with TickerProviderStateMixin {
  int _tabIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerProvider.notifier).addStamina(0);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final character =
        allCharacters[player.selectedCharacterIndex.clamp(0, allCharacters.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _HomeTab(
            player: player,
            character: character,
            pulseAnim: _pulseAnim,
            onStartGame: _startGame,
          ),
          const UpgradeScreen(),
          const ChatScreen(),
          const ShopScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    );
  }

  Future<void> _startGame() async {
    final used = await ref.read(playerProvider.notifier).useStamina();
    if (!used) {
      _showNoStaminaDialog();
      return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  void _showNoStaminaDialog() {
    final player = ref.read(playerProvider);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('⚡ 스태미나 부족', style: TextStyle(color: Colors.white)),
        content: Text(
          '${player.minutesUntilNextStamina}분 후 스태미나가 1 회복돼요.\n\n광고를 보고 5 회복하시겠어요?',
          style: const TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.textDim)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(playerProvider.notifier).addStamina(5);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⚡ 스태미나 +5 회복!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text('📺 광고 보기', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 홈 탭 – 가로화면 최적화 레이아웃
// ─────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final dynamic player;
  final CharacterData character;
  final Animation<double> pulseAnim;
  final VoidCallback onStartGame;

  const _HomeTab({
    required this.player,
    required this.character,
    required this.pulseAnim,
    required this.onStartGame,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 상단 상태바 (코인·젬·닉네임)
          _TopBar(player: player),
          // 메인 콘텐츠: 좌(캐릭터) + 우(정보·버튼)
          Expanded(
            child: Row(
              children: [
                // ── 좌측: 캐릭터 디스플레이 ──────────
                Expanded(
                  flex: 4,
                  child: _CharacterDisplay(character: character),
                ),
                // ── 우측: 정보 + 버튼 ──────────────
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 캐릭터 이름
                        Text(
                          character.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: character.color,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          character.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textDim,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // 스태미나
                        _StaminaBar(player: player),
                        const SizedBox(height: 16),
                        // 최고 기록
                        _StatRow(player: player),
                        const SizedBox(height: 16),
                        // 게임 시작 버튼
                        AnimatedBuilder(
                          animation: pulseAnim,
                          builder: (_, __) => Transform.scale(
                            scale: pulseAnim.value,
                            child: ElevatedButton(
                              onPressed: onStartGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 8,
                                shadowColor: AppColors.primary.withOpacity(0.5),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('👊', style: TextStyle(fontSize: 22)),
                                  SizedBox(width: 10),
                                  Text(
                                    'GAME START',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final dynamic player;
  const _TopBar({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.backgroundAlt, AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // 닉네임
          const Text('👊 ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              player.nickname.isEmpty ? '용사' : player.nickname,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 코인
          _CurrencyChip(icon: '⭐', value: '${player.coins}', color: AppColors.gold),
          const SizedBox(width: 8),
          // 젬
          _CurrencyChip(
              icon: '💎', value: '${player.gems}', color: const Color(0xFF80D8FF)),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final String icon;
  final String value;
  final Color color;
  const _CurrencyChip({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _CharacterDisplay extends StatelessWidget {
  final CharacterData character;
  const _CharacterDisplay({required this.character});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: character.color.withOpacity(0.12),
              border: Border.all(color: character.color.withOpacity(0.5), width: 3),
              boxShadow: [
                BoxShadow(color: character.color.withOpacity(0.35), blurRadius: 28),
              ],
            ),
            child: Center(
              child: Text(character.emoji, style: const TextStyle(fontSize: 58)),
            ),
          ),
          const SizedBox(height: 10),
          // 잠금 해제 레벨 표시
          if (character.unlockStage > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: character.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: character.color.withOpacity(0.3)),
              ),
              child: Text(
                'STAGE ${character.unlockStage} 해금',
                style: TextStyle(color: character.color, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class _StaminaBar extends StatelessWidget {
  final dynamic player;
  const _StaminaBar({required this.player});

  @override
  Widget build(BuildContext context) {
    final ratio = player.stamina / GameConfig.maxStamina;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('⚡ 스태미나',
                style: TextStyle(color: AppColors.textLight, fontSize: 12)),
            Text('${player.stamina} / ${GameConfig.maxStamina}',
                style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(
              ratio > 0.5 ? Colors.greenAccent : Colors.orangeAccent,
            ),
          ),
        ),
        if (player.stamina < GameConfig.maxStamina)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              '${player.minutesUntilNextStamina}분 후 +1 회복',
              style: const TextStyle(color: AppColors.textDim, fontSize: 10),
            ),
          ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final dynamic player;
  const _StatRow({required this.player});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: '🏆',
            label: 'BEST',
            value: 'Stage ${player.highestStage}',
            color: AppColors.gold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            icon: '🔥',
            label: 'COMBO',
            value: '${player.maxCombo}',
            color: AppColors.great,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, letterSpacing: 1)),
              Text(value,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// 하단 네비게이션 (가로화면용 간결 버전)
// ─────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.backgroundAlt,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textDim,
      selectedFontSize: 10,
      unselectedFontSize: 9,
      iconSize: 18,
      items: const [
        BottomNavigationBarItem(icon: Text('🏠', style: TextStyle(fontSize: 18)), label: '홈'),
        BottomNavigationBarItem(icon: Text('⚔️', style: TextStyle(fontSize: 18)), label: '강화'),
        BottomNavigationBarItem(icon: Text('💬', style: TextStyle(fontSize: 18)), label: '채팅'),
        BottomNavigationBarItem(icon: Text('🛒', style: TextStyle(fontSize: 18)), label: '상점'),
        BottomNavigationBarItem(icon: Text('👤', style: TextStyle(fontSize: 18)), label: '프로필'),
      ],
    );
  }
}
