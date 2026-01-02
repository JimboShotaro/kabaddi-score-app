# Google Play公開用手続き（手元作業が必要な項目）

このファイルは、**手元（あなたの操作）で実施が必要**な項目をまとめたチェックリストです。

- 参照（全体TODO）: `googlePlay公開用手続き.md`

---

## 1. Android リリース署名（アップロードキー）

### 1-1. keystore（アップロードキー）の作成

目的: Play App Signing で使う「アップロードキー」を作り、以後のAABアップロードに使う。

 - 作成場所（推奨）: `android/app/upload-keystore.jks`
    - 既に `.gitignore` で `*.jks` はコミットされません

PowerShell（例）

 - 作業ディレクトリ: `android/app/`
- コマンド例:
    - `keytool -genkeypair -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000`

注意

- パスワードは忘れると復旧が難しいため、**安全な場所に保管**してください
- `keyAlias` はこの例では `upload` です（以降の `key.properties` と一致させる）

### 1-2. `android/key.properties` の作成（コミットしない）

目的: Gradle がリリース署名に必要な情報を読み込めるようにする。

- `android/key.properties.example` をコピーして作成:
    - `android/key.properties`
- `key.properties` の例（値はあなたの環境のものに置換）

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

`storeFile` について

- `storeFile=upload-keystore.jks` の解釈は Gradle 実行時の作業ディレクトリ等で揺れる可能性があるため、迷う場合は「確実な相対/絶対」に寄せてください。
- うまく解決しない場合の例:
    - `storeFile=app/upload-keystore.jks`（`kabaddi_app/android/` から見た相対）
    - `storeFile=C:/Users/.../kabaddi_app/android/app/upload-keystore.jks`（絶対）

### 1-3. 署名付きAABの作成（確認）

- リポジトリ直下で実行:
    - `flutter build appbundle --release`

### 1-4. Play Console 側で Play App Signing を有効化

- Play Console の該当アプリで Play App Signing を設定
- 初回アップロード時に、アップロードキー（証明書）登録が必要になることがあります
    - 以後は「アップロードキー」で署名したAABをアップロード
    - 端末配布用の署名（App signing key）はPlay側が保持

---

## 2. Play Console 入力（人手が必要な申告）

### 2-1. ストア掲載情報（テキスト・素材）

- アプリ名（表示）: 「カバディーアプリ」
- スクリーンショット（Phone）
- 機能グラフィック（1024×500）
- アイコン（512×512 PNG）
- 説明文（短い説明/詳細説明）

### 2-2. プライバシーポリシーURLの用意（外部ホスティング）

- URLで公開（ログイン不要、常時公開、地理制限なしが望ましい）
- どこに置くか（例）
    - GitHub Pages
    - 自前サイト
    - Notion公開ページ など

### 2-3. Data safety / 権限 / 対象年齢 / 広告の有無

- これは「申告」作業のため、人手で確認しつつ入力が必要
- 実装（アプリの実態）と申告が一致していることが重要

---

## 3. テスト運用（12人×14日など）

- Internal test / Closed test のトラック作成と招待
- テスター向け案内（試して欲しい内容、連絡先、オプトアウトしないお願い）
- フィードバック収集と対応記録

---

## 4. iOSのビルド・配布（Windowsでは不可）

- iOSは macOS 環境（Xcode）が必要
- iOS配布（TestFlight/App Store）を進める場合は、macOS側でビルド・署名設定が必要
