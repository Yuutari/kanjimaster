import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kanji.dart';

class KanjiRepository {
  static const _studiedKey = 'studiedKanjiChars';
  static const _masteredKey = 'masteredKanjiChars';

  List<Kanji> _kanji = [];

  List<Kanji> get kanji => _kanji;

  Future<void> load() async {
    final jsonStr = await rootBundle.loadString('assets/kanji_all.json');
    final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
    _kanji = data
        .map((e) => Kanji.fromJson(e as Map<String, dynamic>))
        .toList();

    final prefs = await SharedPreferences.getInstance();
    final studiedChars = prefs.getStringList(_studiedKey) ?? [];
    final masteredChars = prefs.getStringList(_masteredKey) ?? [];

    for (final k in _kanji) {
      if (studiedChars.contains(k.char)) {
        k.studied = true;
      }
      if (masteredChars.contains(k.char)) {
        k.mastered = true;
      }
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final studiedChars =
        _kanji.where((k) => k.studied).map((k) => k.char).toList();
    final masteredChars =
        _kanji.where((k) => k.mastered).map((k) => k.char).toList();

    await prefs.setStringList(_studiedKey, studiedChars);
    await prefs.setStringList(_masteredKey, masteredChars);
  }

  Future<void> markStudied(Kanji k) async {
    if (!k.studied) {
      k.studied = true;
      await _saveProgress();
    }
  }

  Future<void> toggleMastered(Kanji k) async {
    k.mastered = !k.mastered;
    if (k.mastered) k.studied = true;
    await _saveProgress();
  }
}