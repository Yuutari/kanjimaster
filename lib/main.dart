import 'package:flutter/material.dart';
import 'data/kanji_repository.dart';
import 'ui/screens/library_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/quiz_screen.dart';
import 'ui/screens/progress_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
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
    // Load theme preference
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('settings_dark_mode') ?? false;
    try {
      await _repo.load();
    } catch (e) {
      debugPrint('Init error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
          _loaded = true;
        });
      }
    }
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
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C8CFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        useMaterial3: true,
      ),
      home: _loaded
          ? RootScreen(
              repository: _repo,
              onThemeChanged: _onThemeChanged,
              themeMode: _themeMode,
            )
          : const _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF27273F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF9C8CFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  '漢',
                  style: TextStyle(
                    fontSize: 44,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kanji Master',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Loading kanji...',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C8CFF)),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  final KanjiRepository repository;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ThemeMode themeMode;

  const RootScreen({
    super.key,
    required this.repository,
    required this.onThemeChanged,
    required this.themeMode,
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
        onThemeChanged: widget.onThemeChanged,
        currentTheme: widget.themeMode,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2A2A3E) : Colors.white;
    final selectedColor = const Color(0xFF9C8CFF);
    final unselectedColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final selectedBg = isDark ? const Color(0xFF3A3A5E) : const Color(0xFFEAE5FF);

    final items = [
      ('Library', Icons.menu_book_outlined),
      ('Quiz', Icons.extension_outlined),
      ('Progress', Icons.trending_up_outlined),
      ('Profile', Icons.person_outline),
      ('Settings', Icons.settings_outlined),
    ];

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: selected ? selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].$2,
                      size: 20,
                      color: selected ? selectedColor : unselectedColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].$1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected ? selectedColor : unselectedColor,
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
