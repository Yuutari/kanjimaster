import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/kanji_repository.dart';
import '../../models/kanji.dart';

enum QuizType { meaning, reading }

class QuizScreen extends StatefulWidget {
  final KanjiRepository repository;

  const QuizScreen({super.key, required this.repository});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const _aiEnabledKey = 'aiEnabled';
  static const _difficultyKey = 'aiDifficulty';
  static const _focusModeKey = 'focusMode';

  static const int _quizQuestionLimit = 20;

  QuizType? _selectedType;
  int _currentIndex = 0;
  int _correct = 0;
  bool _answered = false;
  int? _selectedOption;
  late List<String> _options;
  bool _aiEnabled = true;
  String _difficulty = 'normal';
  String _focusMode = 'weak_kanji';
  String _selectedJlptLevel = 'N5';
  List<Kanji> _questionQueue = [];
  List<Kanji> _reviewQueue = [];
  int _baseQuestionCount = 0;
  bool _showResults = false;
  int _summaryCorrect = 0;
  int _summaryMissed = 0;

  @override
  void initState() {
    super.initState();
    _options = [];
    _loadAiSettings();
  }

  Future<void> _loadAiSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _aiEnabled = prefs.getBool(_aiEnabledKey) ?? true;
      _difficulty = prefs.getString(_difficultyKey) ?? 'normal';
      _focusMode = prefs.getString(_focusModeKey) ?? 'weak_kanji';
    });
  }

  List<Kanji> _filteredKanji() {
    final allKanji = widget.repository.kanji;
    if (_selectedJlptLevel == 'All') {
      return allKanji;
    }

    return allKanji
        .where((kanji) => kanji.jlptLevel == _selectedJlptLevel)
        .toList();
  }

  List<Kanji> _buildQuestionQueue() {
    final pool = _filteredKanji();
    if (pool.isEmpty) return [];

    final shuffled = List<Kanji>.from(pool)..shuffle(Random());
    return shuffled.take(_quizQuestionLimit).toList();
  }

  String _answerLabel(Kanji kanji) {
    if (_selectedType == QuizType.meaning) {
      return kanji.meaning;
    }
    return kanji.onYomi.isNotEmpty ? kanji.onYomi.first : kanji.kunYomi.first;
  }

  List<String> _optionsForCurrent() {
    final current = _questionQueue[_currentIndex];
    final pool = _filteredKanji().where((kanji) => kanji.char != current.char).toList();
    final correct = _answerLabel(current);

    final List<String> wrongOptions = [];
    final randomPool = List<Kanji>.from(pool)..shuffle(Random());

    for (final candidate in randomPool) {
      final candidateLabel = _answerLabel(candidate);
      if (candidateLabel.trim().isEmpty || candidateLabel == correct) {
        continue;
      }
      if (!wrongOptions.contains(candidateLabel)) {
        wrongOptions.add(candidateLabel);
      }
      if (wrongOptions.length == 3) break;
    }

    if (wrongOptions.length < 3) {
      final fallback = widget.repository.kanji
          .where((kanji) => kanji.char != current.char)
          .toList()
        ..shuffle(Random());
      for (final candidate in fallback) {
        final candidateLabel = _answerLabel(candidate);
        if (candidateLabel.trim().isEmpty || candidateLabel == correct || wrongOptions.contains(candidateLabel)) {
          continue;
        }
        wrongOptions.add(candidateLabel);
        if (wrongOptions.length == 3) break;
      }
    }

    final options = <String>[correct, ...wrongOptions]..shuffle(Random());
    return options;
  }

  void _startQuiz(QuizType type) {
    final filtered = _filteredKanji();
    if (filtered.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a broader JLPT level or add more kanji to the deck.')),
      );
      return;
    }

    final questionQueue = _buildQuestionQueue();
    if (questionQueue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No kanji available for this JLPT level yet.')),
      );
      return;
    }

    setState(() {
      _selectedType = type;
      _showResults = false;
      _summaryCorrect = 0;
      _summaryMissed = 0;
      _questionQueue = questionQueue;
      _reviewQueue = [];
      _baseQuestionCount = questionQueue.length;
      _currentIndex = 0;
      _correct = 0;
      _answered = false;
      _selectedOption = null;
      _options = _optionsForCurrent();
    });
  }

  void _chooseOption(int index) async {
    if (_answered) return;
    final current = _questionQueue[_currentIndex];

    setState(() {
      _answered = true;
      _selectedOption = index;
    });

    final correctValue = _selectedType == QuizType.meaning
        ? current.meaning
        : (current.onYomi.isNotEmpty
            ? current.onYomi.first
            : current.kunYomi.first);

    final isCorrect = _options[index] == correctValue;

    if (isCorrect) {
      setState(() => _correct++);
      await widget.repository.markStudied(current);
    } else if (!_reviewQueue.any((kanji) => kanji.char == current.char)) {
      setState(() {
        _reviewQueue.add(current);
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _showResults = false;
      _selectedType = null;
      _questionQueue = [];
      _reviewQueue = [];
      _currentIndex = 0;
      _correct = 0;
      _answered = false;
      _selectedOption = null;
      _options = [];
      _summaryCorrect = 0;
      _summaryMissed = 0;
    });
  }

  void _nextQuestion() {
    final total = _questionQueue.length;

    if (_currentIndex == _baseQuestionCount - 1 && _reviewQueue.isNotEmpty) {
      _summaryCorrect = _correct;
      _summaryMissed = _reviewQueue.length;

      final reviewCards = _reviewQueue.toSet().toList()..shuffle(Random());
      setState(() {
        _questionQueue = [..._questionQueue, ...reviewCards];
        _reviewQueue = [];
        _currentIndex++;
        _answered = false;
        _selectedOption = null;
        _options = _optionsForCurrent();
      });
      return;
    }

    if (_currentIndex == total - 1) {
      final summaryCorrect = _summaryCorrect > 0 ? _summaryCorrect : _correct;
      final summaryTotal = _baseQuestionCount;
      final summaryMissed = _summaryMissed > 0
          ? _summaryMissed
          : (summaryTotal - summaryCorrect).clamp(0, summaryTotal);

      setState(() {
        _showResults = true;
        _questionQueue = [];
        _reviewQueue = [];
      });

      return;
    }

    setState(() {
      _currentIndex++;
      _answered = false;
      _selectedOption = null;
      _options = _optionsForCurrent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allKanji = widget.repository.kanji;

    if (_showResults) {
      final summaryCorrect = _summaryCorrect > 0 ? _summaryCorrect : _correct;
      final summaryTotal = _baseQuestionCount;
      final summaryMissed = _summaryMissed > 0
          ? _summaryMissed
          : (summaryTotal - summaryCorrect).clamp(0, summaryTotal);

      return QuizResultsView(
        correct: summaryCorrect,
        total: summaryTotal,
        missed: summaryMissed,
        onRestart: () => _startQuiz(_selectedType ?? QuizType.meaning),
        onExit: _resetQuiz,
      );
    }

    if (_selectedType == null) {
      final studied = allKanji.where((k) => k.studied).length;
      return Scaffold(
        backgroundColor: const Color(0xFFF7F5FF),
        body: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Ready to Quiz?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You have studied $studied kanji',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE5FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: Color(0xFF7A69E8)),
                        SizedBox(width: 8),
                        Text('AI SRS Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('20 random cards, JLPT filtering, and missed kanji returned at the end.'),
                    const SizedBox(height: 4),
                    Text('Selected JLPT: $_selectedJlptLevel', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedJlptLevel,
                decoration: const InputDecoration(
                  labelText: 'JLPT level',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'N5', child: Text('N5')),
                  DropdownMenuItem(value: 'N4', child: Text('N4')),
                  DropdownMenuItem(value: 'N3', child: Text('N3')),
                  DropdownMenuItem(value: 'N2', child: Text('N2')),
                  DropdownMenuItem(value: 'N1', child: Text('N1')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedJlptLevel = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_aiEnabled)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAE5FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF7A69E8)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AI Coach: $_difficulty mode with $_focusMode focus. We recommend starting with the weakest kanji.',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF3B3658)),
                        ),
                      ),
                    ],
                  ),
                ),
              _quizTypeCard(
                title: 'Meaning Quiz',
                subtitle: 'Match kanji to their meanings',
                icon: Icons.g_translate,
                onTap: () => _startQuiz(QuizType.meaning),
              ),
              const SizedBox(height: 12),
              _quizTypeCard(
                title: 'Reading Quiz',
                subtitle: 'Match kanji to their readings',
                icon: Icons.record_voice_over_outlined,
                onTap: () => _startQuiz(QuizType.reading),
              ),
            ],
          ),
        ),
      );
    }

    final current = _questionQueue[_currentIndex];
    final total = _questionQueue.length;
    final questionTitle = _selectedType == QuizType.meaning
        ? 'What does this mean?'
        : 'What is a reading of this kanji?';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _currentIndex >= _baseQuestionCount
                  ? 'Review missed kanji ${_currentIndex + 1} of $total'
                  : 'Question ${_currentIndex + 1} of $total',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text('$_correct correct',
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: total == 0 ? 0 : (_currentIndex + 1) / total,
              backgroundColor: const Color(0xFFE4E4EF),
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF27273F),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    questionTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    current.char,
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_options.length, (i) {
              final opt = _options[i];
              Color bg = Colors.white;
              Color border = Colors.transparent;

              if (_answered) {
                final correctValue = _selectedType ==
                        QuizType.meaning
                    ? current.meaning
                    : (current.onYomi.isNotEmpty
                        ? current.onYomi.first
                        : current.kunYomi.first);

                if (opt == correctValue) {
                  bg = const Color(0xFFE5F8ED);
                  border = const Color(0xFF2E8B57);
                } else if (i == _selectedOption) {
                  bg = const Color(0xFFFFE5E5);
                  border = const Color(0xFFE57373);
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _chooseOption(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Text(
                        opt,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            SafeArea(
              minimum: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetQuiz,
                      child: const Text('Exit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27273F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentIndex == total - 1 ? 'Finish' : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quizTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F1FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF9C8CFF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizResultsView extends StatelessWidget {
  final int correct;
  final int total;
  final int missed;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const QuizResultsView({
    super.key,
    required this.correct,
    required this.total,
    required this.missed,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A27273F),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quiz complete',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correct of $total correct',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF3B3658)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$missed missed kanji ready to review',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF3B3658)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onExit,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Exit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onRestart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27273F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Try again'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}