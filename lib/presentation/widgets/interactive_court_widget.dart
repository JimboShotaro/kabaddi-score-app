import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../data/models/models.dart';

/// 選手選択可能なインタラクティブコートウィジェット
class InteractiveCourtWidget extends StatelessWidget {
  final Team teamA;
  final Team teamB;
  final bool isTeamARaiding;
  final Set<String> selectedPlayerIds;
  final ValueChanged<String>? onPlayerTap;
  final String? raiderId;

  const InteractiveCourtWidget({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.isTeamARaiding,
    this.selectedPlayerIds = const {},
    this.onPlayerTap,
    this.raiderId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        return CustomPaint(
          size: Size(width, height),
          painter: _CourtBackgroundPainter(isTeamARaiding: isTeamARaiding),
          child: Stack(
            children: [
              // チームAの選手
              ..._buildPlayerWidgets(
                teamA,
                isTeamARaiding,
                width * 0.05,
                width * 0.45,
                height,
                AppTheme.teamAColor,
              ),
              // チームBの選手
              ..._buildPlayerWidgets(
                teamB,
                !isTeamARaiding,
                width * 0.55,
                width * 0.95,
                height,
                AppTheme.teamBColor,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPlayerWidgets(
    Team team,
    bool isRaiding,
    double startX,
    double endX,
    double height,
    Color teamColor,
  ) {
    final activePlayers = team.activePlayers;
    final widgets = <Widget>[];
    
    for (var i = 0; i < activePlayers.length; i++) {
      final player = activePlayers[i];
      final isSelected = selectedPlayerIds.contains(player.id);
      final isRaider = player.id == raiderId;
      
      // 選手の位置を計算（グリッド配置）
      final cols = 3;
      final col = i % cols;
      final row = i ~/ cols;
      
      final xRange = endX - startX;
      final yRange = height * 0.6;
      final yOffset = height * 0.2;
      
      final x = startX + (xRange / (cols + 1)) * (col + 1);
      final y = yOffset + (yRange / 3) * (row + 0.5);
      
      widgets.add(
        Positioned(
          left: x - 24,
          top: y - 24,
          child: GestureDetector(
            onTap: () => onPlayerTap?.call(player.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isRaider
                    ? Colors.orange
                    : isSelected
                        ? Colors.red
                        : teamColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected || isRaider ? Colors.white : teamColor.withAlpha(128),
                  width: isSelected || isRaider ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected || isRaider
                        ? Colors.white.withAlpha(128)
                        : Colors.black26,
                    blurRadius: isSelected || isRaider ? 8 : 4,
                    spreadRadius: isSelected || isRaider ? 2 : 0,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${player.jerseyNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isRaider)
                      const Icon(
                        Icons.directions_run,
                        color: Colors.white,
                        size: 12,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }
}

/// コート背景を描画するPainter
class _CourtBackgroundPainter extends CustomPainter {
  final bool isTeamARaiding;

  _CourtBackgroundPainter({this.isTeamARaiding = true});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // コート全体の背景
    final courtPaint = Paint()
      ..color = AppTheme.courtColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), courtPaint);

    // ライン用ペイント
    final linePaint = Paint()
      ..color = AppTheme.lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 太いライン用
    final thickLinePaint = Paint()
      ..color = AppTheme.lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // ミッドライン（中央線）
    final midX = width / 2;
    canvas.drawLine(
      Offset(midX, 0),
      Offset(midX, height),
      thickLinePaint,
    );

    // ボークライン
    final baulkOffset = width * 0.125;
    canvas.drawLine(
      Offset(midX - baulkOffset, 0),
      Offset(midX - baulkOffset, height),
      linePaint,
    );
    canvas.drawLine(
      Offset(midX + baulkOffset, 0),
      Offset(midX + baulkOffset, height),
      linePaint,
    );

    // ボーナスライン
    final bonusOffset = width * 0.25;
    final dashedPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    _drawDashedLine(
      canvas,
      Offset(midX - bonusOffset, 0),
      Offset(midX - bonusOffset, height),
      dashedPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(midX + bonusOffset, 0),
      Offset(midX + bonusOffset, height),
      dashedPaint,
    );

    // エンドライン
    canvas.drawRect(
      Rect.fromLTWH(1, 1, width - 2, height - 2),
      thickLinePaint,
    );

    // ロビーエリア
    final lobbyWidth = width * 0.08;
    final lobbyPaint = Paint()
      ..color = Colors.brown.withAlpha(80)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, lobbyWidth, height),
      lobbyPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(width - lobbyWidth, 0, lobbyWidth, height),
      lobbyPaint,
    );

    // 攻守表示
    _drawRoleLabel(canvas, 'A', midX / 2, 20, AppTheme.teamAColor, isTeamARaiding);
    _drawRoleLabel(canvas, 'B', midX + midX / 2, 20, AppTheme.teamBColor, !isTeamARaiding);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 10.0;
    const gapLength = 5.0;
    
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    final unitDx = dx / distance;
    final unitDy = dy / distance;
    
    var currentDistance = 0.0;
    while (currentDistance < distance) {
      final startOffset = Offset(
        start.dx + unitDx * currentDistance,
        start.dy + unitDy * currentDistance,
      );
      final endOffset = Offset(
        start.dx + unitDx * (currentDistance + dashLength).clamp(0, distance),
        start.dy + unitDy * (currentDistance + dashLength).clamp(0, distance),
      );
      canvas.drawLine(startOffset, endOffset, paint);
      currentDistance += dashLength + gapLength;
    }
  }

  void _drawRoleLabel(Canvas canvas, String label, double x, double y, Color color, bool isRaiding) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: isRaiding ? '$label 攻撃' : '$label 守備',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          backgroundColor: color.withAlpha(180),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
