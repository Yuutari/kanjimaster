// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kanjimaster/main.dart';
import 'package:kanjimaster/ui/screens/quiz_screen.dart';

void main() {
  testWidgets('app launches and shows the loading state', (tester) async {
    await tester.pumpWidget(const KanjiApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('quiz results summary renders completion stats', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QuizResultsView(
          correct: 15,
          total: 20,
          missed: 5,
          onRestart: () {},
          onExit: () {},
        ),
      ),
    );

    expect(find.text('Quiz complete'), findsOneWidget);
    expect(find.text('15 of 20 correct'), findsOneWidget);
    expect(find.text('5 missed kanji ready to review'), findsOneWidget);
  });
}
