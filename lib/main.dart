import 'package:flutter/material.dart';
import 'data/kanji_repository.dart';
import 'ui/screens/library_screen.dart';
import 'ui/screens/quiz_screen.dart';
import 'ui/screens/progress_screen.dart';

void main() {
  runApp(const KanjiApp());
}

class KanjiApp extends StatefulWidget {
  const KanjiApp({super.key});

  @override
  State<KanjiApp> createState() => _KanjiAppState();
}

class _KanjiAppState extends State<KanjiApp> {
  final KanjiRepository _repo = KanjiRepository();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.load();
    setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanji Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C8CFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: _loaded
          ? RootScreen(repository: _repo)
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

class RootScreen extends StatefulWidget {
  final KanjiRepository repository;

  const RootScreen({super.key, required this.repository});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      LibraryScreen(repository: widget.repository),
      QuizScreen(repository: widget.repository),
      ProgressScreen(repository: widget.repository),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: _BottomNavBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNavBar({
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Library', Icons.menu_book_outlined),
      ('Quiz', Icons.extension_outlined),
      ('Progress', Icons.trending_up_outlined),
    ];

    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFEAE5FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].$2,
                      size: 20,
                      color: selected
                          ? const Color(0xFF9C8CFF)
                          : Colors.grey[600],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].$1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected
                            ? const Color(0xFF9C8CFF)
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}