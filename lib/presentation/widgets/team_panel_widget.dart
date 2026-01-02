import 'package:flutter/material.dart';
import '../../data/models/models.dart';

/// チームパネルウィジェット
class TeamPanelWidget extends StatelessWidget {
  final Team team;
  final bool isRaiding;
  final Color teamColor;
  final Set<String> selectedPlayerIds;
  final void Function(String playerId) onPlayerTap;
  final void Function(String playerId)? onPlayerLongPress;

  const TeamPanelWidget({
    super.key,
    required this.team,
    required this.isRaiding,
    required this.teamColor,
    required this.selectedPlayerIds,
    required this.onPlayerTap,
    this.onPlayerLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isRaiding ? teamColor.withValues(alpha: 13) : null,
      child: Column(
        children: [
          // ヘッダー
          Container(
            padding: const EdgeInsets.all(12),
            color: teamColor.withValues(alpha: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRaiding ? Icons.sports_kabaddi : Icons.shield,
                  color: teamColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  team.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: teamColor,
                  ),
                ),
              ],
            ),
          ),

          // 選手リスト
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                // アクティブ選手
                if (team.activePlayers.isNotEmpty) ...[
                  _buildSectionHeader('コート上', Icons.check_circle, Colors.green),
                  ...team.activePlayers.map(
                    (player) => _buildPlayerTile(player),
                  ),
                ],

                // アウト選手
                if (team.outPlayers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildSectionHeader('アウト', Icons.cancel, Colors.red),
                  ...team.outPlayers.map((player) => _buildPlayerTile(player)),
                ],

                // 控え選手
                if (team.benchPlayers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildSectionHeader(
                    '控え',
                    Icons.event_seat,
                    Colors.blueGrey,
                  ),
                  ...team.benchPlayers.map((player) => _buildPlayerTile(player)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(Player player) {
    final isSelected = selectedPlayerIds.contains(player.id);
    final isActive = player.status == PlayerStatus.active;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? teamColor.withValues(alpha: 51)
          : isActive
          ? null
          : Colors.grey[200],
      child: InkWell(
        onTap: isActive ? () => onPlayerTap(player.id) : null,
        onLongPress:
            isActive && onPlayerLongPress != null
                ? () => onPlayerLongPress!(player.id)
                : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // 背番号
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? teamColor : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${player.jerseyNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 選手名
              Expanded(
                child: Text(
                  player.name,
                  style: TextStyle(
                    color: isActive ? null : Colors.grey,
                    decoration: isActive ? null : TextDecoration.lineThrough,
                  ),
                ),
              ),

              // 選択状態アイコン
              if (isSelected)
                Icon(
                  isRaiding ? Icons.sports_kabaddi : Icons.touch_app,
                  color: teamColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
