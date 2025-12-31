import 'package:equatable/equatable.dart';

/// 選手の状態
enum PlayerStatus {
  /// コート上で活動中
  active,
  /// アウトでベンチ待機中
  out,
  /// 試合に参加していない（控え）
  bench,
}

/// 選手データモデル
class Player extends Equatable {
  final String id;
  final String name;
  final int jerseyNumber;
  final PlayerStatus status;
  final int outOrder; // アウトになった順番（復活順序用）

  const Player({
    required this.id,
    required this.name,
    required this.jerseyNumber,
    this.status = PlayerStatus.active,
    this.outOrder = 0,
  });

  /// アウト状態にする
  Player markAsOut(int order) {
    return Player(
      id: id,
      name: name,
      jerseyNumber: jerseyNumber,
      status: PlayerStatus.out,
      outOrder: order,
    );
  }

  /// 復活させる
  Player revive() {
    return Player(
      id: id,
      name: name,
      jerseyNumber: jerseyNumber,
      status: PlayerStatus.active,
      outOrder: 0,
    );
  }

  Player copyWith({
    String? id,
    String? name,
    int? jerseyNumber,
    PlayerStatus? status,
    int? outOrder,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      status: status ?? this.status,
      outOrder: outOrder ?? this.outOrder,
    );
  }

  @override
  List<Object?> get props => [id, name, jerseyNumber, status, outOrder];
}
