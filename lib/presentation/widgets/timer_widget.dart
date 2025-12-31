import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';

/// タイマー表示ウィジェット
class TimerWidget extends ConsumerWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(matchTimerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: timerState.isLowTime ? Colors.red.withAlpha(50) : Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // タイマー種別アイコン
          Icon(
            timerState.isRaidTimer ? Icons.directions_run : Icons.timer,
            color: timerState.isLowTime ? Colors.red : Colors.black87,
          ),
          const SizedBox(width: 8),
          
          // 時間表示
          Text(
            timerState.displayTime,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: timerState.isLowTime ? Colors.red : Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          
          // 再生/一時停止ボタン
          IconButton(
            icon: Icon(
              timerState.isRunning ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              if (timerState.isRunning) {
                ref.read(matchTimerProvider.notifier).pause();
              } else {
                ref.read(matchTimerProvider.notifier).start();
              }
            },
          ),
          
          // リセットボタン
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(matchTimerProvider.notifier).reset();
            },
          ),
        ],
      ),
    );
  }
}

/// コンパクトなタイマー表示（スコアボード用）
class CompactTimerWidget extends ConsumerWidget {
  const CompactTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(matchTimerProvider);

    return GestureDetector(
      onTap: () {
        if (timerState.isRunning) {
          ref.read(matchTimerProvider.notifier).pause();
        } else {
          ref.read(matchTimerProvider.notifier).start();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: timerState.isLowTime 
              ? Colors.red.withAlpha(200)
              : Colors.black54,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              timerState.isRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              timerState.displayTime,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
