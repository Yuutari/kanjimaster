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
    if (_selectedJlptLevel == 'All') return allKanji;
    return allKanji.where((k) => k.jlptLevel == _selectedJlptLevel).toList();
  }

  List<Kanji> _buildQuestionQueue() {
    final pool = _filteredKanji();
    if (pool.isEmpty) return [];
    final shuffled = List<Kanji>.from(pool)..shuffle(Random());
    return shuffled.take(_quizQuestionLimit).toList();
  }

  String _answerLabel(Kanji kanji) {
    if (_selectedType == QuizType.meaning) return kanji.meaning;
    return kanji.onYomi.isNotEmpty ? kanji.onYomi.first : kanji.kunYomi.first;
  }

  List<String> _optionsForCurrent() {
    final current = _questionQueue[_currentIndex];
    final pool = _filteredKanji().where((k) => k.char != current.char).toList();
    final correct = _answerLabel(current);
    final List<String> wrongOptions = [];
    final randomPool = List<Kanji>.from(pool)..shuffle(Random());

    for (final candidate in randomPool) {
      final label = _answerLabel(candidate);
      if (label.trim().isEmpty || label == correct || wrongOptions.contains(label)) continue;
      wrongOptions.add(label);
      if (wrongOptions.length == 3) break;
    }

    if (wrongOptions.length < 3) {
      final fallback = widget.repository.kanji
          .where((k) => k.char != current.char)
          .toList()..shuffle(Random());
      for (final candidate in fallback) {
        final label = _answerLabel(candidate);
        if (label.trim().isEmpty || label == correct || wrongOptions.contains(label)) continue;
        wrongOptions.add(label);
        if (wrongOptions.length == 3) break;
      }
    }

    return [correct, ...wrongOptions]..shuffle(Random());
  }

  void _startQuiz(QuizType type) {
    final filtered = _filteredKanji();
    if (filtered.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a broader JLPT level or add more kanji.')),
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

  Future<void> _chooseOption(int index) async {
    if (_answered) return;
    final current = _questionQueue[_currentIndex];
    setState(() {
      _answered = true;
      _selectedOption = index;
    });

    final correctValue = _answerLabel(current);
    final isCorrect = _options[index] == correctValue;

    if (isCorrect) {
      setState(() => _correct++);
      await widget.repository.markStudied(current);
    } else if (!_reviewQueue.any((k) => k.char == current.char)) {
      setState(() => _reviewQueue.add(current));
    }

    // Auto-advance after 1.2 seconds
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) _nextQuestion();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF7F5FF);
    final cardColor = isDark ? const Color(0xFF252540) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

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
        isDark: isDark,
      );
    }

    if (_selectedType == null) {
      final studied = allKanji.where((k) => k.studied).length;
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text('Ready to Quiz?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textColor)),
                const SizedBox(height: 4),
                Text('You have studied $studied kanji', style: TextStyle(color: subColor)),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E2E50) : const Color(0xFFEAE5FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: isDark ? const Color(0xFFB8A9FF) : const Color(0xFF7A69E8)),
                          const SizedBox(width: 8),
                          Text('AI SRS Quiz',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '20 random cards, JLPT filtering, and missed kanji returned at the end.',
                          style: TextStyle(fontSize: 13, color: subColor)),
                      const SizedBox(height: 6),
                      Text('Selected JLPT: $_selectedJlptLevel',
                          style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedJlptLevel,
                  decoration: InputDecoration(
                    labelText: 'JLPT level',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: cardColor,
                  ),
                  dropdownColor: cardColor,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'N5', child: Text('N5')),
                    DropdownMenuItem(value: 'N4', child: Text('N4')),
                    DropdownMenuItem(value: 'N3', child: Text('N3')),
                    DropdownMenuItem(value: 'N2', child: Text('N2')),
                    DropdownMenuItem(value: 'N1', child: Text('N1')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedJlptLevel = value);
                  },
                ),
                const SizedBox(height: 20),
                _quizTypeCard(
                  title: 'Meaning Quiz',
                  subtitle: 'Match kanji to their meanings',
                  icon: Icons.g_translate,
                  onTap: () => _startQuiz(QuizType.meaning),
                  cardColor: cardColor,
                  textColor: textColor,
                  subColor: subColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _quizTypeCard(
                  title: 'Reading Quiz',
                  subtitle: 'Match kanji to their readings',
                  icon: Icons.record_voice_over_outlined,
                  onTap: () => _startQuiz(QuizType.reading),
                  cardColor: cardColor,
                  textColor: textColor,
                  subColor: subColor,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final current = _questionQueue[_currentIndex];
    final total = _questionQueue.length;
    final questionTitle = _selectedType == QuizType.meaning
        ? 'What does this mean?'
        : 'What is a reading of this kanji?';
    final correctValue = _answerLabel(current);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _currentIndex >= _baseQuestionCount
                    ? 'Review missed kanji ${_currentIndex + 1} of $total'
                    : 'Question ${_currentIndex + 1} of $total',
                style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
              ),
              const SizedBox(height: 4),
              Text('$_correct correct', style: TextStyle(color: subColor)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : (_currentIndex + 1) / total,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? const Color(0xFF3A3A50)
                        : const Color(0xFFE4E4EF),
                    valueColor: AlwaysStoppedAnimation(
                        isDark ? const Color(0xFFB8A9FF) : const Color(0xFF7A69E8)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Container(
                  key: ValueKey(_currentIndex),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(questionTitle,
                          style: TextStyle(fontSize: 14, color: subColor)),
                      const SizedBox(height: 20),
                      Text(
                        current.char,
                        style: TextStyle(
                            fontSize: 80, fontWeight: FontWeight.w700, color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(_options.length, (i) {
                final opt = _options[i];
                Color bg = cardColor;
                Color border = Colors.transparent;
                IconData? icon;

                if (_answered) {
                  if (opt == correctValue) {
                    bg = isDark
                        ? const Color(0xFF1E4D2B)
                        : const Color(0xFFE5F8ED);
                    border = const Color(0xFF2E8B57);
                    icon = Icons.check_circle;
                  } else if (i == _selectedOption) {
                    bg = isDark
                        ? const Color(0xFF4D1E1E)
                        : const Color(0xFFFFE5E5);
                    border = const Color(0xFFE57373);
                    icon = Icons.cancel;
                  }
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _chooseOption(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: border,
                              width: border == Colors.transparent ? 1 : 2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opt,
                                style: TextStyle(fontSize: 16, color: textColor),
                              ),
                            ),
                            if (icon != null)
                              Icon(icon, color: border, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              Text(
                _answered
                    ? 'Auto-advancing...'
                    : 'Select an answer',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: subColor),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _resetQuiz,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: subColor),
                ),
                child: Text('Exit Quiz', style: TextStyle(color: textColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quizTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    required bool isDark,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
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
                  color: isDark
                      ? const Color(0xFF3A3A50)
                      : const Color(0xFFF3F1FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon,
                    color: isDark
                        ? const Color(0xFFB8A9FF)
                        : const Color(0xFF9C8CFF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: subColor)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: subColor),
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
  final bool isDark;

  const QuizResultsView({
    super.key,
    required this.correct,
    required this.total,
    required this.missed,
    required this.onRestart,
    required this.onExit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF7F5FF);
    final cardColor = isDark ? const Color(0xFF252540) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white70 : const Color(0xFF3B3658);
    final score = (correct / total * 100).round();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    score >= 80
                        ? Icons.emoji_events
                        : score >= 50
                            ? Icons.thumb_up
                            : Icons.restart_alt,
                    size: 64,
                    color: score >= 80
                        ? const Color(0xFFFFB300)
                        : isDark
                            ? Colors.white54
                            : Colors.black54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    score >= 80
                        ? 'Excellent!'
                        : score >= 50
                            ? 'Good job!'
                            : 'Keep practicing!',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w700, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correct of $total correct ($score%)',
                    style: TextStyle(fontSize: 16, color: subColor),
                  ),
                  if (missed > 0) ..[
                    const SizedBox(height: 6),
                    Text(
                      '$missed missed kanji reviewed',
                      style: TextStyle(fontSize: 14, color: subColor),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onExit,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: subColor),
                          ),
                          child: Text('Exit', style: TextStyle(color: textColor)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onRestart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF7A69E8)
                                : const Color(0xFF27273F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Try Again'),
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
