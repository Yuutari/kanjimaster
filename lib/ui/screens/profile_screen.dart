import 'package:flutter/material.dart';
import '../../data/kanji_repository.dart';
import '../../models/kanji.dart';

class ProfileScreen extends StatefulWidget {
  final KanjiRepository repository;
  const ProfileScreen({super.key, required this.repository});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Student');
  String _targetLevel = 'N5';
  bool _editing = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allKanji = widget.repository.kanji;
    final total = allKanji.length;
    final studied = allKanji.where((k) => k.studied).length;
    final mastered = allKanji.where((k) => k.mastered).length;
    final studiedPct = total == 0 ? 0.0 : studied / total;
    final masteredPct = total == 0 ? 0.0 : mastered / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Avatar + name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFEAE5FF),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF9C8CFF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _editing
                        ? SizedBox(
                            width: 200,
                            child: TextField(
                              controller: _nameController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          )
                        : Text(
                            _nameController.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _editing = !_editing),
                      icon: Icon(
                        _editing ? Icons.check : Icons.edit,
                        size: 16,
                        color: const Color(0xFF9C8CFF),
                      ),
                      label: Text(
                        _editing ? 'Save' : 'Edit name',
                        style: const TextStyle(
                            color: Color(0xFF9C8CFF)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Target level
              _card(
                title: 'Target JLPT Level',
                child: DropdownButtonFormField<String>(
                  value: _targetLevel,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF7F5FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['N5', 'N4', 'N3', 'N2', 'N1']
                      .map((l) => DropdownMenuItem(
                            value: l,
                            child: Text(l),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _targetLevel = v ?? _targetLevel),
                ),
              ),

              const SizedBox(height: 16),

              // Stats summary
              _card(
                title: 'My Progress',
                child: Column(
                  children: [
                    _statRow('Total kanji', total.toString()),
                    const Divider(height: 16),
                    _statRow('Studied',
                        '$studied  (${(studiedPct * 100).toStringAsFixed(0)}%)'),
                    const Divider(height: 16),
                    _statRow('Mastered',
                        '$mastered  (${(masteredPct * 100).toStringAsFixed(0)}%)'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // JLPT breakdown
              _card(
                title: 'By JLPT Level',
                child: Column(
                  children: ['N5', 'N4', 'N3', 'N2', 'N1'].map((lvl) {
                    final lvlKanji =
                        allKanji.where((k) => k.jlptLevel == lvl).toList();
                    final lvlMastered =
                        lvlKanji.where((k) => k.mastered).length;
                    final pct = lvlKanji.isEmpty
                        ? 0.0
                        : lvlMastered / lvlKanji.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                              lvl,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                minHeight: 10,
                                value: pct,
                                backgroundColor:
                                    const Color(0xFFEEEEEE),
                                valueColor:
                                    const AlwaysStoppedAnimation(
                                        Color(0xFF9C8CFF)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$lvlMastered/${lvlKanji.length}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Reset button
              OutlinedButton.icon(
                onPressed: () => _confirmReset(context),
                icon: const Icon(Icons.refresh,
                    color: Colors.redAccent),
                label: const Text(
                  'Reset all progress',
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
            'All studied and mastered marks will be removed. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              for (final k in widget.repository.kanji) {
                k.studied = false;
                k.mastered = false;
              }
              await widget.repository.save();
              setState(() {});
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
