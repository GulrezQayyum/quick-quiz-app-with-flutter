// lib/core/utils/avatar_helper.dart
import 'dart:math';

class AvatarHelper {
  static const _style = 'adventurer'; // adventurer style 🧭

  // Generates a DiceBear SVG URL from a seed
  static String getUrl(String seed) {
    return 'https://api.dicebear.com/7.x/$_style/svg?seed=$seed';
  }

  // Generates a random seed string
  static String randomSeed() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random();
    return List.generate(10, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}