import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/course.dart';
import '../../domain/models/lesson_card.dart';
import '../../domain/models/question.dart';
import '../../domain/repositories/content_repository.dart';

class ContentRepositoryImpl implements ContentRepository {
  Course? _course;
  static const String _assetPath = 'assets/content/unit1.json';

  @override
  Future<Course?> getCourse() async {
    if (_course != null) return _course;
    try {
      final str = await rootBundle.loadString(_assetPath);
      final map = jsonDecode(str) as Map<String, dynamic>;
      _course = _parseCourse(map);
      return _course;
    } catch (_) {
      return null;
    }
  }

  @override
  Skill? getSkillById(String skillId) {
    if (_course == null) return null;
    for (final unit in _course!.units) {
      for (final skill in unit.skills) {
        if (skill.id == skillId) return skill;
      }
    }
    return null;
  }

  static Course _parseCourse(Map<String, dynamic> map) {
    final units = (map['units'] as List<dynamic>?)
            ?.map((u) => _parseUnit(u as Map<String, dynamic>))
            .toList() ??
        [];
    return Course(
      id: map['id'] as String? ?? 'course1',
      title: map['title'] as String? ?? 'Temeller',
      units: units,
    );
  }

  static Unit _parseUnit(Map<String, dynamic> map) {
    final skills = (map['skills'] as List<dynamic>?)
            ?.map((s) => _parseSkill(s as Map<String, dynamic>))
            .toList() ??
        [];
    return Unit(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      skills: skills,
    );
  }

  static Skill _parseSkill(Map<String, dynamic> map) {
    final cards = (map['lessonCards'] as List<dynamic>?)
            ?.map((c) => _parseLessonCard(c as Map<String, dynamic>))
            .toList() ??
        [];
    final questions = (map['questions'] as List<dynamic>?)
            ?.map((q) => _parseQuestion(q as Map<String, dynamic>))
            .toList() ??
        [];
    final miniTasks = (map['miniTasks'] as List<dynamic>?)?.cast<String>() ?? [];
    return Skill(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      order: map['order'] as int? ?? 0,
      lessonCards: cards,
      questions: questions,
      miniTasks: miniTasks,
    );
  }

  static LessonCard _parseLessonCard(Map<String, dynamic> map) {
    return LessonCard(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      audioUrl: map['audioUrl'] as String?,
    );
  }

  static Question _parseQuestion(Map<String, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'multipleChoice';
    final type = typeStr == 'trueFalse'
        ? QuestionType.trueFalse
        : QuestionType.multipleChoice;
    return Question(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      options: (map['options'] as List<dynamic>?)?.cast<String>() ?? [],
      correctIndex: map['correctIndex'] as int? ?? 0,
      explanation: map['explanation'] as String? ?? '',
      type: type,
    );
  }
}
