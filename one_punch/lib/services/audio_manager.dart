import 'package:just_audio/just_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final Map<String, AudioPlayer> _players = {};
  bool _muted = false;
  bool _initialized = false;

  bool get muted => _muted;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final sounds = {
      'perfect'   : 'assets/audio/perfect.wav',
      'great'     : 'assets/audio/great.wav',
      'good'      : 'assets/audio/good.wav',
      'miss'      : 'assets/audio/miss.wav',
      'wall_break': 'assets/audio/wall_break.mp3',
      'combo'     : 'assets/audio/combo.wav',
      'game_start': 'assets/audio/game_start.wav',
    };

    for (final entry in sounds.entries) {
      try {
        final player = AudioPlayer();
        await player.setAsset(entry.value);
        _players[entry.key] = player;
      } catch (_) {}
    }
  }

  Future<void> play(String name) async {
    if (_muted) return;
    final player = _players[name];
    if (player == null) return;
    try {
      await player.seek(Duration.zero);
      await player.play();
    } catch (_) {}
  }

  void toggleMute() {
    _muted = !_muted;
    if (_muted) {
      for (final p in _players.values) {
        p.setVolume(0);
      }
    } else {
      for (final p in _players.values) {
        p.setVolume(1.0);
      }
    }
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
    _initialized = false;
  }
}
