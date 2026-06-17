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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF7F5FF);
    final cardColor = isDark ? const Color(0xFF252540) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    final allKanji = widget.repository.kanji;
    final levels = ['All', 'N5', 'N4', 'N3', 'N2', 'N1'];

    final filtered = allKanji.where((k) {
      final q = _query.trim().toLowerCase();
      final byText = q.isEmpty ||
          k.char.contains(q) ||
          k.meaning.toLowerCase().contains(q);
      final byLevel = _levelFilter == 'All' || k.jlptLevel == _levelFilter;
      return byText && byLevel;
    }).toList();

    final total = allKanji.length;
    final studied = allKanji.where((k) => k.studied).length;
    final mastered = allKanji.where((k) => k.mastered).length;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: total == 0
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_rounded,
                          size: 80, color: subColor),
                      const SizedBox(height: 20),
                      Text(
                        'No kanji yet',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: textColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kanji data is loading or not available.\nPlease check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: subColor),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    '漢字マスター',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Search kanji...',
                        hintStyle: TextStyle(color: subColor),
                        filled: true,
                        fillColor: cardColor,
                        prefixIcon: Icon(Icons.search, color: subColor),
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
                          selectedColor: isDark
                              ? const Color(0xFF7A69E8)
                              : const Color(0xFF9C8CFF),
                          backgroundColor: cardColor,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : textColor,
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
                        _statCard(
                          'Total',
                          total.toString(),
                          isDark
                              ? const Color(0xFF2E2E50)
                              : const Color(0xFFEEEBFF),
                          textColor,
                          subColor,
                        ),
                        _statCard(
                          'Studied',
                          studied.toString(),
                          isDark
                              ? const Color(0xFF2E2E50)
                              : const Color(0xFFEAE5FF),
                          textColor,
                          subColor,
                        ),
                        _statCard(
                          'Mastered',
                          mastered.toString(),
                          isDark
                              ? const Color(0xFF1E3A2F)
                              : const Color(0xFFE5F8ED),
                          textColor,
                          subColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty && _query.isNotEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: subColor),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                  fontSize: 13, color: subColor),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
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
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    Color bg,
    Color textColor,
    Color subColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 11, color: subColor)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
