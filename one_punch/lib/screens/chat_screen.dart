import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../utils/constants.dart';

// ── 더미 채팅 메시지 모델 ──────────────────────────
class ChatMessage {
  final String userId;
  final String nickname;
  final String message;
  final DateTime time;
  final bool isMe;

  const ChatMessage({
    required this.userId,
    required this.nickname,
    required this.message,
    required this.time,
    this.isMe = false,
  });
}

// ── 더미 DM 목록 모델 ──────────────────────────────
class DmConversation {
  final String userId;
  final String nickname;
  final String lastMessage;
  final DateTime time;
  final int unread;

  const DmConversation({
    required this.userId,
    required this.nickname,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
  });
}

// ── 전역 채팅 더미 데이터 ──────────────────────────
final _dummyMessages = [
  ChatMessage(userId: 'u1', nickname: '원펀왕',  message: 'Stage 47 클리어!!! 🔥', time: DateTime.now().subtract(const Duration(minutes: 3))),
  ChatMessage(userId: 'u2', nickname: '마법사킹', message: '보스벽 너무 어렵다ㅠㅠ', time: DateTime.now().subtract(const Duration(minutes: 2))),
  ChatMessage(userId: 'u3', nickname: '달리기신', message: '콤보 150 달성 ㅋㅋㅋ', time: DateTime.now().subtract(const Duration(minutes: 1))),
  ChatMessage(userId: 'u4', nickname: '철벽파괴',  message: '강화 ATK Lv.30 찍었다!', time: DateTime.now().subtract(const Duration(seconds: 40))),
  ChatMessage(userId: 'u5', nickname: '퍼펙트머신', message: 'PERFECT 연속 50회 ㄷㄷ', time: DateTime.now().subtract(const Duration(seconds: 20))),
];

final _dummyDms = [
  DmConversation(userId: 'u1', nickname: '원펀왕',   lastMessage: '같이 랭킹 도전해볼까요?', time: DateTime.now().subtract(const Duration(hours: 1)), unread: 2),
  DmConversation(userId: 'u3', nickname: '달리기신',  lastMessage: '콤보 팁 알려드릴게요!',    time: DateTime.now().subtract(const Duration(hours: 3)), unread: 0),
];

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = List.from(_dummyMessages);
  int _tabIndex = 0; // 0: 전체, 1: 귓말

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final player = ref.read(playerProvider);
    setState(() {
      _messages.add(ChatMessage(
        userId: 'me',
        nickname: player.nickname.isEmpty ? '용사' : player.nickname,
        message: text,
        time: DateTime.now(),
        isMe: true,
      ));
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 탭 헤더
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                _TabBtn(label: '🌍 전체 채팅', selected: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
                _TabBtn(label: '💌 귓말', selected: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
              ],
            ),
          ),
          Expanded(
            child: _tabIndex == 0 ? _GlobalChat() : _DmList(),
          ),
        ],
      ),
    );
  }

  Widget _GlobalChat() {
    return Column(
      children: [
        // 채팅 목록
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _ChatBubble(msg: _messages[i]),
          ),
        ),
        // 입력창
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white10)),
            color: AppColors.backgroundAlt,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    hintStyle: const TextStyle(color: AppColors.textDim),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.07),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _DmList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ..._dummyDms.map((dm) => _DmItem(
          dm: dm,
          onTap: () => _openDm(dm),
        )),
        const SizedBox(height: 16),
        Center(
          child: Text(
            '귓말을 보내려면 전체 채팅에서 닉네임을 탭하세요',
            style: const TextStyle(color: AppColors.textDim, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _openDm(DmConversation dm) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DmScreen(dm: dm)),
    );
  }
}

// ─── 채팅 버블 ────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe;
    final timeStr = '${msg.time.hour.toString().padLeft(2,'0')}:${msg.time.minute.toString().padLeft(2,'0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            // 아바타
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accent,
              child: Text(msg.nickname[0], style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(width: 6),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    msg.nickname,
                    style: const TextStyle(color: AppColors.textDim, fontSize: 11),
                  ),
                ),
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : AppColors.backgroundAlt,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Text(
                  msg.message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                child: Text(timeStr, style: const TextStyle(color: AppColors.textDim, fontSize: 10)),
              ),
            ],
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─── DM 목록 아이템 ──────────────────────────────
class _DmItem extends StatelessWidget {
  final DmConversation dm;
  final VoidCallback onTap;
  const _DmItem({required this.dm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.accent,
              child: Text(dm.nickname[0], style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dm.nickname, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(dm.lastMessage, style: const TextStyle(color: AppColors.textDim, fontSize: 13), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (dm.unread > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Text('${dm.unread}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── DM 화면 ─────────────────────────────────────
class DmScreen extends ConsumerStatefulWidget {
  final DmConversation dm;
  const DmScreen({super.key, required this.dm});

  @override
  ConsumerState<DmScreen> createState() => _DmScreenState();
}

class _DmScreenState extends ConsumerState<DmScreen> {
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      userId: widget.dm.userId,
      nickname: widget.dm.nickname,
      message: widget.dm.lastMessage,
      time: widget.dm.time,
    ));
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final player = ref.read(playerProvider);
    setState(() {
      _messages.add(ChatMessage(
        userId: 'me',
        nickname: player.nickname.isEmpty ? '용사' : player.nickname,
        message: text,
        time: DateTime.now(),
        isMe: true,
      ));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundAlt,
        title: Text(widget.dm.nickname, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.block, color: AppColors.textDim), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _ChatBubble(msg: _messages[i]),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white10)),
              color: AppColors.backgroundAlt,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '귓말 보내기...',
                      hintStyle: const TextStyle(color: AppColors.textDim),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 42, height: 42,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
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

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textDim,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
