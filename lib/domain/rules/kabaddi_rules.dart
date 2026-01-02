/// カバディのルール定義
class KabaddiRules {
  /// 1チームのコート上最大人数
  static const int maxPlayersOnCourt = 7;

  /// 1チームの登録選手数
  static const int squadSize = 12;

  /// 1ハーフの時間（秒）
  static const int halfDurationSeconds = 20 * 60; // 20分

  /// レイドの制限時間（秒）
  static const int raidTimeLimit = 30;

  /// ボーナスライン通過条件：守備側6人以上
  static const int bonusLineMinDefenders = 6;

  /// スーパータックル条件：守備側3人以下
  static const int superTackleMaxDefenders = 3;

  /// ローナボーナスポイント
  static const int lonaBonus = 2;

  /// スーパータックルボーナス
  static const int superTackleBonus = 1;
}

/// コートのエリア定義
enum CourtArea {
  /// ロビー（両サイド）
  lobby,

  /// ボークライン
  baulkLine,

  /// ボーナスライン
  bonusLine,

  /// ミッドライン
  midLine,

  /// エンドライン
  endLine,
}

/// コートエリアの説明
extension CourtAreaDescription on CourtArea {
  String get name {
    switch (this) {
      case CourtArea.lobby:
        return 'ロビー';
      case CourtArea.baulkLine:
        return 'ボークライン';
      case CourtArea.bonusLine:
        return 'ボーナスライン';
      case CourtArea.midLine:
        return 'ミッドライン';
      case CourtArea.endLine:
        return 'エンドライン';
    }
  }

  String get description {
    switch (this) {
      case CourtArea.lobby:
        return 'レイダーがこのエリアに入ると、タッチした守備者を確保するためのセーフゾーンになります。';
      case CourtArea.baulkLine:
        return 'レイダーはこのラインを越えて相手コートに入らなければなりません。越えずに戻ると空レイドになります。';
      case CourtArea.bonusLine:
        return '守備側が6人以上いる場合、レイダーがこのラインを越えるとボーナスポイント（+1点）を獲得します。';
      case CourtArea.midLine:
        return 'コートを二分するライン。レイダーはこのラインを越えて相手陣地に侵入します。';
      case CourtArea.endLine:
        return 'コートの端のライン。このラインを越えるとアウトになります。';
    }
  }
}
