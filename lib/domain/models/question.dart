enum QuestionType { multipleChoice, trueFalse }

class Question {
  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.type = QuestionType.multipleChoice,
  });
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final QuestionType type;
}
