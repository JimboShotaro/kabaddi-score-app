import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../data/models/match_summary.dart';
import '../../../data/repositories/match_repository.dart';

/// 試合履歴Provider
final matchHistoryProvider = FutureProvider.autoDispose<List<MatchSummary>>((ref) async {
  final repository = MatchRepository();
  return repository.getMatchHistory();
});

/// 試合履歴一覧画面
class MatchHistoryScreen extends ConsumerWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(matchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('試合履歴'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(matchHistoryProvider),
            tooltip: '更新',
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('エラーが発生しました: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(matchHistoryProvider),
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
        data: (history) {
          if (history.isEmpty) {
            return _buildEmptyState();
          }
          return _buildHistoryList(context, ref, history);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_kabaddi,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '試合履歴がありません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '新規試合を開始して記録を残しましょう',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    WidgetRef ref,
    List<MatchSummary> history,
  ) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final match = history[index];
        final isTeamAWinner = match.finalScoreA > match.finalScoreB;
        final isTeamBWinner = match.finalScoreB > match.finalScoreA;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: () => _showMatchDetails(context, match),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 試合日時とステータス
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(match.playedAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: match.isCompleted
                              ? Colors.green.withAlpha(51)
                              : Colors.orange.withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          match.isCompleted ? '終了' : '中断',
                          style: TextStyle(
                            color: match.isCompleted
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // スコア表示
                  Row(
                    children: [
                      // チームA
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              match.teamAName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isTeamAWinner
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isTeamAWinner
                                    ? AppTheme.teamAColor
                                    : null,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${match.finalScoreA}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isTeamAWinner
                                    ? AppTheme.teamAColor
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // VS
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '-',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      
                      // チームB
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              match.teamBName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isTeamBWinner
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isTeamBWinner
                                    ? AppTheme.teamBColor
                                    : null,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${match.finalScoreB}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isTeamBWinner
                                    ? AppTheme.teamBColor
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // レイド数
                  if (match.totalRaids > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '総レイド数: ${match.totalRaids}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMatchDetails(BuildContext context, MatchSummary match) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '試合詳細',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow('試合ID', match.matchId.substring(0, 8)),
            _buildDetailRow('日時', DateFormat('yyyy/MM/dd HH:mm').format(match.playedAt)),
            _buildDetailRow('ステータス', match.isCompleted ? '終了' : '中断'),
            _buildDetailRow('スコア', '${match.teamAName} ${match.finalScoreA} - ${match.finalScoreB} ${match.teamBName}'),
            if (match.winner != null)
              _buildDetailRow('勝者', match.winner!),
            _buildDetailRow('総レイド数', '${match.totalRaids}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
