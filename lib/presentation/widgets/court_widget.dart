import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// カバディコートを描画するウィジェット
class CourtWidget extends StatelessWidget {
  final VoidCallback? onTeamATap;
  final VoidCallback? onTeamBTap;
  final bool isTeamARaiding;

  const CourtWidget({
    super.key,
    this.onTeamATap,
    this.onTeamBTap,
    this.isTeamARaiding = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: CourtPainter(isTeamARaiding: isTeamARaiding),
          child: Stack(
            children: [
              // チームA側タップエリア
              Positioned(
                left: 0,
                top: 0,
                width: constraints.maxWidth / 2,
                height: constraints.maxHeight,
                child: GestureDetector(
                  onTap: onTeamATap,
                  behavior: HitTestBehavior.translucent,
                ),
              ),
              // チームB側タップエリア
              Positioned(
                left: constraints.maxWidth / 2,
                top: 0,
                width: constraints.maxWidth / 2,
                height: constraints.maxHeight,
                child: GestureDetector(
                  onTap: onTeamBTap,
                  behavior: HitTestBehavior.translucent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// コート描画用のCustomPainter
class CourtPainter extends CustomPainter {
  final bool isTeamARaiding;

  CourtPainter({this.isTeamARaiding = true});

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
    canvas.drawLine(Offset(midX, 0), Offset(midX, height), thickLinePaint);

    // ボークライン（両側、ミッドラインから約1/4の位置）
    final baulkOffset = width * 0.125;
    // チームA側ボークライン
    canvas.drawLine(
      Offset(midX - baulkOffset, 0),
      Offset(midX - baulkOffset, height),
      linePaint,
    );
    // チームB側ボークライン
    canvas.drawLine(
      Offset(midX + baulkOffset, 0),
      Offset(midX + baulkOffset, height),
      linePaint,
    );

    // ボーナスライン（両側、ボークラインからさらに外側）
    final bonusOffset = width * 0.25;
    final dashedPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // チームA側ボーナスライン
    _drawDashedLine(
      canvas,
      Offset(midX - bonusOffset, 0),
      Offset(midX - bonusOffset, height),
      dashedPaint,
    );
    // チームB側ボーナスライン
    _drawDashedLine(
      canvas,
      Offset(midX + bonusOffset, 0),
      Offset(midX + bonusOffset, height),
      dashedPaint,
    );

    // エンドライン（外枠）
    canvas.drawRect(Rect.fromLTWH(1, 1, width - 2, height - 2), thickLinePaint);

    // ロビーエリア（両端）
    final lobbyWidth = width * 0.08;
    final lobbyPaint = Paint()
      ..color = Colors.brown.withAlpha(80)
      ..style = PaintingStyle.fill;

    // 左ロビー
    canvas.drawRect(Rect.fromLTWH(0, 0, lobbyWidth, height), lobbyPaint);
    // 右ロビー
    canvas.drawRect(
      Rect.fromLTWH(width - lobbyWidth, 0, lobbyWidth, height),
      lobbyPaint,
    );

    // チーム表示
    _drawTeamLabel(
      canvas,
      'A',
      midX / 2,
      height / 2,
      AppTheme.teamAColor,
      isTeamARaiding,
    );
    _drawTeamLabel(
      canvas,
      'B',
      midX + midX / 2,
      height / 2,
      AppTheme.teamBColor,
      !isTeamARaiding,
    );
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

  void _drawTeamLabel(
    Canvas canvas,
    String label,
    double x,
    double y,
    Color color,
    bool isRaiding,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: isRaiding ? '$label\n攻撃' : '$label\n守備',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: color, blurRadius: 10)],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CourtPainter oldDelegate) {
    return oldDelegate.isTeamARaiding != isTeamARaiding;
  }
}
