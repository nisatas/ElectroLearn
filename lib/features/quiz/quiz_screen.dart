import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/question.dart';
import '../../shared/widgets/option_tile.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/progress_bar.dart';

const int xpPerCorrect = 10;

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.skillId});

  final String skillId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedIndex;
  bool _showExplanation = false;


  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(skillQuestionsProvider(widget.skillId));

    return questionsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(child: Text('Hata: $e')),
      ),
      data: (questions) {
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz')),
            body: const Center(child: Text('Bu beceri için soru yok.')),
          );
        }
        return _QuizContent(
          questions: questions,
          currentIndex: _currentIndex,
          correctCount: _correctCount,
          selectedIndex: _selectedIndex,
          showExplanation: _showExplanation,
          onOptionTap: (i) {
            if (_showExplanation) return;
            setState(() {
              _selectedIndex = i;
              if (questions[_currentIndex].correctIndex == i) _correctCount++;
              _showExplanation = true;
            });
          },
          onNext: () {
            if (_currentIndex < questions.length - 1) {
              setState(() {
                _currentIndex++;
                _selectedIndex = null;
                _showExplanation = false;
              });
            } else {
              final xp = _correctCount * xpPerCorrect;
              ref.read(progressNotifierProvider.notifier).addXp(xp);
              ref.read(progressNotifierProvider.notifier).completeSkill(widget.skillId);
              context.push('/result', extra: {
                'correct': _correctCount,
                'total': questions.length,
                'xp': xp,
                'skillId': widget.skillId,
              });
            }
          },
        );
      },
    );
  }
}

class _QuizContent extends StatelessWidget {
  const _QuizContent({
    required this.questions,
    required this.currentIndex,
    required this.correctCount,
    required this.selectedIndex,
    required this.showExplanation,
    required this.onOptionTap,
    required this.onNext,
  });

  final List<Question> questions;
  final int currentIndex;
  final int correctCount;
  final int? selectedIndex;
  final bool showExplanation;
  final void Function(int) onOptionTap;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIndex];
    final isLast = currentIndex == questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ProgressBar(
                progress: (currentIndex + 1) / questions.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                q.text,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ...List.generate(q.options.length, (i) {
                      OptionState state = OptionState.idle;
                      if (selectedIndex != null) {
                        if (i == q.correctIndex) {
                          state = OptionState.correct;
                        } else if (i == selectedIndex && i != q.correctIndex) {
                          state = OptionState.wrong;
                        } else {
                          state = OptionState.disabled;
                        }
                      }
                      return OptionTile(
                        label: q.options[i],
                        state: state,
                        onTap: () => onOptionTap(i),
                      );
                    }),
                    if (showExplanation) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                q.explanation,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                label: showExplanation
                    ? (isLast ? 'Sonuçları gör' : 'Devam')
                    : 'Cevap ver',
                enabled: showExplanation,
                onPressed: showExplanation ? onNext : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
