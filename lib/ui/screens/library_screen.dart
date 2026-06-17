import 'package:flutter/material.dart';
import '../../data/kanji_repository.dart';
import '../widgets/kanji_card.dart';

class LibraryScreen extends StatefulWidget {
  final KanjiRepository repository;

  const LibraryScreen({super.key, required this.repository});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _query = '';
  String _levelFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final allKanji = widget.repository.kanji;
    final levels = ['All', 'N5', 'N4', 'N3', 'N2', 'N1'];

    final filtered = allKanji.where((k) {
      final q = _query.trim().toLowerCase();
      final byText = q.isEmpty ||
          k.char.contains(q) ||
          k.meaning.toLowerCase().contains(q);
      final byLevel =
          _levelFilter == 'All' || k.jlptLevel == _levelFilter;
      return byText && byLevel;
    }).toList();

    final total = allKanji.length;
    final studied = allKanji.where((k) => k.studied).length;
    final mastered = allKanji.where((k) => k.mastered).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            '漢字マスター',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search kanji...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: levels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final l = levels[index];
                final selected = l == _levelFilter;
                return ChoiceChip(
                  label: Text(l),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _levelFilter = l),
                  selectedColor: const Color(0xFF9C8CFF),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _statCard('Total', total.toString(), Colors.blue[50]!),
                _statCard('Studied', studied.toString(),
                    Colors.purple[50]!),
                _statCard('Mastered', mastered.toString(),
                    Colors.green[50]!),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: filtered.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  return KanjiCard(
                    kanji: filtered[index],
                    repository: widget.repository,
                                    onChanged: () => setState(() {}),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color bg) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
