import 'package:flutter/material.dart';

/// Основная навигация с нижним tab-баром.
/// Принимает список виджетов, метки и иконки для табов.
class MainTabs extends StatefulWidget {
  final List<Widget> tabs;
  final List<String> tabLabels;
  final List<IconData> tabIcons;

  const MainTabs({
    super.key,
    required this.tabs,
    required this.tabLabels,
    required this.tabIcons,
  });

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.tabs[_index],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.tabs.length, (i) {
            final selected = i == _index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _index = i),
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
                        widget.tabIcons[i],
                        size: 20,
                        color: selected
                            ? const Color(0xFF9C8CFF)
                            : Colors.grey[600],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.tabLabels[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
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
      ),
    );
  }
}
