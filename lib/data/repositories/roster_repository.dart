import 'package:shared_preferences/shared_preferences.dart';

/// 保存済み名簿（選手名一覧）を管理するリポジトリ
class RosterRepository {
  static const _rosterNamesKey = 'saved_roster_names';

  Future<List<String>> getRosterNames() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_rosterNamesKey) ?? const <String>[];
    return names;
  }

  Future<void> addRosterNames(Iterable<String> names) async {
    final normalized = names
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    if (normalized.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_rosterNamesKey) ?? const <String>[];

    final merged = <String>{...existing, ...normalized}.toList()..sort();
    await prefs.setStringList(_rosterNamesKey, merged);
  }

  Future<void> clearRosterNames() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rosterNamesKey);
  }
}
