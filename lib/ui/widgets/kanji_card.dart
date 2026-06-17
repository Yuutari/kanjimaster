import 'package:flutter/material.dart';
import '../../models/kanji.dart';
import '../../data/kanji_repository.dart';
import '../screens/kanji_details_screen.dart';

class KanjiCard extends StatefulWidget {
  final Kanji kanji;
  final KanjiRepository repository;
    final VoidCallback? onChanged;

  const KanjiCard({
    super.key,
    required this.kanji,
    required this.repository,
        this.onChanged,
  });

  @override
  State<KanjiCard> createState() => _KanjiCardState();
}

class _KanjiCardState extends State<KanjiCard> {
  @override
  Widget build(BuildContext context) {
    final kanji = widget.kanji;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => KanjiDetailsScreen(
              kanji: kanji,
              repository: widget.repository,
            ),
          ),
        ).then((_) {
          if (mounted) setState(() {});
                    widget.onChanged?.call();
        });
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                if (kanji.mastered)
                  const Icon(Icons.star, size: 14, color: Color(0xFFFFD700))
                else if (kanji.studied)
                  const Icon(Icons.check_circle, size: 14, color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
