import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sqflite/sqflite.dart';
import '../models/kanji.dart';
import 'database_provider.dart';

class KanjiRepository {
  final _db = DatabaseProvider.instance;

  List<Kanji> _kanji = [];

  List<Kanji> get kanji => _kanji;

  Future<void> load() async {
    // First try loading from DB
    try {
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
    } catch (e) {
      debugPrint('DB load failed: $e, falling back to JSON');
    }

    // If DB loading failed or returned empty, load directly from JSON
    if (_kanji.isEmpty) {
      await _loadFromJsonDirectly();
    }
  }

  Future<void> _loadFromJsonDirectly() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/kanji_all.json');
      final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
      _kanji = data.map((e) {
        final map = e as Map<String, dynamic>;
        List<String> asList(dynamic v) {
          if (v == null) return [];
          if (v is List) return List<String>.from(v.map((x) => x.toString()));
          return [v.toString()];
        }
        return Kanji(
          char: (map['char'] ?? map['symbol'] ?? '').toString(),
          meaning: (map['meaning'] ?? '').toString(),
          jlptLevel: (map['jlptLevel'] ?? map['jlpt_level'] ?? 'N5').toString(),
          strokes: (map['strokes'] as num?)?.toInt() ?? 0,
          onYomi: asList(map['onYomi'] ?? map['onyomi']),
          kunYomi: asList(map['kunYomi'] ?? map['kunyomi']),
          examples: asList(map['examples']),
          studied: false,
          mastered: false,
        );
      }).toList();
      debugPrint('Loaded ${_kanji.length} kanji from JSON directly');
    } catch (e) {
      debugPrint('JSON direct load failed: $e');
    }
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
      debugPrint('Seeded ${data.length} kanji into DB');
    } catch (e) {
      debugPrint('Seed from JSON failed: $e');
    }
  }

  Future<void> markStudied(Kanji k) async {
    if (!k.studied) {
      k.studied = true;
      try {
        final db = await _db.database;
        await db.update(
          'kanji',
          {'studied': 1},
          where: 'symbol = ?',
          whereArgs: [k.char],
        );
      } catch (_) {}
    }
  }

  Future<void> toggleMastered(Kanji k) async {
    k.mastered = !k.mastered;
    if (k.mastered) k.studied = true;
    try {
      final db = await _db.database;
      await db.update(
        'kanji',
        {'mastered': k.mastered ? 1 : 0, 'studied': k.studied ? 1 : 0},
        where: 'symbol = ?',
        whereArgs: [k.char],
      );
    } catch (_) {}
  }
}
