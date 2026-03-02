/// Bir beceri tamamlandığında kazanılan rozet.
class Badge {
  const Badge({
    required this.id,
    required this.title,
    required this.skillId,
    this.emoji = '🎖',
  });
  final String id;
  final String title;
  /// Bu beceri tamamlandığında rozet kazanılır.
  final String skillId;
  final String emoji;
}
