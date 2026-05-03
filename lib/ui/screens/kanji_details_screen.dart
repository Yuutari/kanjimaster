import 'package:flutter/material.dart';
import '../../models/kanji.dart';
import '../../data/kanji_repository.dart';

class KanjiDetailsScreen extends StatefulWidget {
  final Kanji kanji;
  final KanjiRepository repository;

  const KanjiDetailsScreen({
    super.key,
    required this.kanji,
    required this.repository,
  });

  @override
  State<KanjiDetailsScreen> createState() => _KanjiDetailsScreenState();
}

class _KanjiDetailsScreenState extends State<KanjiDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final k = widget.kanji;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F5FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kanji Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        k.char,
                        style: const TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Chip(
                        label: Text(k.meaning),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(k.jlptLevel),
                        backgroundColor: const Color(0xFFE5F8ED),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('${k.strokes} strokes'),
                        backgroundColor: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Readings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _readingGroup('On-yomi', k.onYomi),
                  const SizedBox(height: 8),
                  _readingGroup('Kun-yomi', k.kunYomi),
                  const SizedBox(height: 16),
                  const Text(
                    'Examples',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...k.examples.map(
                    (e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(e),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await widget.repository.toggleMastered(k);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27273F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  k.mastered ? 'Unmark Mastered' : 'Mark as Mastered',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readingGroup(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F1FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(e),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}