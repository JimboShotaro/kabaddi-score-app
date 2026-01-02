/// 手動同期用の接続先
///
/// Android Emulator からホストPCへ到達する場合は `10.0.2.2` を使います。
/// - 例: http://10.0.2.2:8000
///
/// 実機から到達する場合は、ホストPCのローカルIPに変更してください。
class SyncConfig {
  static const String baseUrl = 'http://10.0.2.2:8000';
}
