import 'package:flutter/material.dart';
import '../../data/kanji_repository.dart';

enum QuizType { meaning, reading }

class QuizScreen extends StatefulWidget {
  final KanjiRepository repository;

  const QuizScreen({super.key, required this.repository});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizType? _selectedType;
  int _currentIndex = 0;
  int _correct = 0;
  bool _answered = false;
  int? _selectedOption;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _options = [];
  }

  List<String> _optionsForCurrent() {
    final allKanji = widget.repository.kanji;
    final current = allKanji[_currentIndex];
    final List<String> opts = [];

    if (_selectedType == QuizType.meaning) {
      opts.add(current.meaning);
      for (final k in allKanji) {
        if (k == current) continue;
        opts.add(k.meaning);
        if (opts.length == 4) break;
      }
    } else {
      final reading = current.onYomi.isNotEmpty
          ? current.onYomi.first
          : current.kunYomi.first;
      opts.add(reading);
      for (final k in allKanji) {
        if (k == current) continue;
        final r =
            k.onYomi.isNotEmpty ? k.onYomi.first : k.kunYomi.first;
        opts.add(r);
        if (opts.length == 4) break;
      }
    }

    opts.shuffle();
    return opts;
  }

  void _startQuiz(QuizType type) {
    setState(() {
      _selectedType = type;
      _currentIndex = 0;
      _correct = 0;
      _answered = false;
      _selectedOption = null;
      _options = _optionsForCurrent();
    });
  }

  void _chooseOption(int index) async {
    if (_answered) return;
    final allKanji = widget.repository.kanji;
    final current = allKanji[_currentIndex];

    setState(() {
      _answered = true;
      _selectedOption = index;
    });

    final correctValue = _selectedType == QuizType.meaning
        ? current.meaning
        : (current.onYomi.isNotEmpty
            ? current.onYomi.first
            : current.kunYomi.first);

    if (_options[index] == correctValue) {
      setState(() => _correct++);
      await widget.repository.markStudied(current);
      setState(() {});
    }
  }

  void _nextQuestion() {
    final total = widget.repository.kanji.length;
    if (_currentIndex == total - 1) {
      setState(() {
        _selectedType = null;
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
              const SizedBox(height: 24),
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

    final total = allKanji.length;
    final current = allKanji[_currentIndex];
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
              'Question ${_currentIndex + 1} of $total',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text('$_correct correct',
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / total,
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
                      onPressed: () {
                        setState(() {
                          _selectedType = null;
                        });
                      },
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