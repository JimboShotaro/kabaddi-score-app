import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/match_detail.dart';
import '../models/match_summary.dart';
import '../models/raid_result.dart';
import 'match_repository.dart';

class SyncResult {
  final int attempted;
  final int succeeded;
  final int failed;
  final List<String> errors;

  const SyncResult({
    required this.attempted,
    required this.succeeded,
    required this.failed,
    required this.errors,
  });
}

/// FastAPI への手動同期（最小実装）
class SyncRepository {
  final MatchRepository _matchRepository;

  const SyncRepository(this._matchRepository);

  Future<SyncResult> syncEndedMatches({required String baseUrl}) async {
    final history = await _matchRepository.getMatchHistory();

    // 中断/完了を含め「終了時刻があるもの」を同期対象とする
    final targets = history.where((m) => m.endedAt != null).toList();

    var succeeded = 0;
    final errors = <String>[];

    for (final summary in targets) {
      try {
        final detail = await _matchRepository.getMatchDetail(summary.matchId);
        if (detail == null) {
          errors.add('${summary.matchId}: detail not found');
          continue;
        }

        final payload = _buildPayload(summary: summary, detail: detail);
        final uri = Uri.parse('$baseUrl/api/v1/sync');

        final res = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 10));

        if (res.statusCode >= 200 && res.statusCode < 300) {
          succeeded += 1;
        } else {
          errors.add('${summary.matchId}: HTTP ${res.statusCode} ${res.body}');
        }
      } catch (e) {
        errors.add('${summary.matchId}: $e');
      }
    }

    return SyncResult(
      attempted: targets.length,
      succeeded: succeeded,
      failed: targets.length - succeeded,
      errors: errors,
    );
  }

  Map<String, dynamic> _buildPayload({
    required MatchSummary summary,
    required MatchDetail detail,
  }) {
    final date = (summary.endedAt ?? summary.playedAt).toIso8601String();

    final logs = detail.raidLogs.asMap().entries.map((entry) {
      final index = entry.key;
      final raid = entry.value;

      final outcome = switch (raid.outcome) {
        RaidOutcome.success => 'success',
        RaidOutcome.tackled => 'tackled',
        RaidOutcome.empty => 'empty',
        RaidOutcome.bonus => 'success',
      };

      final pointsGained = outcome == 'tackled' ? 0 : raid.totalAttackPoints;

      return {
        'raid_number': index + 1,
        'raider_id': raid.raiderId,
        'outcome': outcome,
        'points_gained': pointsGained,
      };
    }).toList();

    return {
      'match_id': summary.matchId,
      'date': date,
      'team_a_name': summary.teamAName,
      'team_b_name': summary.teamBName,
      'final_score_a': summary.finalScoreA,
      'final_score_b': summary.finalScoreB,
      'logs': logs,
    };
  }
}
