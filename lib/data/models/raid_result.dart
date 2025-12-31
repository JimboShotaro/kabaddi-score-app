import 'package:equatable/equatable.dart';

/// レイドの結果タイプ
enum RaidOutcome {
  /// レイド成功（タッチ獲得）
  success,
  /// レイダーがタックルされた
  tackled,
  /// 空レイド（得点なし）
  empty,
  /// ボーナスライン通過
  bonus,
}

/// レイド結果データモデル
class RaidResult extends Equatable {
  /// レイドを行ったチームのID
  final String raiderTeamId;
  
  /// レイダーのID
  final String raiderId;
  
  /// タッチした守備選手のIDリスト
  final List<String> touchedDefenderIds;
  
  /// ボーナスポイント獲得
  final bool isBonus;
  
  /// レイダーがアウトになったか
  final bool isRaiderOut;
  
  /// レイド結果
  final RaidOutcome outcome;

  const RaidResult({
    required this.raiderTeamId,
    required this.raiderId,
    this.touchedDefenderIds = const [],
    this.isBonus = false,
    this.isRaiderOut = false,
    required this.outcome,
  });

  /// タッチポイント数
  int get touchPoints => touchedDefenderIds.length;

  /// 合計獲得ポイント（ボーナス含む）
  int get totalAttackPoints {
    int points = touchPoints;
    if (isBonus) points += 1;
    return points;
  }

  @override
  List<Object?> get props => [
        raiderTeamId,
        raiderId,
        touchedDefenderIds,
        isBonus,
        isRaiderOut,
        outcome,
      ];
}
