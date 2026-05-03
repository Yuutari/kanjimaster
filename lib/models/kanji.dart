class Kanji {
  final String char;
  final String meaning;
  final String jlptLevel;
  final int strokes;
  final List<String> onYomi;
  final List<String> kunYomi;
  final List<String> examples;

  bool studied;
  bool mastered;

  Kanji({
    required this.char,
    required this.meaning,
    required this.jlptLevel,
    required this.strokes,
    required this.onYomi,
    required this.kunYomi,
    required this.examples,
    this.studied = false,
    this.mastered = false,
  });

  factory Kanji.fromJson(Map<String, dynamic> json) {
    return Kanji(
      char: json['char'] as String,
      meaning: json['meaning'] as String,
      jlptLevel: json['jlptLevel'] as String,
      strokes: json['strokes'] as int,
      onYomi: List<String>.from(json['onYomi'] as List),
      kunYomi: List<String>.from(json['kunYomi'] as List),
      examples: List<String>.from(json['examples'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'char': char,
      'meaning': meaning,
      'jlptLevel': jlptLevel,
      'strokes': strokes,
      'onYomi': onYomi,
      'kunYomi': kunYomi,
      'examples': examples,
    };
  }
}