# Google Play公開用手続き（TODOまとめ）

このドキュメントは、Google Play（Play Console）へAndroidアプリを公開するために必要な準備を、実務のチェックリストとして整理したものです。

- 参考: https://pochanglab.com/blog/personal_android_app?lang=ja
- このプロジェクトのAndroidアプリ本体: `./`

## このプロジェクトの決定事項・進捗（記録）

最終更新: 2026-01-03

- アプリ名（表示名）: 「カバディーアプリ」
- Android applicationId: `jp.shotaroJimbo.kabaddi`
- iOS/macOS bundle id: `jp.shotaroJimbo.kabaddi`
- 検証: `flutter build appbundle --release` でAAB生成OK（Windows上で確認、出力: `build/app/outputs/bundle/release/app-release.aab`）
    - 補足: `MainActivity.kt` の重複（`com/example/...` と `jp/shotaroJimbo/...`）を解消してビルド成功

- Androidリリース署名（現状）
    - 署名設定の仕組みは実装済み（`android/app/build.gradle.kts` が `android/key.properties` を読む）
    - `android/key.properties.example` あり（雛形）
    - 実際の keystore（アップロードキー）作成と `key.properties` 作成はこれから（※いったん保留）
    - iOSビルド（`flutter build ios`）はmacOS環境が必要なため、このPC（Windows）では未検証

---

## 0. 前提（方針の決定）

- [x] 公開するアプリ名（ストア表示名）を決める（「カバディーアプリ」）
- [x] アプリのパッケージ名（applicationId）を確定する（`jp.shotaroJimbo.kabaddi`）
- [ ] 配信対象（まずは Phone のみ、地域/言語、無料/有料）を決める
- [ ] 収益化（広告/課金）を行うか決める（行う場合は追加の申告が増える）

---

## 1. 開発者アカウント（Play Console）

- [ ] Google Play Console 開発者アカウント登録
- [ ] 個人/組織の選択と本人確認
- [ ] 連絡先/支払い情報の登録
- [ ] （有料・課金を行う場合）税務/決済関連の設定

---

## 2. 技術準備（Android）

### 2-1. 配布形式（AAB）

- [ ] 新規公開はAndroid App Bundle（`.aab`）で提出する（APKではなくAAB）
- [x] リリース用ビルドがAABで生成できることを確認（`flutter build appbundle --release`）

### 2-2. 署名（Play App Signing / アップロードキー）

- [ ] Play App Signing を利用する前提で進める
- [ ] アップロードキー（keystore）を作成し安全に保管する
- [ ] 署名設定（release）をプロジェクトに設定する（秘密情報はGitに入れない）

#### 手順（手元作業）

- 手元作業が必要な手順は `googlePlay公開用手続き_手動.md` にまとめています

### 2-3. ターゲットAPI（targetSdk）

- [ ] Play公開要件を満たす targetSdk に設定されていることを確認（要件は年次で更新される）

### 2-4. リリースビルド設定

- [x] `versionCode` / `versionName` の運用ルールを決める（アップデートのたびに必ず増える）
    - **更新場所**: `pubspec.yaml` の `version: x.y.z+N`
    - **versionName**: `x.y.z`（例: `1.0.0`）
    - **versionCode**: `N`（例: `1`）。リリースごとに必ず +1 する
    - **例**: `version: 1.0.0+1` → 次のリリースは `version: 1.0.1+2`
- [ ] リリース前に `version` を更新した上でAABを作成する
    - 手順: `pubspec.yaml` の `version` 更新 → `flutter build appbundle --release`
- [ ] （必要に応じて）R8/minify/shrinkResources を検討
- [ ] （難読化を使う場合）`mapping.txt` を Play Console へアップロードできる運用にする

---

## 3. Play Console設定（アプリ作成）

- [x] Play Console でアプリを作成（デフォルト言語・アプリ名・無料/有料）
    - **設定**: 無料アプリ
- [x] 配信する国/地域（価格）を設定
    - **設定**: 日本
- [x] デバイスカテゴリ（まずは Phone/Tablet）を選択
    - **設定**: Phone（まずはスマートフォン向け）

---

## 4. ストア掲載情報・ポリシー申告

### 4-1. ストア素材（最低限）

- [ ] アプリアイコン（512×512 PNG）
- [ ] 機能グラフィック（1024×500）
- [ ] スクリーンショット（まずは Phone）
    - [ ] 余裕があれば Large screens（タブレット/Chromebook）用のスクショも検討
- **準備用フォルダ**: `kabaddi_app_image_v1/` に必要な画像サイズ等を記載したREADMEとフォルダを用意しました。ここに素材を入れてください。

### 4-2. データセーフティ（Data safety）

- [ ] アプリが収集/共有するデータを棚卸しする（サードパーティSDK含む）
- [ ] 実装と申告が一致していることを確認する（不一致はリジェクト要因）

### 4-3. プライバシーポリシーURL

- [ ] プライバシーポリシーを「URL」で用意する
    - **雛形**: `docs/privacy_policy_template.md` を作成しました。内容を調整してブログやGitHub Pages等に掲載してください。
    - [ ] ログイン不要で誰でもアクセス可能
    - [ ] 常時公開
    - [ ] 地理制限なし
    - [ ] 静的ページ（PDF不可とされるケースがあるため避ける）

### 4-4. ターゲット年齢 / コンテンツレーティング

- [x] Target audience & content を回答
    - **ターゲット**: カバディープレイヤー（年齢層は13歳以上などを選択推奨）
    - ※子供向け（13歳未満）を含めると要件が厳しくなるため、特段の理由がなければ13歳以上を選択するのが無難です。
- [x] IARC の質問に回答してレーティング取得
    - **方針**: スポーツツールのため、暴力・恐怖・性的表現などは「いいえ」を選択し、全年齢対象（3+）を目指します。

### 4-5. その他の宣言

- [x] 広告の有無を申告
    - **設定**: 「はい、アプリには広告が含まれています」を選択
- [x] アクセス制限（ログイン必須等）の有無を申告
    - **設定**: 「一部またはすべての機能が制限されている」を選択
    - ※審査用ログインアカウント（ID/Pass）の提供が必要になります。
- [x] 制限付き権限（例: バックグラウンド位置情報等）を使っていないことを確認し、使う場合は追加要件を満たす
    - **設定**: 使用しない

---

## 5. テスト運用（公開前）

- [ ] Internal test（内部テスト）で動作確認（配布が速い）
- [ ] Closed test（クローズドテスト）を開始
- [ ] 新規個人アカウントの場合、12人が14日間連続でオプトインしていることを満たす運用をする
    - [ ] テスター向け案内（試して欲しい機能、報告の仕方、連絡先）を準備
    - [ ] テスターが途中でオプトアウトしないように運用する（連続性が重要）
- [ ] フィードバック収集 → 要約 → 改善内容を記録

---

## 6. Production access申請〜本番リリース

- [ ] Production access を申請（必要項目を埋める）
- [ ] 審査対応（追加対応が求められた場合に備える）
- [ ] 承認後、段階的ロールアウト（例: 5%→20%→50%→100%）で配信

---

## 7. 公開後の運用

- [ ] Pre-launch report / Android Vitals を監視
- [ ] クラッシュ/ANR を監視して改善
- [ ] レビュー対応（返信・改善）
- [ ] targetSdk 要件の年次更新に追従

---

## このプロジェクト向けの追加TODO（実装・確認）

### A. Android設定の棚卸し

- [ ] `kabaddi_app/android/app/build.gradle.kts` の applicationId / versionCode / versionName を確認
- [ ] `kabaddi_app/android/app/src/main/AndroidManifest.xml` の permissions / exported / app名 などを確認
- [ ] `kabaddi_app/pubspec.yaml` の依存SDKを棚卸し（広告・解析・クラッシュ収集の有無）

### B. リリースビルドの作成手順を確立

- [ ] keystore を作成（ローカルのみ）し、`key.properties` で参照する形にする
- [x] `flutter build appbundle --release` でAABが作れることを確認（いったん署名は保留）
- [x] `versionCode` 増分の手順をドキュメント化（`pubspec.yaml` の `version: x.y.z+N` を更新）

### C. ストア掲載文面

- [ ] 概要（短い説明）
- [ ] 詳細説明
- [ ] プライバシーポリシーURL

