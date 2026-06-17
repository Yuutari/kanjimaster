import '../models/progress_model.dart';
import 'database_provider.dart';

class ProgressRepository {
  final _db = DatabaseProvider.instance;

  Future<void> saveProgress(ProgressModel progress) async {
    final db = await _db.database;
    final existing = await db.query(
      'progress',
      where: 'user_id = ? AND kanji_id = ?',
      whereArgs: [progress.userId, progress.kanjiId],
    );
    if (existing.isNotEmpty) {
      await db.update(
        'progress',
        {
          'seen_count': progress.seenCount,
          'correct_count': progress.correctCount,
          'last_seen_at': progress.lastSeenAt,
        },
        where: 'user_id = ? AND kanji_id = ?',
        whereArgs: [progress.userId, progress.kanjiId],
      );
    } else {
      await db.insert('progress', {
        'user_id': progress.userId,
        'kanji_id': progress.kanjiId,
        'seen_count': progress.seenCount,
        'correct_count': progress.correctCount,
        'last_seen_at': progress.lastSeenAt,
      });
    }
  }

  Future<ProgressModel?> getProgressForKanji(
      int userId, int kanjiId) async {
    final db = await _db.database;
    final rows = await db.query(
      'progress',
      where: 'user_id = ? AND kanji_id = ?',
      whereArgs: [userId, kanjiId],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return ProgressModel(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      kanjiId: row['kanji_id'] as int,
      seenCount: row['seen_count'] as int,
      correctCount: row['correct_count'] as int,
      lastSeenAt: row['last_seen_at'] as String?,
    );
  }

  Future<Map<String, int>> getProgressSummary(int userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final seen = rows.where((r) => (r['seen_count'] as int) > 0).length;
    final correct = rows.fold<int>(
        0, (sum, r) => sum + (r['correct_count'] as int? ?? 0));
    final total = rows.fold<int>(
        0, (sum, r) => sum + (r['seen_count'] as int? ?? 0));
    return {'seen': seen, 'correct': correct, 'total': total};
  }
}
