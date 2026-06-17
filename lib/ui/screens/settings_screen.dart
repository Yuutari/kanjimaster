import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Экран настроек приложения.
/// Хранит выбранную тему и предпочтения в SharedPreferences.
class SettingsScreen extends StatefulWidget {
  final ValueChanged<ThemeMode>? onThemeChanged;
  final ThemeMode currentTheme;

  const SettingsScreen({
    super.key,
    this.onThemeChanged,
    this.currentTheme = ThemeMode.light,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _darkMode;
  late bool _soundEnabled;
  late bool _notificationsEnabled;
  late bool _romajiEnabled;
  late String _quizOrder;
  late int _dailyGoal;

  static const _kDark = 'settings_dark_mode';
  static const _kSound = 'settings_sound';
  static const _kNotif = 'settings_notifications';
  static const _kRomaji = 'settings_romaji';
  static const _kOrder = 'settings_quiz_order';
  static const _kGoal = 'settings_daily_goal';

  @override
  void initState() {
    super.initState();
    _darkMode = widget.currentTheme == ThemeMode.dark;
    _soundEnabled = true;
    _notificationsEnabled = true;
    _romajiEnabled = false;
    _quizOrder = 'random';
    _dailyGoal = 10;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = p.getBool(_kDark) ?? (widget.currentTheme == ThemeMode.dark);
      _soundEnabled = p.getBool(_kSound) ?? true;
      _notificationsEnabled = p.getBool(_kNotif) ?? true;
      _romajiEnabled = p.getBool(_kRomaji) ?? false;
      _quizOrder = p.getString(_kOrder) ?? 'random';
      _dailyGoal = p.getInt(_kGoal) ?? 10;
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDark, _darkMode);
    await p.setBool(_kSound, _soundEnabled);
    await p.setBool(_kNotif, _notificationsEnabled);
    await p.setBool(_kRomaji, _romajiEnabled);
    await p.setString(_kOrder, _quizOrder);
    await p.setInt(_kGoal, _dailyGoal);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SwitchListTile.adaptive(
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() => _darkMode = value);
                      _savePrefs();
                      widget.onThemeChanged?.call(value ? ThemeMode.dark : ThemeMode.light);
                    },
                    title: const Text('Enable AI suggestions'),
                    subtitle: const Text('Use AI tips in the quiz flow.'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Внешний вид
              _sectionTitle('Appearance'),
              _card([
                _switchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  value: _darkMode,
                  onChanged: (v) {
                    final nextMode = v ? ThemeMode.dark : ThemeMode.light;
                    setState(() => _darkMode = v);
                    _savePrefs();
                    widget.onThemeChanged?.call(nextMode);
                  },
                ),
              ]),

              const SizedBox(height: 16),

              // Обучение
              _sectionTitle('Learning'),
              _card([
                _switchTile(
                  icon: Icons.translate,
                  title: 'Show Romaji',
                  subtitle: 'Display romanized reading',
                  value: _romajiEnabled,
                  onChanged: (v) {
                    setState(() => _romajiEnabled = v);
                    _savePrefs();
                  },
                ),
                const Divider(height: 1),
                _dropdownTile(
                  icon: Icons.shuffle,
                  title: 'Quiz Order',
                  value: _quizOrder,
                  items: const {
                    'random': 'Random',
                    'jlpt': 'By JLPT Level',
                    'weak': 'Weak Kanji First',
                  },
                  onChanged: (v) {
                    setState(() => _quizOrder = v!);
                    _savePrefs();
                  },
                ),
                const Divider(height: 1),
                _stepperTile(
                  icon: Icons.flag_outlined,
                  title: 'Daily Goal',
                  subtitle: 'Kanji to study per day',
                  value: _dailyGoal,
                  min: 5,
                  max: 50,
                  step: 5,
                  onChanged: (v) {
                    setState(() => _dailyGoal = v);
                    _savePrefs();
                  },
                ),
              ]),

              const SizedBox(height: 16),

              // Уведомления
              _sectionTitle('Notifications'),
              _card([
                _switchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Daily Reminders',
                  subtitle: 'Remind me to study every day',
                  value: _notificationsEnabled,
                  onChanged: (v) {
                    setState(() => _notificationsEnabled = v);
                    _savePrefs();
                  },
                ),
                const Divider(height: 1),
                _switchTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Sound Effects',
                  subtitle: 'Play sounds during quiz',
                  value: _soundEnabled,
                  onChanged: (v) {
                    setState(() => _soundEnabled = v);
                    _savePrefs();
                  },
                ),
              ]),

              const SizedBox(height: 16),

              // О приложении
              _sectionTitle('About'),
              _card([
                ListTile(
                  leading: Icon(Icons.info_outline,
                      color: scheme.primary),
                  title: const Text('Version'),
                  trailing: const Text('1.0.0',
                      style: TextStyle(color: Colors.grey)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code,
                      color: scheme.primary),
                  title: const Text('KanjiMaster'),
                  subtitle: const Text(
                      'Flutter · Dart · SQLite'),
                ),
              ]),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon,
          color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12)),
      value: value,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: onChanged,
    );
  }

  Widget _dropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _stepperTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required int value,
    required int min,
    required int max,
    required int step,
    required ValueChanged<int> onChanged,
  }) {
    return ListTile(
      leading:
          Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > min
                ? () => onChanged(value - step)
                : null,
          ),
          Text(
            '$value',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value < max
                ? () => onChanged(value + step)
                : null,
          ),
        ],
      ),
    );
  }
}
