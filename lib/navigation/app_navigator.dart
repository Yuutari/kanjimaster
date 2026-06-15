import 'package:flutter/material.dart';
import '../data/kanji_repository.dart';
import '../ui/screens/library_screen.dart';
import '../ui/screens/quiz_screen.dart';
import '../ui/screens/progress_screen.dart';
import 'main_tabs.dart';

/// Главный навигатор приложения. Отвечает за перенаправление между основными разделами.
class AppNavigator extends StatelessWidget {
  final KanjiRepository repository;

  const AppNavigator({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MainTabs(
      tabs: [
        LibraryScreen(repository: repository),
        QuizScreen(repository: repository),
        ProgressScreen(repository: repository),
      ],
      tabLabels: const ['Library', 'Quiz', 'Progress'],
      tabIcons: const [
        Icons.menu_book_outlined,
        Icons.extension_outlined,
        Icons.trending_up_outlined,
      ],
    );
  }
}
