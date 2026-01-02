import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../../data/models/models.dart';
import '../../providers/match_provider.dart';
import '../../widgets/scoreboard_widget.dart';
import '../../widgets/team_panel_widget.dart';
import '../../widgets/raid_action_widget.dart';

/// 試合実行画面
class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  // 選択された守備選手（タッチされた選手）
  final Set<String> _selectedDefenders = {};

  // 現在のレイダー
  String? _currentRaiderId;

  // ボーナス獲得フラグ
  bool _isBonus = false;

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);

    if (matchState == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('試合')),
        body: const Center(child: Text('試合が開始されていません')),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _showAbandonMatchDialog(matchState);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '第${matchState.currentHalf}ハーフ - レイド #${matchState.raidNumber + 1}',
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetSelection,
              tooltip: '選択をリセット',
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, matchState),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'switch_half',
                  child: Text('ハーフを変更'),
                ),
                const PopupMenuItem(
                  value: 'abandon_match',
                  child: Text('中断して終了'),
                ),
                const PopupMenuItem(value: 'end_match', child: Text('試合終了')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
          // スコアボード
          ScoreboardWidget(matchState: matchState),

          const Divider(height: 1),

          // チームパネル
          Expanded(
            child: Row(
              children: [
                // チームA
                Expanded(
                  child: TeamPanelWidget(
                    team: matchState.teamA,
                    isRaiding: matchState.raidingTeamId == matchState.teamA.id,
                    teamColor: AppTheme.teamAColor,
                    selectedPlayerIds:
                        matchState.raidingTeamId == matchState.teamA.id
                        ? {if (_currentRaiderId != null) _currentRaiderId!}
                        : _selectedDefenders,
                    onPlayerTap: (playerId) => _handlePlayerTap(
                      playerId,
                      matchState.raidingTeamId == matchState.teamA.id,
                      matchState,
                    ),
                    onPlayerLongPress: (playerId) => _showSubstitutionSheet(
                      team: matchState.teamA,
                      activePlayerId: playerId,
                    ),
                  ),
                ),

                // 中央区切り
                Container(width: 2, color: Colors.grey[300]),

                // チームB
                Expanded(
                  child: TeamPanelWidget(
                    team: matchState.teamB,
                    isRaiding: matchState.raidingTeamId == matchState.teamB.id,
                    teamColor: AppTheme.teamBColor,
                    selectedPlayerIds:
                        matchState.raidingTeamId == matchState.teamB.id
                        ? {if (_currentRaiderId != null) _currentRaiderId!}
                        : _selectedDefenders,
                    onPlayerTap: (playerId) => _handlePlayerTap(
                      playerId,
                      matchState.raidingTeamId == matchState.teamB.id,
                      matchState,
                    ),
                    onPlayerLongPress: (playerId) => _showSubstitutionSheet(
                      team: matchState.teamB,
                      activePlayerId: playerId,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // レイドアクションパネル
            RaidActionWidget(
              raiderId: _currentRaiderId,
              touchedCount: _selectedDefenders.length,
              isBonus: _isBonus,
              onBonusChanged: (value) => setState(() => _isBonus = value),
              onRaidSuccess:
                  _currentRaiderId != null ? _recordRaidSuccess : null,
              onTackle: _currentRaiderId != null ? _recordTackle : null,
              onEmptyRaid: _currentRaiderId != null ? _recordEmptyRaid : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handlePlayerTap(String playerId, bool isRaidingTeam, MatchState state) {
    setState(() {
      if (isRaidingTeam) {
        // 攻撃チームの選手：レイダーとして選択
        final player = state.raidingTeam!.players.firstWhere(
          (p) => p.id == playerId,
        );
        if (player.status == PlayerStatus.active) {
          // レイダー変更時は、タッチ選択/ボーナスをリセットして混乱を防ぐ
          if (_currentRaiderId == playerId) {
            _currentRaiderId = null;
          } else {
            _currentRaiderId = playerId;
          }
          _selectedDefenders.clear();
          _isBonus = false;
        }
      } else {
        // レイダー未選択時は、先にレイダー選択を促す
        if (_currentRaiderId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showResultSnackBar('先に攻撃チームからレイダーを選択してください');
          });
          return;
        }

        // 守備チームの選手：タッチ対象として選択/解除
        final player = state.defendingTeam!.players.firstWhere(
          (p) => p.id == playerId,
        );
        if (player.status == PlayerStatus.active) {
          if (_selectedDefenders.contains(playerId)) {
            _selectedDefenders.remove(playerId);
          } else {
            _selectedDefenders.add(playerId);
          }
        }
      }
    });
  }

  void _recordRaidSuccess() {
    if (_currentRaiderId == null) return;

    ref
        .read(matchProvider.notifier)
        .recordSuccessfulRaid(
          raiderId: _currentRaiderId!,
          touchedDefenderIds: _selectedDefenders.toList(),
          isBonus: _isBonus,
        );

    _resetSelection();
    _showResultSnackBar('レイド成功！');
  }

  void _recordTackle() {
    if (_currentRaiderId == null) return;

    ref.read(matchProvider.notifier).recordTackle(raiderId: _currentRaiderId!);

    _resetSelection();
    _showResultSnackBar('タックル成功！');
  }

  void _recordEmptyRaid() {
    if (_currentRaiderId == null) return;

    ref
        .read(matchProvider.notifier)
        .recordEmptyRaid(raiderId: _currentRaiderId!);

    _resetSelection();
    _showResultSnackBar('空レイド');
  }

  void _resetSelection() {
    setState(() {
      _selectedDefenders.clear();
      _currentRaiderId = null;
      _isBonus = false;
    });
  }

  void _handleMenuAction(String action, MatchState state) {
    switch (action) {
      case 'switch_half':
        ref.read(matchProvider.notifier).switchHalf();
        _resetSelection();
        _showResultSnackBar('ハーフを変更しました');
        break;
      case 'abandon_match':
        _showAbandonMatchDialog(state);
        break;
      case 'end_match':
        _showEndMatchDialog(state);
        break;
    }
  }

  Future<void> _showAbandonMatchDialog(MatchState state) async {
    final shouldAbandon = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('試合を中断しますか？'),
        content: const Text('現在のスコアとログを保存して「中断」として履歴に残します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('続ける'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('中断してホームへ'),
          ),
        ],
      ),
    );

    if (shouldAbandon != true) return;

    await ref.read(matchProvider.notifier).abandonMatch();
    ref.read(matchProvider.notifier).resetMatch();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showEndMatchDialog(MatchState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('試合終了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${state.teamA.name}: ${state.scoreA}点'),
            Text('${state.teamB.name}: ${state.scoreB}点'),
            const SizedBox(height: 16),
            Text(
              state.scoreA > state.scoreB
                  ? '${state.teamA.name} の勝利！'
                  : state.scoreB > state.scoreA
                  ? '${state.teamB.name} の勝利！'
                  : '引き分け',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('続ける'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 試合を終了して履歴を保存
              await ref.read(matchProvider.notifier).endMatch();
              ref.read(matchProvider.notifier).resetMatch();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('ホームに戻る'),
          ),
        ],
      ),
    );
  }

  void _showResultSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  void _showSubstitutionSheet({
    required Team team,
    required String activePlayerId,
  }) {
    final bench = team.benchPlayers;
    if (bench.isEmpty) {
      _showResultSnackBar('控え選手がいません');
      return;
    }

    final active = team.players.firstWhere((p) => p.id == activePlayerId);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('交代'),
                subtitle: Text('OUT: ${active.name}'),
              ),
              for (final benchPlayer in bench)
                ListTile(
                  leading: const Icon(Icons.event_seat),
                  title: Text(benchPlayer.name),
                  subtitle: Text('背番号 ${benchPlayer.jerseyNumber}'),
                  onTap: () async {
                    await ref.read(matchProvider.notifier).substitute(
                          teamId: team.id,
                          activePlayerId: activePlayerId,
                          benchPlayerId: benchPlayer.id,
                        );
                    if (context.mounted) Navigator.pop(context);
                    _resetSelection();
                    _showResultSnackBar('交代しました');
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
