import '../models/user_progress.dart';

abstract class ProgressRepository {
  Future<UserProgress> getProgress();
  Future<void> saveProgress(UserProgress progress);
}
