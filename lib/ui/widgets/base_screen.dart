import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Базовый экран приложения с единым фоном и отступами.
/// Оборачивает содержимое в Scaffold с настройками из AppTheme.
class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showAppBar;

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: AppTheme.background,
              elevation: 0,
              centerTitle: true,
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black87),
              actions: actions,
            )
          : null,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
