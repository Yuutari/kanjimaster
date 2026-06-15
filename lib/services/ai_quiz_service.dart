import '../models/kanji_model.dart';
import '../models/progress_model.dart';
import '../data/database_provider.dart';

class AiQuizService {
  final DatabaseProvider db;

  AiQuizService(this.db);

  /// Формирует набор канджи для викторины с учётом прогресса пользователя.
  /// Приоритет отдаётся более слабым канджи (с наибольшим количеством ошибок).
  Future<List<KanjiModel>> buildQuizSet(int userId, {int count = 10}) async {
    final progress = db.progressTable
        .where((p) => p.userId == userId)
        .toList();

    final progressMap = <int, ProgressModel>{};
    for (final p in progress) {
      progressMap[p.kanjiId] = p;
    }

    final allKanji = List<KanjiModel>.from(db.kanjiTable);

    allKanji.sort((a, b) {
      final pa = progressMap[a.id];
      final pb = progressMap[b.id];
      final wrongA = pa?.wrongCount ?? 0;
      final wrongB = pb?.wrongCount ?? 0;
      return wrongB.compareTo(wrongA);
    });

    return allKanji.take(count).toList();
  }
}
