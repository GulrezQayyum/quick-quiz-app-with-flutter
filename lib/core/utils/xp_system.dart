// lib/core/utils/xp_system.dart

class XpSystem {
  /// XP earned per quiz: 10 base + up to 20 accuracy bonus
  static int calculateXP(int correct, int total) {
    if (total == 0) return 0;
    final accuracyBonus = ((correct / total) * 20).round();
    return 10 + accuracyBonus;
  }

  /// Total XP required to reach [level]
  /// Level 1 = 0, Level 2 = 100, Level 3 = 250, Level 4 = 450 ...
  /// Each gap increases by 50 XP
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    int total = 0;
    int gap = 100;
    for (int i = 2; i <= level; i++) {
      total += gap;
      gap += 50;
    }
    return total;
  }

  /// Current level from total XP
  static int levelFromXP(int xp) {
    int level = 1;
    while (xpForLevel(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  /// Total XP needed to reach next level
  static int xpForNextLevel(int xp) {
    return xpForLevel(levelFromXP(xp) + 1);
  }

  /// Total XP at the start of the current level
  static int xpForCurrentLevel(int xp) {
    return xpForLevel(levelFromXP(xp));
  }

  /// Progress within current level as 0.0 → 1.0
  static double levelProgress(int xp) {
    final current = xpForCurrentLevel(xp);
    final next    = xpForNextLevel(xp);
    if (next == current) return 1.0;
    return (xp - current) / (next - current);
  }
}