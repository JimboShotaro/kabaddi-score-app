import 'package:equatable/equatable.dart';
import 'team.dart';
import 'raid_result.dart';

/// 試合の現在の状態を表すイミュータブルなクラス
class MatchState extends Equatable {
  /// チームA
  final Team teamA;
  
  /// チームB
  final Team teamB;
  
  /// チームAのスコア
  final int scoreA;
  
  /// チームBのスコア
  final int scoreB;
  
  /// 現在のハーフ（1 or 2）
  final int currentHalf;
  
  /// 現在攻撃中（レイド中）のチームID
  final String? raidingTeamId;
  
  /// 現在のレイド番号
  final int raidNumber;
  
  /// アウト順序のカウンター
  final int outOrderCounter;
  
  /// レイドログ
  final List<RaidResult> raidLogs;
  
  /// ローナ発生回数（チームA）
  final int lonaCountA;
  
  /// ローナ発生回数（チームB）
  final int lonaCountB;

  const MatchState({
    required this.teamA,
    required this.teamB,
    this.scoreA = 0,
    this.scoreB = 0,
    this.currentHalf = 1,
    this.raidingTeamId,
    this.raidNumber = 0,
    this.outOrderCounter = 0,
    this.raidLogs = const [],
    this.lonaCountA = 0,
    this.lonaCountB = 0,
  });

  /// 攻撃チームを取得
  Team? get raidingTeam {
    if (raidingTeamId == null) return null;
    return raidingTeamId == teamA.id ? teamA : teamB;
  }

  /// 守備チームを取得
  Team? get defendingTeam {
    if (raidingTeamId == null) return null;
    return raidingTeamId == teamA.id ? teamB : teamA;
  }

  /// 特定のチームIDから守備チームを取得
  Team getDefendingTeam(String attackingTeamId) {
    return attackingTeamId == teamA.id ? teamB : teamA;
  }

  /// 特定のチームIDからそのチームを取得
  Team getTeam(String teamId) {
    return teamId == teamA.id ? teamA : teamB;
  }

  /// スーパータックル可能かどうか（守備側が3人以下）
  bool isSuperTackleEligible(String defendingTeamId) {
    final defenders = getTeam(defendingTeamId);
    return defenders.activeCount <= 3;
  }

  MatchState copyWith({
    Team? teamA,
    Team? teamB,
    int? scoreA,
    int? scoreB,
    int? currentHalf,
    String? raidingTeamId,
    int? raidNumber,
    int? outOrderCounter,
    List<RaidResult>? raidLogs,
    int? lonaCountA,
    int? lonaCountB,
  }) {
    return MatchState(
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      currentHalf: currentHalf ?? this.currentHalf,
      raidingTeamId: raidingTeamId ?? this.raidingTeamId,
      raidNumber: raidNumber ?? this.raidNumber,
      outOrderCounter: outOrderCounter ?? this.outOrderCounter,
      raidLogs: raidLogs ?? this.raidLogs,
      lonaCountA: lonaCountA ?? this.lonaCountA,
      lonaCountB: lonaCountB ?? this.lonaCountB,
    );
  }

  @override
  List<Object?> get props => [
        teamA,
        teamB,
        scoreA,
        scoreB,
        currentHalf,
        raidingTeamId,
        raidNumber,
        outOrderCounter,
        raidLogs,
        lonaCountA,
        lonaCountB,
      ];
}
