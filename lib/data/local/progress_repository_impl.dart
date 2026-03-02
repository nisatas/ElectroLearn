import '../../domain/models/user_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import 'hive_service.dart';

const String _keyProgress = 'userProgress';

class ProgressRepositoryImpl implements ProgressRepository {
  @override
  Future<UserProgress> getProgress() async {
    final raw = HiveService.progressBox.get(_keyProgress);
    if (raw == null) return const UserProgress();
    if (raw is Map) {
      return UserProgress.fromJson(Map<String, dynamic>.from(raw));
    }
    return const UserProgress();
  }

  @override
  Future<void> saveProgress(UserProgress progress) async {
    await HiveService.progressBox.put(_keyProgress, progress.toJson());
  }
}
