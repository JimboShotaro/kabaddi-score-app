import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/rules/kabaddi_rules.dart';

/// タイマーの状態
class TimerState {
  final int remainingSeconds;
  final bool isRunning;
  final bool isRaidTimer; // true: レイドタイマー, false: ハーフタイマー

  const TimerState({
    required this.remainingSeconds,
    this.isRunning = false,
    this.isRaidTimer = false,
  });

  /// 分:秒形式で表示
  String get displayTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 残り時間が少ないかどうか
  bool get isLowTime => remainingSeconds <= 30;

  TimerState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    bool? isRaidTimer,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isRaidTimer: isRaidTimer ?? this.isRaidTimer,
    );
  }
}

/// 試合タイマー管理
class MatchTimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;

  MatchTimerNotifier()
      : super(const TimerState(
          remainingSeconds: KabaddiRules.halfDurationSeconds,
          isRunning: false,
          isRaidTimer: false,
        ));

  /// ハーフタイマーをリセット
  void resetHalfTimer() {
    _cancelTimer();
    state = const TimerState(
      remainingSeconds: KabaddiRules.halfDurationSeconds,
      isRunning: false,
      isRaidTimer: false,
    );
  }

  /// レイドタイマーを開始
  void startRaidTimer() {
    _cancelTimer();
    state = const TimerState(
      remainingSeconds: KabaddiRules.raidTimeLimit,
      isRunning: true,
      isRaidTimer: true,
    );
    _startCountdown();
  }

  /// タイマーを開始/再開
  void start() {
    if (state.remainingSeconds > 0 && !state.isRunning) {
      state = state.copyWith(isRunning: true);
      _startCountdown();
    }
  }

  /// タイマーを一時停止
  void pause() {
    _cancelTimer();
    state = state.copyWith(isRunning: false);
  }

  /// タイマーをリセット（ハーフ用）
  void reset() {
    _cancelTimer();
    state = TimerState(
      remainingSeconds: state.isRaidTimer
          ? KabaddiRules.raidTimeLimit
          : KabaddiRules.halfDurationSeconds,
      isRunning: false,
      isRaidTimer: state.isRaidTimer,
    );
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _cancelTimer();
        state = state.copyWith(isRunning: false);
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}

/// タイマーのProvider
final matchTimerProvider =
    StateNotifierProvider<MatchTimerNotifier, TimerState>((ref) {
  return MatchTimerNotifier();
});
