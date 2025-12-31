import 'package:equatable/equatable.dart';
import 'player.dart';

/// チームデータモデル
class Team extends Equatable {
  final String id;
  final String name;
  final List<Player> players;

  const Team({
    required this.id,
    required this.name,
    required this.players,
  });

  /// アクティブな選手のリスト
  List<Player> get activePlayers =>
      players.where((p) => p.status == PlayerStatus.active).toList();

  /// アウト中の選手のリスト（アウト順序でソート）
  List<Player> get outPlayers {
    final out = players.where((p) => p.status == PlayerStatus.out).toList();
    out.sort((a, b) => a.outOrder.compareTo(b.outOrder));
    return out;
  }

  /// アクティブな選手の数
  int get activeCount => activePlayers.length;

  /// アウト中の選手の数
  int get outCount => outPlayers.length;

  /// 全員アウトかどうか（ローナ判定用）
  bool get isAllOut => activeCount == 0;

  /// 選手を更新
  Team updatePlayer(Player updatedPlayer) {
    final updatedPlayers = players.map((p) {
      return p.id == updatedPlayer.id ? updatedPlayer : p;
    }).toList();
    return Team(id: id, name: name, players: updatedPlayers);
  }

  /// 指定した選手をアウトにする
  Team markPlayerOut(String playerId, int outOrder) {
    final player = players.firstWhere((p) => p.id == playerId);
    return updatePlayer(player.markAsOut(outOrder));
  }

  /// 最も早くアウトになった選手を復活させる
  Team reviveOldestOutPlayer() {
    if (outPlayers.isEmpty) return this;
    final oldest = outPlayers.first;
    return updatePlayer(oldest.revive());
  }

  /// 指定人数を復活させる
  Team revivePlayers(int count) {
    var team = this;
    for (int i = 0; i < count && team.outPlayers.isNotEmpty; i++) {
      team = team.reviveOldestOutPlayer();
    }
    return team;
  }

  /// 全員を復活させる
  Team reviveAllPlayers() {
    final revivedPlayers = players.map((p) {
      if (p.status == PlayerStatus.out) {
        return p.revive();
      }
      return p;
    }).toList();
    return Team(id: id, name: name, players: revivedPlayers);
  }

  Team copyWith({
    String? id,
    String? name,
    List<Player>? players,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      players: players ?? this.players,
    );
  }

  @override
  List<Object?> get props => [id, name, players];
}
