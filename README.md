# カバディスコア (Kabaddi Score App)

カバディ競技支援アプリケーション - Flutter製のクロスプラットフォームアプリ

## 概要

カバディの複雑な得点計算（復活、ローナ、スーパータックル等）を自動化し、審判・記録員の負荷を軽減します。また、インタラクティブなルールブック機能で初心者へのルール普及を支援します。

## 機能

### ✅ 実装済み機能

- **得点計算エンジン**
  - タッチポイント計算
  - ボーナスポイント計算
  - スーパータックル（守備側3人以下でのタックル成功時 +1点）
  - 復活ロジック（先にアウトになった選手から順番に復活）
  - ローナ判定（全員アウト時 +2点ボーナス）

- **試合管理UI**
  - スコアボード表示
  - チーム別選手パネル
  - レイダー選択・守備選手タッチ選択
  - 空レイド / タックル / レイド成功の記録

- **タイマー機能**
  - ハーフタイマー（20分）
  - レイドタイマー（30秒）

- **インタラクティブ・ルールブック**
  - コート図の可視化
  - 各ラインの説明
  - ルール解説

### 🚧 今後の実装予定

- レイド軌跡のアニメーション
- ローカルデータベース（試合データ保存）
- サーバー連携（Python/FastAPI）

## プロジェクト構造

```
lib/
├── main.dart
├── core/                   # 共通設定 (テーマ、定数)
│   └── app_theme.dart
├── data/                   # データ層
│   └── models/             # データモデル
│       ├── player.dart
│       ├── team.dart
│       ├── raid_result.dart
│       ├── match_state.dart
│       └── models.dart
├── domain/                 # ドメイン層
│   ├── engine/             # 得点計算エンジン
│   │   └── match_engine.dart
│   └── rules/              # ルール定義
│       └── kabaddi_rules.dart
└── presentation/           # UI層
    ├── providers/          # Riverpod状態管理
    │   ├── match_provider.dart
    │   └── timer_provider.dart
    ├── screens/            # 画面
    │   ├── home/
    │   ├── match/
    │   └── rulebook/
    └── widgets/            # 再利用可能ウィジェット
        ├── scoreboard_widget.dart
        ├── team_panel_widget.dart
        ├── raid_action_widget.dart
        ├── court_widget.dart
        └── timer_widget.dart
```

## 技術スタック

- **Flutter** - クロスプラットフォームUI
- **Dart** - プログラミング言語
- **Riverpod** - 状態管理
- **Equatable** - 値オブジェクトの等価性比較

## 開発環境セットアップ

```bash
# 依存関係のインストール
flutter pub get

# テストの実行
flutter test

# アプリの起動
flutter run
```

## テスト

12件のテストを含む：

- 基本テスト（初期状態、攻守交替）
- レイド成功テスト（タッチ、ボーナス）
- タックルテスト（通常、スーパータックル）
- 復活ロジックテスト
- ローナテスト
- ハーフ変更テスト

```bash
flutter test
```

## ライセンス

MIT License
