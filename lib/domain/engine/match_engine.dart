import '../../data/models/models.dart';

/// カバディの得点計算エンジン
/// 
/// レイド結果を受け取り、新しい試合状態を返す純粋関数を提供
class MatchEngine {
  /// カバディのコート上の最大選手数
  static const int maxPlayersOnCourt = 7;
  
  /// スーパータックル成立条件（守備側人数）
  static const int superTackleThreshold = 3;
  
  /// ローナボーナスポイント
  static const int lonaBonus = 2;

  /// レイド結果を処理し、新しい試合状態を返す
  MatchState processRaid(MatchState current, RaidResult result) {
    var newState = current;
    
    // 攻撃側・守備側のチームを取得
    final bool isTeamARaiding = result.raiderTeamId == current.teamA.id;
    Team attackTeam = isTeamARaiding ? current.teamA : current.teamB;
    Team defenseTeam = isTeamARaiding ? current.teamB : current.teamA;
    
    int attackPoints = 0;
    int defensePoints = 0;
    int newOutOrderCounter = current.outOrderCounter;
    
    // スーパータックル判定（守備側が3人以下）
    final bool isSuperTackleEligible = defenseTeam.activeCount <= superTackleThreshold;
    
    if (!result.isRaiderOut) {
      // === 攻撃成功 ===
      
      // タッチポイント
      attackPoints += result.touchedDefenderIds.length;
      
      // ボーナスポイント
      if (result.isBonus) {
        attackPoints += 1;
      }
      
      // 守備選手をアウトにする
      for (final defenderId in result.touchedDefenderIds) {
        newOutOrderCounter++;
        defenseTeam = defenseTeam.markPlayerOut(defenderId, newOutOrderCounter);
      }
      
      // ローナ判定（守備側全員アウト）
      if (defenseTeam.isAllOut) {
        attackPoints += lonaBonus;
        // 守備側全員復活
        defenseTeam = defenseTeam.reviveAllPlayers();
        // ローナカウント更新
        if (isTeamARaiding) {
          newState = newState.copyWith(lonaCountA: newState.lonaCountA + 1);
        } else {
          newState = newState.copyWith(lonaCountB: newState.lonaCountB + 1);
        }
      }
      
      // 復活処理（攻撃側：獲得したタッチポイント分復活）
      attackTeam = attackTeam.revivePlayers(result.touchedDefenderIds.length);
      
    } else {
      // === 守備成功（タックル） ===
      
      defensePoints += 1;
      
      // スーパータックル成立
      if (isSuperTackleEligible) {
        defensePoints += 1;
      }
      
      // レイダーをアウトにする
      newOutOrderCounter++;
      attackTeam = attackTeam.markPlayerOut(result.raiderId, newOutOrderCounter);
      
      // ローナ判定（攻撃側全員アウト）
      if (attackTeam.isAllOut) {
        defensePoints += lonaBonus;
        // 攻撃側全員復活
        attackTeam = attackTeam.reviveAllPlayers();
        // ローナカウント更新
        if (!isTeamARaiding) {
          newState = newState.copyWith(lonaCountA: newState.lonaCountA + 1);
        } else {
          newState = newState.copyWith(lonaCountB: newState.lonaCountB + 1);
        }
      }
      
      // 復活処理（守備側：タックル成功で1人復活）
      defenseTeam = defenseTeam.revivePlayers(1);
    }
    
    // スコア更新
    final newScoreA = isTeamARaiding
        ? newState.scoreA + attackPoints
        : newState.scoreA + defensePoints;
    final newScoreB = isTeamARaiding
        ? newState.scoreB + defensePoints
        : newState.scoreB + attackPoints;
    
    // チーム更新
    final newTeamA = isTeamARaiding ? attackTeam : defenseTeam;
    final newTeamB = isTeamARaiding ? defenseTeam : attackTeam;
    
    // レイドログ追加
    final newLogs = [...newState.raidLogs, result];
    
    return newState.copyWith(
      teamA: newTeamA,
      teamB: newTeamB,
      scoreA: newScoreA,
      scoreB: newScoreB,
      raidNumber: newState.raidNumber + 1,
      outOrderCounter: newOutOrderCounter,
      raidLogs: newLogs,
    );
  }

  /// 新しい試合状態を作成
  MatchState createInitialState({
    required Team teamA,
    required Team teamB,
    String? startingRaidTeamId,
  }) {
    return MatchState(
      teamA: teamA,
      teamB: teamB,
      raidingTeamId: startingRaidTeamId ?? teamA.id,
    );
  }

  /// 攻守交替
  MatchState switchRaidingTeam(MatchState current) {
    final newRaidingTeamId = current.raidingTeamId == current.teamA.id
        ? current.teamB.id
        : current.teamA.id;
    return current.copyWith(raidingTeamId: newRaidingTeamId);
  }

  /// ハーフ変更
  MatchState switchHalf(MatchState current) {
    // ハーフ変更時に攻守交替
    final newRaidingTeamId = current.raidingTeamId == current.teamA.id
        ? current.teamB.id
        : current.teamA.id;
    
    // 両チームの選手を全員復活
    final revivedTeamA = current.teamA.reviveAllPlayers();
    final revivedTeamB = current.teamB.reviveAllPlayers();
    
    return current.copyWith(
      currentHalf: 2,
      raidingTeamId: newRaidingTeamId,
      teamA: revivedTeamA,
      teamB: revivedTeamB,
    );
  }
}
