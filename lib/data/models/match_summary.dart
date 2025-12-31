import 'dart:convert';

/// 試合概要（履歴保存用）
class MatchSummary {
  /// 試合ID
  final String matchId;
  
  /// チームA名
  final String teamAName;
  
  /// チームB名
  final String teamBName;
  
  /// 最終スコアA
  final int finalScoreA;
  
  /// 最終スコアB
  final int finalScoreB;
  
  /// 試合日時
  final DateTime playedAt;
  
  /// 試合完了フラグ
  final bool isCompleted;
  
  /// 総レイド数
  final int totalRaids;

  const MatchSummary({
    required this.matchId,
    required this.teamAName,
    required this.teamBName,
    required this.finalScoreA,
    required this.finalScoreB,
    required this.playedAt,
    this.isCompleted = false,
    this.totalRaids = 0,
  });

  /// 勝者チーム名を取得
  String? get winner {
    if (!isCompleted) return null;
    if (finalScoreA > finalScoreB) return teamAName;
    if (finalScoreB > finalScoreA) return teamBName;
    return null; // 引き分け
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'teamAName': teamAName,
      'teamBName': teamBName,
      'finalScoreA': finalScoreA,
      'finalScoreB': finalScoreB,
      'playedAt': playedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'totalRaids': totalRaids,
    };
  }

  /// JSONから生成
  factory MatchSummary.fromJson(Map<String, dynamic> json) {
    return MatchSummary(
      matchId: json['matchId'] as String,
      teamAName: json['teamAName'] as String,
      teamBName: json['teamBName'] as String,
      finalScoreA: json['finalScoreA'] as int,
      finalScoreB: json['finalScoreB'] as int,
      playedAt: DateTime.parse(json['playedAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      totalRaids: json['totalRaids'] as int? ?? 0,
    );
  }

  /// JSON文字列に変換
  String toJsonString() => jsonEncode(toJson());

  /// JSON文字列から生成
  factory MatchSummary.fromJsonString(String jsonString) {
    return MatchSummary.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// コピー（一部変更）
  MatchSummary copyWith({
    String? matchId,
    String? teamAName,
    String? teamBName,
    int? finalScoreA,
    int? finalScoreB,
    DateTime? playedAt,
    bool? isCompleted,
    int? totalRaids,
  }) {
    return MatchSummary(
      matchId: matchId ?? this.matchId,
      teamAName: teamAName ?? this.teamAName,
      teamBName: teamBName ?? this.teamBName,
      finalScoreA: finalScoreA ?? this.finalScoreA,
      finalScoreB: finalScoreB ?? this.finalScoreB,
      playedAt: playedAt ?? this.playedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      totalRaids: totalRaids ?? this.totalRaids,
    );
  }

  @override
  String toString() {
    return 'MatchSummary(matchId: $matchId, $teamAName $finalScoreA - $finalScoreB $teamBName)';
  }
}
