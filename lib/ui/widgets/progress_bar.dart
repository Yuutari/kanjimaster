import 'package:flutter/material.dart';

class SimpleProgressBar extends StatelessWidget {
  final double value;

  const SimpleProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 8,
        value: value.clamp(0, 1),
        backgroundColor: const Color(0xFFE4E4EF),
        valueColor: const AlwaysStoppedAnimation(Color(0xFF27273F)),
      ),
    );
  }
}