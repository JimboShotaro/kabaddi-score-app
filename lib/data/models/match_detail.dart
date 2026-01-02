import 'dart:convert';

import 'raid_result.dart';
import 'team.dart';

/// 試合詳細（レイドログなど）
///
/// SharedPreferences で matchId ごとに保存し、履歴から再閲覧するためのデータ。
class MatchDetail {
  final String matchId;
  final Team? teamA;
  final Team? teamB;
  final List<RaidResult> raidLogs;

  const MatchDetail({
    required this.matchId,
    this.teamA,
    this.teamB,
    required this.raidLogs,
  });

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'teamA': teamA?.toJson(),
      'teamB': teamB?.toJson(),
      'raidLogs': raidLogs.map((e) => e.toJson()).toList(),
    };
  }

  factory MatchDetail.fromJson(Map<String, dynamic> json) {
    return MatchDetail(
      matchId: json['matchId'] as String,
      teamA: json['teamA'] == null
          ? null
          : Team.fromJson(json['teamA'] as Map<String, dynamic>),
      teamB: json['teamB'] == null
          ? null
          : Team.fromJson(json['teamB'] as Map<String, dynamic>),
      raidLogs: (json['raidLogs'] as List<dynamic>? ?? const [])
          .map((e) => RaidResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory MatchDetail.fromJsonString(String jsonString) {
    return MatchDetail.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
