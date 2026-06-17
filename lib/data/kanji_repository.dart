import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/kanji.dart';
import 'database_provider.dart';

class KanjiRepository {
  final _db = DatabaseProvider.instance;

  List<Kanji> _kanji = [];

  List<Kanji> get kanji => _kanji;

  Future<void> load() async {
    final db = await _db.database;

    // If DB is empty, seed from assets JSON
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM kanji'),
    ) ?? 0;

    if (count == 0) {
      await _seedFromJson(db);
    }

    final rows = await db.query('kanji', orderBy: 'jlpt_level ASC');
    _kanji = rows.map((row) => Kanji(
      char: row['symbol'] as String,
      meaning: row['meaning'] as String? ?? '',
      onyomi: row['onyomi'] as String? ?? '',
      kunyomi: row['kunyomi'] as String? ?? '',
      jlptLevel: row['jlpt_level'] as int? ?? 5,
      strokes: row['strokes'] as int? ?? 0,
      studied: (row['studied'] as int? ?? 0) == 1,
      mastered: (row['mastered'] as int? ?? 0) == 1,
    )).toList();
  }

  Future<void> _seedFromJson(dynamic db) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/kanji_all.json');
      final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
      final batch = db.batch();
      for (final e in data) {
        final map = e as Map<String, dynamic>;
        batch.insert('kanji', {
          'symbol': map['char'] ?? map['symbol'] ?? '',
          'onyomi': map['onyomi'] ?? '',
          'kunyomi': map['kunyomi'] ?? '',
          'meaning': map['meaning'] ?? '',
          'jlpt_level': map['jlptLevel'] ?? map['jlpt_level'] ?? 5,
          'strokes': map['strokes'] ?? 0,
          'radical': map['radical'] ?? '',
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
