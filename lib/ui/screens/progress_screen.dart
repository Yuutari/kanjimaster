import 'package:flutter/material.dart';
import '../../data/kanji_repository.dart';
import '../widgets/progress_bar.dart';

class ProgressScreen extends StatelessWidget {
  final KanjiRepository repository;

  const ProgressScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final allKanji = repository.kanji;
    final total = allKanji.length;
    final studied = allKanji.where((k) => k.studied).length;
    final mastered = allKanji.where((k) => k.mastered).length;

    final studiedRatio = total == 0 ? 0.0 : studied / total;
    final masteredRatio = total == 0 ? 0.0 : mastered / total;

    final n5List = allKanji.where((k) => k.jlptLevel == 'N5').toList();
    final n5Studied = n5List.where((k) => k.studied).length;
    final n5Mastered = n5List.where((k) => k.mastered).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _labelRow('Studied',
                      '${(studiedRatio * 100).round()}%'),
                  const SizedBox(height: 6),
                  SimpleProgressBar(value: studiedRatio),
                  const SizedBox(height: 12),
                  _labelRow('Mastered',
                      '${(masteredRatio * 100).round()}%'),
                  const SizedBox(height: 6),
                  SimpleProgressBar(value: masteredRatio),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'JLPT Level Progress',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _jlptRow(
                    level: 'N5',
                    studied: n5Studied,
                    total: n5List.length,
                    mastered: n5Mastered,
                  ),
                  const SizedBox(height: 16),
                  _jlptRow(
                    level: 'N4',
                    studied: 0,
                    total: 0,
                    mastered: 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black54)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _jlptRow({
    required String level,
    required int studied,
    required int total,
    required int mastered,
  }) {
    final studiedRatio = total == 0 ? 0.0 : studied / total;
    final masteredRatio = total == 0 ? 0.0 : mastered / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F8ED),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(level),
            ),
            const SizedBox(width: 8),
            Text('$studied/$total studied'),
          ],
        ),
        const SizedBox(height: 8),
        SimpleProgressBar(value: studiedRatio),
        const SizedBox(height: 6),
        SimpleProgressBar(value: masteredRatio),
      ],
    );
  }
}