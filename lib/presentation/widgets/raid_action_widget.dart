import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// レイドアクションウィジェット
class RaidActionWidget extends StatelessWidget {
  final String? raiderId;
  final int touchedCount;
  final bool isBonus;
  final ValueChanged<bool> onBonusChanged;
  final VoidCallback? onRaidSuccess;
  final VoidCallback? onTackle;
  final VoidCallback? onEmptyRaid;

  const RaidActionWidget({
    super.key,
    required this.raiderId,
    required this.touchedCount,
    required this.isBonus,
    required this.onBonusChanged,
    this.onRaidSuccess,
    this.onTackle,
    this.onEmptyRaid,
  });

  @override
  Widget build(BuildContext context) {
    final hasRaider = raiderId != null;
    final totalPoints = touchedCount + (isBonus ? 1 : 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 操作ガイド
            if (!hasRaider)
              const Text(
                '攻撃チームからレイダーを選択してください',
                style: TextStyle(color: Colors.grey),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_kabaddi, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'タッチ: $touchedCount人',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isBonus) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '+ボーナス',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 16),
                  Text(
                    '= $totalPoints点',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 12),
            
            // ボーナスチェックボックス
            if (hasRaider)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isBonus,
                    onChanged: hasRaider
                        ? (value) => onBonusChanged(value ?? false)
                        : null,
                  ),
                  const Text('ボーナスライン通過'),
                ],
              ),
            
            const SizedBox(height: 12),
            
            // アクションボタン
            Row(
              children: [
                // 空レイド
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEmptyRaid,
                    icon: const Icon(Icons.block),
                    label: const Text('空レイド'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // タックル成功
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTackle,
                    icon: const Icon(Icons.sports_mma),
                    label: const Text('タックル'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.teamBColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // レイド成功
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: touchedCount > 0 || isBonus ? onRaidSuccess : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('レイド成功'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
