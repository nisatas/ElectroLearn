import '../models/course.dart';
import '../models/lesson_card.dart';
import '../models/question.dart';

abstract class ContentRepository {
  Future<Course?> getCourse();
  Skill? getSkillById(String skillId);
}

extension ContentRepositoryX on ContentRepository {
  LessonCard? getLessonCard(String skillId, int index) {
    final skill = getSkillById(skillId);
    if (skill == null || index < 0 || index >= skill.lessonCards.length) {
      return null;
    }
    return skill.lessonCards[index];
  }

  List<Question> getQuestions(String skillId) {
    return getSkillById(skillId)?.questions ?? [];
  }
}
