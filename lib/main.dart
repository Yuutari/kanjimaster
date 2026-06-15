import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/kanji_repository.dart';
import 'ui/screens/library_screen.dart';
import 'ui/screens/quiz_screen.dart';
import 'ui/screens/progress_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/settings_screen.dart';

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
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.load();
    // Восстанавливаем сохранённую тему
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('settings_dark_mode') ?? false;
    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
      _loaded = true;
    });
  }

  void _onThemeChanged(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanji Master',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C8CFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5FF),
        cardColor: Colors.white,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C8CFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        cardColor: const Color(0xFF16213E),
        useMaterial3: true,
      ),
      home: _loaded
          ? RootScreen(
              repository: _repo,
              themeMode: _themeMode,
              onThemeChanged: _onThemeChanged,
            )
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

class RootScreen extends StatefulWidget {
  final KanjiRepository repository;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const RootScreen({
    super.key,
    required this.repository,
    required this.themeMode,
    required this.onThemeChanged,
  });

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
      ProfileScreen(repository: widget.repository),
      SettingsScreen(
        currentTheme: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? const Color(0xFF16213E)
        : Colors.white;
    final selectedColor = const Color(0xFF9C8CFF);
    final unselectedColor =
        isDark ? Colors.grey[400]! : Colors.grey[600]!;

    const items = [
      (label: 'Library', icon: Icons.menu_book_outlined),
      (label: 'Quiz', icon: Icons.extension_outlined),
      (label: 'Progress', icon: Icons.trending_up_outlined),
      (label: 'Profile', icon: Icons.person_outline),
      (label: 'Settings', icon: Icons.settings_outlined),
    ];

    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin:
                    const EdgeInsets.symmetric(horizontal: 3),
                padding:
                    const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? selectedColor.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].icon,
                      size: 20,
                      color: selected
                          ? selectedColor
                          : unselectedColor,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? selectedColor
                            : unselectedColor,
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
