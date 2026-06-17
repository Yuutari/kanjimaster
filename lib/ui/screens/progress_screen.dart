import 'package:flutter/material.dart';
import '../../data/kanji_repository.dart';
import '../widgets/progress_bar.dart';

class ProgressScreen extends StatelessWidget {
  final KanjiRepository repository;

  const ProgressScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allKanji = repository.kanji;
    final total = allKanji.length;
    final studied = allKanji.where((k) => k.studied).length;
    final mastered = allKanji.where((k) => k.mastered).length;
    final studiedRatio = total == 0 ? 0.0 : studied / total;
    final masteredRatio = total == 0 ? 0.0 : mastered / total;
    final jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF7F5FF);
    final cardColor = isDark ? const Color(0xFF252540) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: total == 0
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 72,
                        color: subColor),
                    const SizedBox(height: 16),
                    Text('No kanji data yet',
                        style: TextStyle(fontSize: 18, color: subColor)),
                    const SizedBox(height: 8),
                    Text('Study some kanji to see your progress',
                        style: TextStyle(fontSize: 13, color: subColor)),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total kanji total',
                    style: TextStyle(fontSize: 14, color: subColor),
                  ),
                  const SizedBox(height: 20),

                  // Summary mini-stats row
                  Row(
                    children: [
                      _miniStat(context, '\uD83D\uDCDA', 'Total', '$total',
                          isDark ? const Color(0xFF2E2E50) : const Color(0xFFEEEBFF), textColor, subColor),
                      const SizedBox(width: 10),
                      _miniStat(context, '\u270F\uFE0F', 'Studied', '$studied',
                          isDark ? const Color(0xFF1E3A2F) : const Color(0xFFE5F8ED), textColor, subColor),
                      const SizedBox(width: 10),
                      _miniStat(context, '\u2B50', 'Mastered', '$mastered',
                          isDark ? const Color(0xFF3A2E00) : const Color(0xFFFFF8E1), textColor, subColor),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Overall progress card
                  _card(
                    cardColor: cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overall Progress',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        const SizedBox(height: 16),
                        _progressRow(
                          label: 'Studied',
                          value: '${(studiedRatio * 100).round()}%',
                          ratio: studiedRatio,
                          color: const Color(0xFF4CAF50),
                          textColor: textColor,
                          subColor: subColor,
                        ),
                        const SizedBox(height: 14),
                        _progressRow(
                          label: 'Mastered',
                          value: '${(masteredRatio * 100).round()}%',
                          ratio: masteredRatio,
                          color: const Color(0xFFFFB300),
                          textColor: textColor,
                          subColor: subColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // JLPT level breakdown
                  Text('JLPT Level Breakdown',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                  const SizedBox(height: 10),

                  for (final level in jlptLevels) ...[  
                    _jlptCard(
                      level: level,
                      allKanji: allKanji,
                      cardColor: cardColor,
                      textColor: textColor,
                      subColor: subColor,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _miniStat(
    BuildContext context,
    String emoji,
    String label,
    String value,
    Color bg,
    Color textColor,
    Color subColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: subColor)),
          ],
        ),
      ),
    );
  }

  Widget _card({required Color cardColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _progressRow({
    required String label,
    required String value,
    required double ratio,
    required Color color,
    required Color textColor,
    required Color subColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: subColor)),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _jlptCard({
    required String level,
    required List allKanji,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    required bool isDark,
  }) {
    final levelKanji = allKanji.where((k) => k.jlptLevel == level).toList();
    final levelTotal = levelKanji.length;
    final levelStudied = levelKanji.where((k) => k.studied).length;
    final levelMastered = levelKanji.where((k) => k.mastered).length;
    final studiedRatio = levelTotal == 0 ? 0.0 : levelStudied / levelTotal;
    final masteredRatio = levelTotal == 0 ? 0.0 : levelMastered / levelTotal;

    const levelColors = {
      'N5': Color(0xFF4CAF50),
      'N4': Color(0xFF2196F3),
      'N3': Color(0xFFFF9800),
      'N2': Color(0xFF9C27B0),
      'N1': Color(0xFFF44336),
    };
    final levelColor = levelColors[level] ?? const Color(0xFF607D8B);
    final badgeBg = isDark
        ? levelColor.withOpacity(0.25)
        : levelColor.withOpacity(0.12);

    return _card(
      cardColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                      color: levelColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                levelTotal == 0
                    ? 'No kanji'
                    : '$levelStudied / $levelTotal studied',
                style: TextStyle(color: subColor, fontSize: 13),
              ),
              const Spacer(),
              Text(
                levelTotal == 0
                    ? ''
                    : '$levelMastered mastered',
                style: TextStyle(
                    color: const Color(0xFFFFB300),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (levelTotal > 0) ...[  
            const SizedBox(height: 12),
            _progressRow(
              label: 'Studied',
              value: '${(studiedRatio * 100).round()}%',
              ratio: studiedRatio,
              color: levelColor,
              textColor: textColor,
              subColor: subColor,
            ),
            const SizedBox(height: 10),
            _progressRow(
              label: 'Mastered',
              value: '${(masteredRatio * 100).round()}%',
              ratio: masteredRatio,
              color: const Color(0xFFFFB300),
              textColor: textColor,
              subColor: subColor,
            ),
          ],
        ],
      ),
    );
  }
}
