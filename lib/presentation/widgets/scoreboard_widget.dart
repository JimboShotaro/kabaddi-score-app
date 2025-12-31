import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../data/models/models.dart';
import 'timer_widget.dart';

/// スコアボードウィジェット
class ScoreboardWidget extends StatelessWidget {
  final MatchState matchState;

  const ScoreboardWidget({
    super.key,
    required this.matchState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.teamAColor.withAlpha(25),
            AppTheme.teamBColor.withAlpha(25),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // チームA
          _buildTeamScore(
            context,
            team: matchState.teamA,
            score: matchState.scoreA,
            color: AppTheme.teamAColor,
            isRaiding: matchState.raidingTeamId == matchState.teamA.id,
          ),
          
          // VS
          Column(
            children: [
              const CompactTimerWidget(),
              const SizedBox(height: 8),
              const Text(
                'VS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '第${matchState.currentHalf}ハーフ',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          
          // チームB
          _buildTeamScore(
            context,
            team: matchState.teamB,
            score: matchState.scoreB,
            color: AppTheme.teamBColor,
            isRaiding: matchState.raidingTeamId == matchState.teamB.id,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(
    BuildContext context, {
    required Team team,
    required int score,
    required Color color,
    required bool isRaiding,
  }) {
    return Column(
      children: [
        // チーム名
        Row(
          children: [
            if (isRaiding)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '攻撃',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              team.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // スコア
        Text(
          '$score',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        
        // アクティブ人数
        Text(
          '${team.activeCount}人 / 7人',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
