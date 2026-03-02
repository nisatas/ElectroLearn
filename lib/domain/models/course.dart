import 'lesson_card.dart';
import 'question.dart';

/// Üst seviye içerik: Unit listesi.
class Course {
  const Course({required this.id, required this.title, required this.units});
  final String id;
  final String title;
  final List<Unit> units;
}

class Unit {
  const Unit({required this.id, required this.title, required this.skills});
  final String id;
  final String title;
  final List<Skill> skills;
}

class Skill {
  const Skill({
    required this.id,
    required this.title,
    required this.lessonCards,
    required this.questions,
    this.order = 0,
    this.miniTasks = const [],
  });
  final String id;
  final String title;
  final int order;
  final List<LessonCard> lessonCards;
  final List<Question> questions;
  /// Mini görev listesi (örn. "Işığı Yak!", "5V ölç")
  final List<String> miniTasks;
}
