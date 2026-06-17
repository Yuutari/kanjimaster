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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kanji (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        onyomi TEXT,
        kunyomi TEXT,
        meaning TEXT,
        jlpt_level TEXT,
        strokes INTEGER,
        radical TEXT,
        examples_json TEXT,
        studied INTEGER NOT NULL DEFAULT 0,
        mastered INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS examples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kanji_id INTEGER NOT NULL,
        word TEXT NOT NULL,
        reading TEXT,
        translation TEXT,
        FOREIGN KEY (kanji_id) REFERENCES kanji (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_level TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS progress (
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
      CREATE TABLE IF NOT EXISTS sessions (
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
      CREATE TABLE IF NOT EXISTS ai_config (
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
    final users = await db.query('users', limit: 1);
    if (users.isEmpty) {
      await _seedData(db);
    }
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    final userId = await db.insert('users', {
      'name': 'Student',
      'target_level': 'N5',
      'created_at': now,
    });

    await db.insert('ai_config', {
      'user_id': userId,
      'difficulty': 'normal',
      'focus_mode': 'weak_kanji',
      'updated_at': now,
    });
  }

  Future<void> openDb() async {
    await database;
  }
}
