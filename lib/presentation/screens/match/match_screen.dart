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

    return Scaffold(
      appBar: AppBar(
        title: Text('第${matchState.currentHalf}ハーフ - レイド #${matchState.raidNumber + 1}'),
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
              const PopupMenuItem(value: 'switch_half', child: Text('ハーフを変更')),
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
                    selectedPlayerIds: matchState.raidingTeamId == matchState.teamA.id
                        ? {if (_currentRaiderId != null) _currentRaiderId!}
                        : _selectedDefenders,
                    onPlayerTap: (playerId) => _handlePlayerTap(
                      playerId,
                      matchState.raidingTeamId == matchState.teamA.id,
                      matchState,
                    ),
                  ),
                ),
                
                // 中央区切り
                Container(
                  width: 2,
                  color: Colors.grey[300],
                ),
                
                // チームB
                Expanded(
                  child: TeamPanelWidget(
                    team: matchState.teamB,
                    isRaiding: matchState.raidingTeamId == matchState.teamB.id,
                    teamColor: AppTheme.teamBColor,
                    selectedPlayerIds: matchState.raidingTeamId == matchState.teamB.id
                        ? {if (_currentRaiderId != null) _currentRaiderId!}
                        : _selectedDefenders,
                    onPlayerTap: (playerId) => _handlePlayerTap(
                      playerId,
                      matchState.raidingTeamId == matchState.teamB.id,
                      matchState,
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
            onRaidSuccess: _currentRaiderId != null ? _recordRaidSuccess : null,
            onTackle: _currentRaiderId != null ? _recordTackle : null,
            onEmptyRaid: _currentRaiderId != null ? _recordEmptyRaid : null,
          ),
        ],
      ),
    );
  }

  void _handlePlayerTap(String playerId, bool isRaidingTeam, MatchState state) {
    setState(() {
      if (isRaidingTeam) {
        // 攻撃チームの選手：レイダーとして選択
        final player = state.raidingTeam!.players.firstWhere((p) => p.id == playerId);
        if (player.status == PlayerStatus.active) {
          _currentRaiderId = playerId;
        }
      } else {
        // 守備チームの選手：タッチ対象として選択/解除
        final player = state.defendingTeam!.players.firstWhere((p) => p.id == playerId);
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
    
    ref.read(matchProvider.notifier).recordSuccessfulRaid(
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
    
    ref.read(matchProvider.notifier).recordEmptyRaid(raiderId: _currentRaiderId!);
    
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
      case 'end_match':
        _showEndMatchDialog(state);
        break;
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
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
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
