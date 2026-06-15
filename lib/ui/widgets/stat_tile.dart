import 'package:flutter/material.dart';

/// Карточка статистики — отображает название и значение.
/// Используется на экране библиотеки и прогресса.
class StatTile extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;

  const StatTile({
    super.key,
    required this.title,
    required this.value,
    this.backgroundColor = const Color(0xFFF3F1FF),
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
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
