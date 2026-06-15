import '../data/database_provider.dart';

class ProgressService {
  final DatabaseProvider db;

  ProgressService(this.db);

  /// Возвращает сводную статистику по дашборду для пользователя.
  Future<Map<String, dynamic>> getDashboardStats(int userId) async {
    final progress = db.progressTable
        .where((p) => p.userId == userId)
        .toList();

    final sessions = db.sessionsTable
        .where((s) => s.userId == userId)
        .toList();

    final totalKanji = db.kanjiTable.length;
    final studiedKanji = progress.where((p) => p.seenCount > 0).length;
    final masteredKanji = progress.where((p) => p.srsStage >= 5).length;
    final totalSessions = sessions.length;
    final totalCorrect = sessions.fold<int>(0, (sum, s) => sum + s.correct);
    final totalAnswers = sessions.fold<int>(0, (sum, s) => sum + s.total);
    final accuracy = totalAnswers == 0
        ? 0.0
        : totalCorrect / totalAnswers;

    return {
      'totalKanji': totalKanji,
      'studiedKanji': studiedKanji,
      'masteredKanji': masteredKanji,
      'totalSessions': totalSessions,
      'accuracy': accuracy,
    };
  }
}
