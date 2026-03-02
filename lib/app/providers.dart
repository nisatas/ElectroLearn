import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/content/content_repository_impl.dart';
import '../data/local/progress_repository_impl.dart';
import '../domain/models/course.dart';
import '../domain/models/question.dart';
import '../domain/models/user_progress.dart';
import '../domain/repositories/content_repository.dart';
import '../domain/repositories/progress_repository.dart';
import '../shared/services/speech_service.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepositoryImpl();
});

final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl();
});

final courseProvider = FutureProvider<Course?>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.getCourse();
});

final skillQuestionsProvider =
    FutureProvider.family<List<Question>, String>((ref, skillId) async {
  final repo = ref.read(contentRepositoryProvider);
  await repo.getCourse();
  return repo.getSkillById(skillId)?.questions ?? [];
});

final progressProvider = FutureProvider<UserProgress>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getProgress();
});

final progressNotifierProvider =
    StateNotifierProvider<ProgressNotifier, AsyncValue<UserProgress>>((ref) {
  final repo = ref.read(progressRepositoryProvider);
  return ProgressNotifier(repo);
});

class ProgressNotifier extends StateNotifier<AsyncValue<UserProgress>> {
  ProgressNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  final ProgressRepository _repo;

  Future<void> _load() async {
    state = AsyncValue.data(await _repo.getProgress());
  }

  Future<void> addXp(int xp) async {
    final current = state.valueOrNull ?? const UserProgress();
    final updated = _applyStreak(current.copyWith(totalXp: current.totalXp + xp));
    await _repo.saveProgress(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> completeSkill(String skillId) async {
    final current = state.valueOrNull ?? const UserProgress();
    if (current.completedSkillIds.contains(skillId)) return;
    final updated = _applyStreak(current.copyWith(
      completedSkillIds: [...current.completedSkillIds, skillId],
    ));
    await _repo.saveProgress(updated);
    state = AsyncValue.data(updated);
  }

  static String _miniTaskKey(String skillId, int index) => '$skillId-$index';

  bool isMiniTaskCompleted(String skillId, int index) {
    final keys = state.valueOrNull?.completedMiniTaskKeys ?? [];
    return keys.contains(_miniTaskKey(skillId, index));
  }

  Future<void> toggleMiniTask(String skillId, int index) async {
    final current = state.valueOrNull ?? const UserProgress();
    final key = _miniTaskKey(skillId, index);
    final keys = List<String>.from(current.completedMiniTaskKeys);
    if (keys.contains(key)) {
      keys.remove(key);
    } else {
      keys.add(key);
    }
    final updated = current.copyWith(completedMiniTaskKeys: keys);
    await _repo.saveProgress(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> completeMiniTask(String skillId, int index) async {
    final current = state.valueOrNull ?? const UserProgress();
    final key = _miniTaskKey(skillId, index);
    if (current.completedMiniTaskKeys.contains(key)) return;
    final keys = [...current.completedMiniTaskKeys, key];
    final updated = current.copyWith(completedMiniTaskKeys: keys);
    await _repo.saveProgress(updated);
    state = AsyncValue.data(updated);
  }

  Future<int> maybeGiveMiniTasksBonus(String skillId, int taskCount) async {
    if (taskCount == 0) return 0;
    final current = state.valueOrNull ?? const UserProgress();
    if (current.miniTaskBonusGivenForSkillIds.contains(skillId)) return 0;
    for (int i = 0; i < taskCount; i++) {
      if (!current.completedMiniTaskKeys.contains(_miniTaskKey(skillId, i))) return 0;
    }
    const bonus = 15;
    final updated = current.copyWith(
      totalXp: current.totalXp + bonus,
      miniTaskBonusGivenForSkillIds: [...current.miniTaskBonusGivenForSkillIds, skillId],
    );
    final withStreak = _applyStreak(updated);
    await _repo.saveProgress(withStreak);
    state = AsyncValue.data(withStreak);
    return bonus;
  }

  UserProgress _applyStreak(UserProgress p) {
    final today = _today();
    final last = p.lastActiveDate;
    int streak = p.streakDays;
    if (last == null) {
      streak = 1;
    } else if (last == today) {
      // no change
    } else if (_isYesterday(last)) {
      streak = p.streakDays + 1;
    } else {
      streak = 1;
    }
    return p.copyWith(
      streakDays: streak,
      lastActiveDate: today,
    );
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool _isYesterday(String dateStr) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final y =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    return dateStr == y;
  }

  Future<void> refresh() async {
    await _load();
  }
}
