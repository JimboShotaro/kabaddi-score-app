import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/models.dart';
import '../../domain/engine/match_engine.dart';

/// MatchEngineのProvider
final matchEngineProvider = Provider<MatchEngine>((ref) => MatchEngine());

/// UUIDジェネレーター
const _uuid = Uuid();

/// 試合状態を管理するNotifier
class MatchNotifier extends StateNotifier<MatchState?> {
  final MatchEngine _engine;

  MatchNotifier(this._engine) : super(null);

  /// 新しい試合を開始
  void startNewMatch({
    required String teamAName,
    required String teamBName,
  }) {
    final teamA = _createTeam(teamAName);
    final teamB = _createTeam(teamBName);
    
    state = _engine.createInitialState(
      teamA: teamA,
      teamB: teamB,
      startingRaidTeamId: teamA.id,
    );
  }

  /// テストデータで新しい試合を開始
  void startDemoMatch() {
    startNewMatch(
      teamAName: 'レッドイーグルス',
      teamBName: 'ブルータイガース',
    );
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
  }

  /// 試合をリセット
  void resetMatch() {
    state = null;
  }

  /// チームを作成
  Team _createTeam(String name) {
    final teamId = _uuid.v4();
    final players = List.generate(
      7,
      (i) => Player(
        id: _uuid.v4(),
        name: '$name ${i + 1}',
        jerseyNumber: i + 1,
      ),
    );
    return Team(id: teamId, name: name, players: players);
  }
}

/// 試合状態のProvider
final matchProvider = StateNotifierProvider<MatchNotifier, MatchState?>((ref) {
  final engine = ref.watch(matchEngineProvider);
  return MatchNotifier(engine);
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
