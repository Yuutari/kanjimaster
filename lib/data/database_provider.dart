import '../models/kanji_model.dart';
import '../models/example_model.dart';
import '../models/user_model.dart';
import '../models/progress_model.dart';
import '../models/session_model.dart';
import '../models/ai_config_model.dart';

const String dbName = 'kanjimaster.db';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._internal();
  DatabaseProvider._internal();

  final List<KanjiModel> kanjiTable = [];
  final List<ExampleModel> examplesTable = [];
  final List<UserModel> usersTable = [];
  final List<ProgressModel> progressTable = [];
  final List<SessionModel> sessionsTable = [];
  final List<AiConfigModel> aiConfigTable = [];

  Future<void> openDatabase() async {
    await initSchema();
  }

  Future<void> initSchema() async {
    if (kanjiTable.isNotEmpty) return;

    kanjiTable.addAll([
      KanjiModel(id: 1, symbol: '日', onyomi: 'ニチ', kunyomi: 'ひ', meaning: 'Sun, day', jlptLevel: 5, strokes: 4, radical: '日'),
      KanjiModel(id: 2, symbol: '月', onyomi: 'ゲツ', kunyomi: 'つき', meaning: 'Moon, month', jlptLevel: 5, strokes: 4, radical: '月'),
      KanjiModel(id: 3, symbol: '山', onyomi: 'サン', kunyomi: 'やま', meaning: 'Mountain', jlptLevel: 5, strokes: 3, radical: '山'),
      KanjiModel(id: 4, symbol: '水', onyomi: 'スイ', kunyomi: 'みず', meaning: 'Water', jlptLevel: 5, strokes: 4, radical: '水'),
      KanjiModel(id: 5, symbol: '火', onyomi: 'カ', kunyomi: 'ひ', meaning: 'Fire', jlptLevel: 5, strokes: 4, radical: '火'),
    ]);

    examplesTable.addAll([
      ExampleModel(id: 1, kanjiId: 1, word: '日本', reading: 'にほん', translation: 'Japan'),
      ExampleModel(id: 2, kanjiId: 2, word: '月曜日', reading: 'げつようび', translation: 'Monday'),
      ExampleModel(id: 3, kanjiId: 3, word: '富士山', reading: 'ふじさん', translation: 'Mount Fuji'),
    ]);

    usersTable.add(UserModel(
      id: 1,
      name: 'Student',
      targetLevel: 'N5',
      createdAt: DateTime.now().toIso8601String(),
    ));

    aiConfigTable.add(AiConfigModel(
      id: 1,
      userId: 1,
      difficulty: 'normal',
      focusMode: 'weak_kanji',
      updatedAt: DateTime.now().toIso8601String(),
    ));
  }
}
