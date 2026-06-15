import '../models/progress_model.dart';
import 'database_provider.dart';

class ProgressRepository {
  final DatabaseProvider db;

  ProgressRepository(this.db);

  Future<void> saveProgress(ProgressModel progress) async {
    final index = db.progressTable.indexWhere((item) => item.id == progress.id);
    if (index >= 0) {
      db.progressTable[index] = progress;
    } else {
      db.progressTable.add(progress);
    }
  }

  Future<ProgressModel?> getProgressForKanji(int userId, int kanjiId) async {
    final items = db.progressTable
        .where((item) => item.userId == userId && item.kanjiId == kanjiId)
        .toList();
    return items.isEmpty ? null : items.first;
  }

  Future<Map<String, int>> getProgressSummary(int userId) async {
    final items = db.progressTable.where((item) => item.userId == userId).toList();
    final seen = items.where((item) => item.seenCount > 0).length;
    final correct = items.fold<int>(0, (sum, item) => sum + item.correctCount);
    final total = items.fold<int>(0, (sum, item) => sum + item.seenCount);
    return {'seen': seen, 'correct': correct, 'total': total};
  }
}
