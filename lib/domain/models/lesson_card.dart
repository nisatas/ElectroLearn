class LessonCard {
  const LessonCard({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.audioUrl,
  });
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  /// ElevenLabs veya harici ses dosyası URL'i (opsiyonel)
  final String? audioUrl;
}
