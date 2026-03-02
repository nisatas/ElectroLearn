import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/colors.dart';
import '../../app/providers.dart';
import '../../domain/models/lesson_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/progress_bar.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.skillId});

  final String skillId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  int _totalPages = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    ref.read(speechServiceProvider).stop();
    super.dispose();
  }

  Future<void> _playCardAudio(LessonCard card) async {
    final speech = ref.read(speechServiceProvider);
    await speech.stop();
    await _audioPlayer.stop();

    final audioUrl = card.audioUrl;
    if (audioUrl != null && audioUrl.trim().isNotEmpty) {
      try {
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
      } catch (_) {
        await speech.speak('${card.title}. ${card.body}');
      }
    } else {
      await speech.speak('${card.title}. ${card.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseProvider);
    return courseAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Ders')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Ders')),
        body: Center(child: Text('Hata: $e')),
      ),
      data: (_) {
        final contentRepo = ref.read(contentRepositoryProvider);
        final skill = contentRepo.getSkillById(widget.skillId);
        final cards = skill?.lessonCards ?? [];

        if (_totalPages == 0 && cards.isNotEmpty) {
          _totalPages = cards.length;
        }

        if (cards.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Ders')),
            body: const Center(child: Text('Bu beceri için ders kartı yok.')),
          );
        }

        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              ref.read(speechServiceProvider).stop();
              _audioPlayer.stop();
            }
          },
          child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(skill?.title ?? 'Ders'),
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                icon: const Icon(Icons.volume_up, color: AppColors.primary),
                tooltip: 'Sesle oku',
                onPressed: () => _playCardAudio(cards[_currentPage]),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ProgressBar(
                    progress: _totalPages > 0
                        ? (_currentPage + 1) / _totalPages
                        : 0,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: cards.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) {
                      final card = cards[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                card.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  card.body,
                                  style:
                                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            height: 1.5,
                                            color: AppColors.primary,
                                          ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                onPressed: () => _playCardAudio(card),
                                icon: const Icon(Icons.volume_up, size: 20),
                                label: const Text('Sesle oku'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.accent,
                                  side: const BorderSide(color: AppColors.accent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (skill?.miniTasks != null && skill!.miniTasks.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '🧩 Mini görevler',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...skill.miniTasks.map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 20,
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    task,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.primary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: PrimaryButton(
                    label:
                        _currentPage == cards.length - 1 ? 'Teste geç' : 'Devam',
                    onPressed: () {
                      if (_currentPage < cards.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() => _currentPage++);
                      } else {
                        context.push('/quiz/${widget.skillId}');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
    );
      },
    );
  }
}
