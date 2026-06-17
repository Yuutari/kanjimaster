import '../models/session_model.dart';
import 'database_provider.dart';

class SessionsRepository {
  final _db = DatabaseProvider.instance;

  Future<void> saveSessionResult(SessionModel session) async {
    final db = await _db.database;
    await db.insert('sessions', {
      'user_id': session.userId,
      'score': session.score,
      'total': session.total,
      'mode': session.mode,
      'created_at': session.createdAt,
    });
  }

  Future<List<SessionModel>> getSessionsHistory(int userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map((row) => SessionModel(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      score: row['score'] as int,
      total: row['total'] as int,
      mode: row['mode'] as String?,
      createdAt: row['created_at'] as String,
    )).toList();
  }

  Future<Map<String, dynamic>> getOverallStats(int userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final totalSessions = rows.length;
    final totalCorrect = rows.fold<int>(
        0, (sum, r) => sum + (r['score'] as int? ?? 0));
    final totalAnswered = rows.fold<int>(
        0, (sum, r) => sum + (r['total'] as int? ?? 0));
    return {
      'totalSessions': totalSessions,
      'totalCorrect': totalCorrect,
      'totalAnswered': totalAnswered,
    };
  }
}
