import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kanjimaster/data/kanji_repository.dart';
import 'package:kanjimaster/ui/screens/profile_screen.dart';
import 'package:kanjimaster/ui/screens/quiz_screen.dart';
import 'package:kanjimaster/ui/screens/settings_screen.dart';

void main() {
  testWidgets('profile screen exposes registration controls', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(repository: KanjiRepository())),
    );

    expect(find.text('Register a new profile'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('settings screen exposes AI preferences', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    expect(find.text('Enable AI suggestions'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('quiz screen surfaces AI coaching guidance', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: QuizScreen(repository: KanjiRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('AI'), findsWidgets);
  });

  testWidgets('quiz screen offers JLPT levels and AI SRS setup', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: QuizScreen(repository: KanjiRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI SRS Quiz'), findsOneWidget);
    expect(find.text('JLPT level'), findsOneWidget);
    expect(find.text('N5'), findsOneWidget);
  });
}
