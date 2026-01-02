import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_detail.dart';
import '../models/match_summary.dart';
import '../models/raid_result.dart';
import '../models/team.dart';

/// 試合履歴を管理するリポジトリ
class MatchRepository {
  static const String _matchHistoryKey = 'match_history';
  static const String _matchDetailPrefix = 'match_detail_';
  static const int _maxHistoryCount = 50;

  SharedPreferences? _prefs;

  /// SharedPreferencesのインスタンスを取得
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// 試合履歴を取得
  Future<List<MatchSummary>> getMatchHistory() async {
    final p = await prefs;
    final jsonList = p.getStringList(_matchHistoryKey) ?? [];

    return jsonList
        .map((jsonString) {
          try {
            return MatchSummary.fromJsonString(jsonString);
          } catch (e) {
            return null;
          }
        })
        .whereType<MatchSummary>()
        .toList();
  }

  /// 試合を保存
  Future<void> saveMatch(MatchSummary match) async {
    final p = await prefs;
    final history = await getMatchHistory();

    // 既存の試合を更新または追加
    final existingIndex = history.indexWhere((m) => m.matchId == match.matchId);
    if (existingIndex >= 0) {
      history[existingIndex] = match;
    } else {
      history.insert(0, match); // 新しい試合を先頭に追加
    }

    // 履歴の上限を超えたら古いものを削除
    while (history.length > _maxHistoryCount) {
      final removed = history.removeLast();
      await p.remove('$_matchDetailPrefix${removed.matchId}');
    }

    final jsonList = history.map((m) => m.toJsonString()).toList();
    await p.setStringList(_matchHistoryKey, jsonList);
  }

  /// 試合詳細（レイドログ）を保存
  Future<void> saveMatchDetail({
    required String matchId,
    required Team teamA,
    required Team teamB,
    required List<RaidResult> raidLogs,
  }) async {
    final p = await prefs;
    final detail = MatchDetail(
      matchId: matchId,
      teamA: teamA,
      teamB: teamB,
      raidLogs: raidLogs,
    );
    await p.setString('$_matchDetailPrefix$matchId', detail.toJsonString());
  }

  /// 試合詳細（レイドログ）を取得
  Future<MatchDetail?> getMatchDetail(String matchId) async {
    final p = await prefs;
    final jsonString = p.getString('$_matchDetailPrefix$matchId');
    if (jsonString == null) return null;
    try {
      return MatchDetail.fromJsonString(jsonString);
    } catch (_) {
      return null;
    }
  }

  /// 試合を削除
  Future<void> deleteMatch(String matchId) async {
    final p = await prefs;
    final history = await getMatchHistory();

    history.removeWhere((m) => m.matchId == matchId);

    await p.remove('$_matchDetailPrefix$matchId');

    final jsonList = history.map((m) => m.toJsonString()).toList();
    await p.setStringList(_matchHistoryKey, jsonList);
  }

  /// 特定の試合を取得
  Future<MatchSummary?> getMatch(String matchId) async {
    final history = await getMatchHistory();
    try {
      return history.firstWhere((m) => m.matchId == matchId);
    } catch (e) {
      return null;
    }
  }

  /// 全履歴をクリア
  Future<void> clearHistory() async {
    final p = await prefs;

    // 履歴に紐づく詳細データも削除
    final history = await getMatchHistory();
    for (final match in history) {
      await p.remove('$_matchDetailPrefix${match.matchId}');
    }
    await p.remove(_matchHistoryKey);
  }
}
