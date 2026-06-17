import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../models/kanji.dart';
import 'database_provider.dart';

class KanjiRepository {
  final _db = DatabaseProvider.instance;

  List<Kanji> _kanji = [];

  List<Kanji> get kanji => _kanji;

  Future<void> load() async {
    final db = await _db.database;

    // If DB is empty, seed from assets JSON
    final countResult = await db.rawQuery('SELECT COUNT(*) as cnt FROM kanji');
    final count = countResult.first['cnt'] as int? ?? 0;

    if (count == 0) {
      await _seedFromJson(db);
    }

    final rows = await db.query('kanji', orderBy: 'jlpt_level ASC');
    _kanji = rows.map((row) {
      List<String> parseJson(String? v) {
        if (v == null || v.isEmpty) return [];
        try {
          return List<String>.from(jsonDecode(v) as List);
        } catch (_) {
          return [v];
        }
      }

      return Kanji(
        char: row['symbol'] as String,
        meaning: row['meaning'] as String? ?? '',
        jlptLevel: (row['jlpt_level'] ?? 'N5').toString(),
        strokes: row['strokes'] as int? ?? 0,
        onYomi: parseJson(row['onyomi'] as String?),
        kunYomi: parseJson(row['kunyomi'] as String?),
        examples: parseJson(row['examples_json'] as String?),
        studied: (row['studied'] as int? ?? 0) == 1,
        mastered: (row['mastered'] as int? ?? 0) == 1,
      );
    }).toList();
  }

  Future<void> _seedFromJson(Database db) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/kanji_all.json');
      final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
      final batch = db.batch();
      for (final e in data) {
        final map = e as Map<String, dynamic>;
        final onYomi = map['onYomi'] ?? map['onyomi'] ?? [];
        final kunYomi = map['kunYomi'] ?? map['kunyomi'] ?? [];
        final examples = map['examples'] ?? [];
        batch.insert('kanji', {
          'symbol': map['char'] ?? map['symbol'] ?? '',
          'onyomi': jsonEncode(onYomi is List ? onYomi : [onYomi.toString()]),
          'kunyomi': jsonEncode(kunYomi is List ? kunYomi : [kunYomi.toString()]),
          'meaning': map['meaning'] ?? '',
          'jlpt_level': (map['jlptLevel'] ?? map['jlpt_level'] ?? 'N5').toString(),
          'strokes': map['strokes'] ?? 0,
          'radical': map['radical'] ?? '',
          'examples_json': jsonEncode(examples is List ? examples : [examples.toString()]),
          'studied': 0,
          'mastered': 0,
        });
      }
      await batch.commit(noResult: true);
    } catch (_) {
      // JSON not found or parse error, skip seeding
    }
  }

  Future<void> markStudied(Kanji k) async {
    if (!k.studied) {
      k.studied = true;
      final db = await _db.database;
      await db.update(
        'kanji',
        {'studied': 1},
        where: 'symbol = ?',
        whereArgs: [k.char],
      );
    }
  }

  Future<void> toggleMastered(Kanji k) async {
    k.mastered = !k.mastered;
    if (k.mastered) k.studied = true;
    final db = await _db.database;
    await db.update(
      'kanji',
      {'mastered': k.mastered ? 1 : 0, 'studied': k.studied ? 1 : 0},
      where: 'symbol = ?',
      whereArgs: [k.char],
    );
  }
}
