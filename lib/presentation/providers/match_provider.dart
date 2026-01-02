import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/models.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/roster_repository.dart';
import '../../domain/engine/match_engine.dart';

/// MatchEngineのProvider
final matchEngineProvider = Provider<MatchEngine>((ref) => MatchEngine());

/// MatchRepositoryのProvider
final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => MatchRepository(),
);

/// RosterRepositoryのProvider
final rosterRepositoryProvider = Provider<RosterRepository>(
  (ref) => RosterRepository(),
);

/// UUIDジェネレーター
const _uuid = Uuid();

/// 現在の試合ID
String? _currentMatchId;
DateTime? _matchStartTime;

/// 試合状態を管理するNotifier
class MatchNotifier extends StateNotifier<MatchState?> {
  final MatchEngine _engine;
  final MatchRepository _repository;

  MatchNotifier(this._engine, this._repository) : super(null);

  /// 新しい試合を開始
  void startNewMatch({required String teamAName, required String teamBName}) {
    final teamA = _createTeam(teamAName);
    final teamB = _createTeam(teamBName);

    _currentMatchId = _uuid.v4();
    _matchStartTime = DateTime.now();

    state = _engine.createInitialState(
      teamA: teamA,
      teamB: teamB,
      startingRaidTeamId: teamA.id,
    );

    // 試合開始を保存
    _saveMatchProgress();
  }

  /// チームを指定して試合を初期化
  void initializeMatch(Team teamA, Team teamB) {
    _currentMatchId = _uuid.v4();
    _matchStartTime = DateTime.now();

    state = _engine.createInitialState(
      teamA: teamA,
      teamB: teamB,
      startingRaidTeamId: teamA.id,
    );

    _saveMatchProgress();
  }

  /// テストデータで新しい試合を開始
  void startDemoMatch() {
    startNewMatch(teamAName: 'レッドイーグルス', teamBName: 'ブルータイガース');
  }

  /// レイド結果を処理
  void processRaid(RaidResult result) {
    if (state == null) return;
    state = _engine.processRaid(state!, result);
  }

  /// 攻撃成功（タッチ）
  void recordSuccessfulRaid({
    required String raiderId,
    required List<String> touchedDefenderIds,
    bool isBonus = false,
  }) {
    if (state == null) return;

    final result = RaidResult(
      raiderTeamId: state!.raidingTeamId!,
      raiderId: raiderId,
      touchedDefenderIds: touchedDefenderIds,
      isBonus: isBonus,
      outcome: touchedDefenderIds.isEmpty
          ? RaidOutcome.empty
          : RaidOutcome.success,
    );

    state = _engine.processRaid(state!, result);
    // 攻守交替
    state = _engine.switchRaidingTeam(state!);
    _saveMatchProgress();
  }

  /// 守備成功（タックル）
  void recordTackle({required String raiderId}) {
    if (state == null) return;

    final result = RaidResult(
      raiderTeamId: state!.raidingTeamId!,
      raiderId: raiderId,
      isRaiderOut: true,
      outcome: RaidOutcome.tackled,
    );

    state = _engine.processRaid(state!, result);
    // 攻守交替
    state = _engine.switchRaidingTeam(state!);
    _saveMatchProgress();
  }

  /// 空レイド
  void recordEmptyRaid({required String raiderId}) {
    if (state == null) return;

    final result = RaidResult(
      raiderTeamId: state!.raidingTeamId!,
      raiderId: raiderId,
      outcome: RaidOutcome.empty,
    );

    state = _engine.processRaid(state!, result);
    // 攻守交替
    state = _engine.switchRaidingTeam(state!);
    _saveMatchProgress();
  }

  /// 攻守交替
  void switchTeams() {
    if (state == null) return;
    state = _engine.switchRaidingTeam(state!);
  }

  /// ハーフ変更
  void switchHalf() {
    if (state == null) return;
    state = _engine.switchHalf(state!);
    _saveMatchProgress();
  }

  /// 交代（控え ↔ コート上）
  Future<void> substitute({
    required String teamId,
    required String activePlayerId,
    required String benchPlayerId,
  }) async {
    if (state == null) return;

    final current = state!;
    final updatedTeamA =
        current.teamA.id == teamId
            ? current.teamA.substitute(
                activePlayerId: activePlayerId,
                benchPlayerId: benchPlayerId,
              )
            : current.teamA;
    final updatedTeamB =
        current.teamB.id == teamId
            ? current.teamB.substitute(
                activePlayerId: activePlayerId,
                benchPlayerId: benchPlayerId,
              )
            : current.teamB;

    state = current.copyWith(teamA: updatedTeamA, teamB: updatedTeamB);
    await _saveMatchProgress();
  }

  /// 試合終了
  Future<void> endMatch() async {
    if (state == null || _currentMatchId == null) return;

    final matchId = _currentMatchId!;
    final now = DateTime.now();
    final currentState = state!;

    final summary = MatchSummary(
      matchId: matchId,
      teamAName: currentState.teamA.name,
      teamBName: currentState.teamB.name,
      finalScoreA: currentState.scoreA,
      finalScoreB: currentState.scoreB,
      playedAt: _matchStartTime ?? now,
      isCompleted: true,
      endedAt: now,
      totalRaids: currentState.raidNumber,
    );

    await _repository.saveMatch(summary);
    await _repository.saveMatchDetail(
      matchId: matchId,
      teamA: currentState.teamA,
      teamB: currentState.teamB,
      raidLogs: currentState.raidLogs,
    );
    _currentMatchId = null;
    _matchStartTime = null;
  }

  /// 試合を中断して終了（履歴には「中断」として残す）
  Future<void> abandonMatch() async {
    if (state == null || _currentMatchId == null) return;

    final matchId = _currentMatchId!;
    final now = DateTime.now();
    final currentState = state!;

    final summary = MatchSummary(
      matchId: matchId,
      teamAName: currentState.teamA.name,
      teamBName: currentState.teamB.name,
      finalScoreA: currentState.scoreA,
      finalScoreB: currentState.scoreB,
      playedAt: _matchStartTime ?? now,
      isCompleted: false,
      endedAt: now,
      totalRaids: currentState.raidNumber,
    );

    await _repository.saveMatch(summary);
    await _repository.saveMatchDetail(
      matchId: matchId,
      teamA: currentState.teamA,
      teamB: currentState.teamB,
      raidLogs: currentState.raidLogs,
    );

    _currentMatchId = null;
    _matchStartTime = null;
  }

  /// 試合をリセット
  void resetMatch() {
    _currentMatchId = null;
    _matchStartTime = null;
    state = null;
  }

  /// 試合の進行状況を保存
  Future<void> _saveMatchProgress() async {
    if (state == null || _currentMatchId == null) return;

    final matchId = _currentMatchId!;
    final currentState = state!;

    final summary = MatchSummary(
      matchId: matchId,
      teamAName: currentState.teamA.name,
      teamBName: currentState.teamB.name,
      finalScoreA: currentState.scoreA,
      finalScoreB: currentState.scoreB,
      playedAt: _matchStartTime ?? DateTime.now(),
      isCompleted: false,
      endedAt: null,
      totalRaids: currentState.raidNumber,
    );

    await _repository.saveMatch(summary);
    await _repository.saveMatchDetail(
      matchId: matchId,
      teamA: currentState.teamA,
      teamB: currentState.teamB,
      raidLogs: currentState.raidLogs,
    );
  }

  /// チームを作成
  Team _createTeam(String name) {
    final teamId = _uuid.v4();
    final players = List.generate(
      7,
      (i) =>
          Player(id: _uuid.v4(), name: '$name ${i + 1}', jerseyNumber: i + 1),
    );
    return Team(id: teamId, name: name, players: players);
  }
}

/// 試合状態のProvider
final matchProvider = StateNotifierProvider<MatchNotifier, MatchState?>((ref) {
  final engine = ref.watch(matchEngineProvider);
  final repository = ref.watch(matchRepositoryProvider);
  return MatchNotifier(engine, repository);
});

/// 現在攻撃中のチームを取得
final raidingTeamProvider = Provider<Team?>((ref) {
  final match = ref.watch(matchProvider);
  return match?.raidingTeam;
});

/// 現在守備中のチームを取得
final defendingTeamProvider = Provider<Team?>((ref) {
  final match = ref.watch(matchProvider);
  return match?.defendingTeam;
});
