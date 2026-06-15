class KanjiModel {
  final int id;
  final String symbol;
  final String onyomi;
  final String kunyomi;
  final String meaning;
  final int jlptLevel;
  final int strokes;
  final String radical;

  KanjiModel({
    required this.id,
    required this.symbol,
    required this.onyomi,
    required this.kunyomi,
    required this.meaning,
    required this.jlptLevel,
    required this.strokes,
    required this.radical,
  });
}
