import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

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

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE kanji (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        onyomi TEXT,
        kunyomi TEXT,
        meaning TEXT,
        jlpt_level INTEGER,
        strokes INTEGER,
        radical TEXT,
        studied INTEGER NOT NULL DEFAULT 0,
        mastered INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE examples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kanji_id INTEGER NOT NULL,
        word TEXT NOT NULL,
        reading TEXT,
        translation TEXT,
        FOREIGN KEY (kanji_id) REFERENCES kanji (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_level TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        kanji_id INTEGER NOT NULL,
        seen_count INTEGER NOT NULL DEFAULT 0,
        correct_count INTEGER NOT NULL DEFAULT 0,
        last_seen_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (kanji_id) REFERENCES kanji (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        score INTEGER NOT NULL DEFAULT 0,
        total INTEGER NOT NULL DEFAULT 0,
        mode TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ai_config (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'normal',
        focus_mode TEXT NOT NULL DEFAULT 'weak_kanji',
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await _seedData(db);
  }

  Future<void> _onOpen(Database db) async {
    final users = await db.query('users');
    if (users.isEmpty) {
      await _seedData(db);
    }
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Default user
    final userId = await db.insert('users', {
      'name': 'Student',
      'target_level': 'N5',
      'created_at': now,
    });

    // Default AI config
    await db.insert('ai_config', {
      'user_id': userId,
      'difficulty': 'normal',
      'focus_mode': 'weak_kanji',
      'updated_at': now,
    });

    // Seed N5 kanji
    final kanjiData = [
      KanjiModel(id: 0, symbol: '\u65e5', onyomi: '\u30cb\u30c1', kunyomi: '\u3072', meaning: 'Sun, day', jlptLevel: 5, strokes: 4, radical: '\u65e5'),
      KanjiModel(id: 0, symbol: '\u6708', onyomi: '\u30b2\u30c4', kunyomi: '\u3064\u304d', meaning: 'Moon, month', jlptLevel: 5, strokes: 4, radical: '\u6708'),
      KanjiModel(id: 0, symbol: '\u5c71', onyomi: '\u30b5\u30f3', kunyomi: '\u3084\u307e', meaning: 'Mountain', jlptLevel: 5, strokes: 3, radical: '\u5c71'),
      KanjiModel(id: 0, symbol: '\u6c34', onyomi: '\u30b9\u30a4', kunyomi: '\u307f\u305a', meaning: 'Water', jlptLevel: 5, strokes: 4, radical: '\u6c34'),
      KanjiModel(id: 0, symbol: '\u706b', onyomi: '\u30ab', kunyomi: '\u3072', meaning: 'Fire', jlptLevel: 5, strokes: 4, radical: '\u706b'),
      KanjiModel(id: 0, symbol: '\u6728', onyomi: '\u30e2\u30af', kunyomi: '\u304d', meaning: 'Tree, wood', jlptLevel: 5, strokes: 4, radical: '\u6728'),
      KanjiModel(id: 0, symbol: '\u91d1', onyomi: '\u30ad\u30f3', kunyomi: '\u304b\u306d', meaning: 'Gold, money', jlptLevel: 5, strokes: 8, radical: '\u91d1'),
      KanjiModel(id: 0, symbol: '\u571f', onyomi: '\u30c9', kunyomi: '\u3064\u3061', meaning: 'Earth, soil', jlptLevel: 5, strokes: 3, radical: '\u571f'),
    ];

    for (final k in kanjiData) {
      final kanjiId = await db.insert('kanji', {
        'symbol': k.symbol,
        'onyomi': k.onyomi,
        'kunyomi': k.kunyomi,
        'meaning': k.meaning,
        'jlpt_level': k.jlptLevel,
        'strokes': k.strokes,
        'radical': k.radical,
        'studied': 0,
        'mastered': 0,
      });

      // Seed examples for kanji
      final examples = _getExamplesForKanji(k.symbol);
      for (final ex in examples) {
        await db.insert('examples', {
          'kanji_id': kanjiId,
          'word': ex['word'],
          'reading': ex['reading'],
          'translation': ex['translation'],
        });
      }
    }
  }

  List<Map<String, String>> _getExamplesForKanji(String symbol) {
    const examples = {
      '\u65e5': [{'word': '\u65e5\u672c', 'reading': '\u306b\u307b\u3093', 'translation': 'Japan'}],
      '\u6708': [{'word': '\u6708\u66dc\u65e5', 'reading': '\u3052\u3064\u3088\u3046\u3073', 'translation': 'Monday'}],
      '\u5c71': [{'word': '\u5bcc\u58eb\u5c71', 'reading': '\u3075\u3058\u3055\u3093', 'translation': 'Mount Fuji'}],
      '\u6c34': [{'word': '\u6c34\u66dc\u65e5', 'reading': '\u3059\u3044\u3088\u3046\u3073', 'translation': 'Wednesday'}],
      '\u706b': [{'word': '\u706b\u66dc\u65e5', 'reading': '\u304b\u3088\u3046\u3073', 'translation': 'Tuesday'}],
      '\u6728': [{'word': '\u6728\u66dc\u65e5', 'reading': '\u3082\u304f\u3088\u3046\u3073', 'translation': 'Thursday'}],
      '\u91d1': [{'word': '\u91d1\u66dc\u65e5', 'reading': '\u304d\u3093\u3088\u3046\u3073', 'translation': 'Friday'}],
      '\u571f': [{'word': '\u571f\u66dc\u65e5', 'reading': '\u3069\u3088\u3046\u3073', 'translation': 'Saturday'}],
    };
    return (examples[symbol] ?? []).map((e) => Map<String, String>.from(e)).toList();
  }

  Future<void> openDatabase() async {
    await database;
  }
}
