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

  /// JSONに変換（SharedPreferences 永続化用）
  Map<String, dynamic> toJson() {
    return {
      'raiderTeamId': raiderTeamId,
      'raiderId': raiderId,
      'touchedDefenderIds': touchedDefenderIds,
      'isBonus': isBonus,
      'isRaiderOut': isRaiderOut,
      'outcome': outcome.name,
    };
  }

  /// JSONから生成
  factory RaidResult.fromJson(Map<String, dynamic> json) {
    return RaidResult(
      raiderTeamId: json['raiderTeamId'] as String,
      raiderId: json['raiderId'] as String,
      touchedDefenderIds:
          (json['touchedDefenderIds'] as List<dynamic>? ?? const [])
              .map((e) => e as String)
              .toList(),
      isBonus: json['isBonus'] as bool? ?? false,
      isRaiderOut: json['isRaiderOut'] as bool? ?? false,
      outcome: RaidOutcome.values.byName(json['outcome'] as String),
    );
  }

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
