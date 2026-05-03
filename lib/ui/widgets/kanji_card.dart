import 'package:flutter/material.dart';
import '../../models/kanji.dart';
import '../../data/kanji_repository.dart';
import '../screens/kanji_details_screen.dart';

class KanjiCard extends StatelessWidget {
  final Kanji kanji;
  final KanjiRepository repository;

  const KanjiCard({
    super.key,
    required this.kanji,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => KanjiDetailsScreen(
              kanji: kanji,
              repository: repository,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              kanji.char,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              kanji.meaning,
              style: const TextStyle(fontSize: 12),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F8ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                kanji.jlptLevel,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF2E8B57),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}