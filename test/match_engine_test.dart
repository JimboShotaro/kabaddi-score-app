import 'package:flutter_test/flutter_test.dart';
import 'package:kabaddi_app/data/models/models.dart';
import 'package:kabaddi_app/domain/engine/match_engine.dart';

void main() {
  late MatchEngine engine;
  late Team teamA;
  late Team teamB;
  late MatchState initialState;

  /// テスト用のチームを作成
  Team createTestTeam(String id, String name) {
    return Team(
      id: id,
      name: name,
      players: List.generate(
        7,
        (i) => Player(
          id: '${id}_player_$i',
          name: '$name Player ${i + 1}',
          jerseyNumber: i + 1,
        ),
      ),
    );
  }

  setUp(() {
    engine = MatchEngine();
    teamA = createTestTeam('teamA', 'Team A');
    teamB = createTestTeam('teamB', 'Team B');
    initialState = engine.createInitialState(
      teamA: teamA,
      teamB: teamB,
      startingRaidTeamId: teamA.id,
    );
  });

  group('MatchEngine - 基本テスト', () {
    test('初期状態が正しく作成される', () {
      expect(initialState.scoreA, 0);
      expect(initialState.scoreB, 0);
      expect(initialState.teamA.activeCount, 7);
      expect(initialState.teamB.activeCount, 7);
      expect(initialState.raidingTeamId, teamA.id);
    });

    test('攻守交替が正しく動作する', () {
      final switched = engine.switchRaidingTeam(initialState);
      expect(switched.raidingTeamId, teamB.id);

      final switchedBack = engine.switchRaidingTeam(switched);
      expect(switchedBack.raidingTeamId, teamA.id);
    });
  });

  group('MatchEngine - レイド成功', () {
    test('1人タッチで1点獲得', () {
      final result = RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[0].id,
        touchedDefenderIds: [teamB.players[0].id],
        outcome: RaidOutcome.success,
      );

      final newState = engine.processRaid(initialState, result);

      expect(newState.scoreA, 1);
      expect(newState.scoreB, 0);
      expect(newState.teamB.activeCount, 6); // 1人アウト
      expect(newState.teamB.outCount, 1);
    });

    test('3人タッチで3点獲得', () {
      final result = RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[0].id,
        touchedDefenderIds: [
          teamB.players[0].id,
          teamB.players[1].id,
          teamB.players[2].id,
        ],
        outcome: RaidOutcome.success,
      );

      final newState = engine.processRaid(initialState, result);

      expect(newState.scoreA, 3);
      expect(newState.teamB.activeCount, 4);
      expect(newState.teamB.outCount, 3);
    });

    test('ボーナスポイントで+1点', () {
      final result = RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[0].id,
        touchedDefenderIds: [teamB.players[0].id],
        isBonus: true,
        outcome: RaidOutcome.success,
      );

      final newState = engine.processRaid(initialState, result);

      expect(newState.scoreA, 2); // 1タッチ + 1ボーナス
    });
  });

  group('MatchEngine - タックル（守備成功）', () {
    test('通常タックルで1点', () {
      final result = RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[0].id,
        isRaiderOut: true,
        outcome: RaidOutcome.tackled,
      );

      final newState = engine.processRaid(initialState, result);

      expect(newState.scoreA, 0);
      expect(newState.scoreB, 1); // 守備側に1点
      expect(newState.teamA.activeCount, 6); // レイダーがアウト
    });

    test('スーパータックルで2点（守備側3人以下）', () {
      // 守備側を3人にする
      var state = initialState;
      for (int i = 0; i < 4; i++) {
        final result = RaidResult(
          raiderTeamId: teamA.id,
          raiderId: teamA.players[0].id,
          touchedDefenderIds: [teamB.players[i].id],
          outcome: RaidOutcome.success,
        );
        state = engine.processRaid(state, result);
      }
      
      expect(state.teamB.activeCount, 3);

      // スーパータックル
      final tackleResult = RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[0].id,
        isRaiderOut: true,
        outcome: RaidOutcome.tackled,
      );

      final newState = engine.processRaid(state, tackleResult);

      expect(newState.scoreB, state.scoreB + 2); // 通常1 + スーパー1
    });
  });

  group('MatchEngine - 復活ロジック', () {
    test('タッチ成功時に攻撃側のアウト選手が復活', () {
      // まずチームAの選手をアウトにする
      var state = initialState;
      final tackleResult = RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[0].id,
        isRaiderOut: true,
        outcome: RaidOutcome.tackled,
      );
      state = engine.processRaid(state, tackleResult);
      
      expect(state.teamA.outCount, 1);
      expect(state.teamA.activeCount, 6);

      // チームAが1人タッチ成功 → 1人復活
      final touchResult = RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[1].id,
        touchedDefenderIds: [teamB.players[0].id],
        outcome: RaidOutcome.success,
      );
      final newState = engine.processRaid(state, touchResult);

      expect(newState.teamA.activeCount, 7); // 復活して7人に
      expect(newState.teamA.outCount, 0);
    });

    test('復活は先にアウトになった選手から順番に', () {
      // チームAの選手を2人アウトにする
      var state = initialState;
      
      // 1人目アウト
      state = engine.processRaid(state, RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[0].id,
        isRaiderOut: true,
        outcome: RaidOutcome.tackled,
      ));
      
      // 2人目アウト
      state = engine.processRaid(state, RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[1].id,
        isRaiderOut: true,
        outcome: RaidOutcome.tackled,
      ));
      
      expect(state.teamA.outCount, 2);
      
      // アウト順序を確認
      final outPlayers = state.teamA.outPlayers;
      expect(outPlayers[0].id, teamA.players[0].id); // 先にアウト
      expect(outPlayers[1].id, teamA.players[1].id); // 後にアウト

      // 1人復活
      final touchResult = RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[2].id,
        touchedDefenderIds: [teamB.players[0].id],
        outcome: RaidOutcome.success,
      );
      final newState = engine.processRaid(state, touchResult);

      // 先にアウトになった選手が復活
      final player0 = newState.teamA.players.firstWhere((p) => p.id == teamA.players[0].id);
      final player1 = newState.teamA.players.firstWhere((p) => p.id == teamA.players[1].id);
      
      expect(player0.status, PlayerStatus.active); // 復活した
      expect(player1.status, PlayerStatus.out); // まだアウト
    });
  });

  group('MatchEngine - ローナ', () {
    test('全員アウトでローナボーナス+2点', () {
      var state = initialState;
      
      // チームBの7人全員をアウトにする
      for (int i = 0; i < 7; i++) {
        final result = RaidResult(
          raiderTeamId: teamA.id,
          raiderId: teamA.players[0].id,
          touchedDefenderIds: [teamB.players[i].id],
          outcome: RaidOutcome.success,
        );
        state = engine.processRaid(state, result);
      }
      
      // 7タッチ + ローナボーナス2 = 9点
      expect(state.scoreA, 9);
      expect(state.lonaCountA, 1);
      
      // ローナ後は全員復活
      expect(state.teamB.activeCount, 7);
    });
  });

  group('MatchEngine - ハーフ変更', () {
    test('ハーフ変更で攻守交替・全員復活', () {
      var state = initialState;
      
      // 選手を何人かアウトにする
      state = engine.processRaid(state, RaidResult(
        raiderTeamId: teamA.id,
        raiderId: teamA.players[0].id,
        touchedDefenderIds: [teamB.players[0].id, teamB.players[1].id],
        outcome: RaidOutcome.success,
      ));
      
      expect(state.teamB.outCount, 2);
      expect(state.raidingTeamId, teamA.id);

      // ハーフ変更
      final newHalfState = engine.switchHalf(state);
      
      expect(newHalfState.currentHalf, 2);
      expect(newHalfState.raidingTeamId, teamB.id); // 攻守交替
      expect(newHalfState.teamA.activeCount, 7); // 全員復活
      expect(newHalfState.teamB.activeCount, 7); // 全員復活
    });
  });
}
