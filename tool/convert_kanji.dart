import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final srcPath = 'data_src/kanji.json';
  final dstPath = 'assets/kanji_all.json';

  final srcFile = File(srcPath);
  if (!await srcFile.exists()) {
    stderr.writeln('Source file not found: $srcPath');
    stderr.writeln(
        'Скачай kanji.json из https://github.com/davidluzgouveia/kanji-data и положи в data_src/');
    exit(1);
  }

  final raw = await srcFile.readAsString();
  final Map<String, dynamic> original =
      json.decode(raw) as Map<String, dynamic>;

  final List<Map<String, dynamic>> result = [];

  original.forEach((char, data) {
    if (data is! Map<String, dynamic>) return;

    final jlptNew = data['jlpt_new'];
    if (jlptNew == null) {
      return;
    }

    final strokes = data['strokes'] as int? ?? 0;

    final meanings = data['meanings'] as List<dynamic>? ?? const [];
    final String meaning = meanings.isNotEmpty
        ? meanings.first.toString()
        : '';

    final readingsOn =
        (data['readings_on'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList();

    final readingsKun =
        (data['readings_kun'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList();

    String jlptLevel;
    if (jlptNew is int) {
      jlptLevel = 'N$jlptNew';
    } else {
      jlptLevel = 'N5';
    }

    result.add({
      'char': char,
      'meaning': meaning.toLowerCase(),
      'jlptLevel': jlptLevel,
      'strokes': strokes,
      'onYomi': readingsOn,
      'kunYomi': readingsKun,
      'examples': <String>[],
    });
  });

  result.sort((a, b) {
    final lvlA = a['jlptLevel'] as String? ?? 'N5';
    final lvlB = b['jlptLevel'] as String? ?? 'N5';
    if (lvlA != lvlB) return lvlA.compareTo(lvlB);
    return (a['char'] as String).compareTo(b['char'] as String);
  });

  final dstDir = Directory('assets');
  if (!await dstDir.exists()) {
    await dstDir.create(recursive: true);
  }

  final dstFile = File(dstPath);
  await dstFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(result),
  );

  stdout.writeln('Готово: записано ${result.length} кандзи в $dstPath');
}