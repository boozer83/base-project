class GameResult {
  final int stage;
  final int maxCombo;
  final int perfectCount;
  final int greatCount;
  final int goodCount;
  final int missCount;
  final int coinsEarned;
  final bool isRevived;

  const GameResult({
    required this.stage,
    required this.maxCombo,
    required this.perfectCount,
    required this.greatCount,
    required this.goodCount,
    required this.missCount,
    required this.coinsEarned,
    this.isRevived = false,
  });

  String get grade {
    final total = perfectCount + greatCount + goodCount + missCount;
    if (total == 0) return 'F';
    final perfectRate = perfectCount / total;
    if (perfectRate >= 0.90) return 'S';
    if (perfectRate >= 0.70) return 'A';
    if (perfectRate >= 0.50) return 'B';
    if (perfectRate >= 0.30) return 'C';
    return 'D';
  }
}
