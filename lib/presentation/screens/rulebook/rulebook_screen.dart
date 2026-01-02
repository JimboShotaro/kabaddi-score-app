import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../domain/rules/kabaddi_rules.dart';
import '../../widgets/court_widget.dart';

/// インタラクティブルールブック画面
class RulebookScreen extends StatefulWidget {
  const RulebookScreen({super.key});

  @override
  State<RulebookScreen> createState() => _RulebookScreenState();
}

class _RulebookScreenState extends State<RulebookScreen> {
  CourtArea? _selectedArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルールブック'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // コート図
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    const CourtWidget(isTeamARaiding: true),
                    // タップ可能なエリアオーバーレイ
                    ..._buildTappableAreas(),
                  ],
                ),
              ),
            ),
          ),

          // 説明パネル
          Expanded(flex: 1, child: _buildExplanationPanel()),

          // ルール一覧
          Expanded(flex: 2, child: _buildRulesList()),
        ],
      ),
    );
  }

  List<Widget> _buildTappableAreas() {
    return [
      // ボークライン
      _buildTappableArea(
        area: CourtArea.baulkLine,
        left: 0.3,
        width: 0.1,
        color: Colors.orange,
      ),
      _buildTappableArea(
        area: CourtArea.baulkLine,
        left: 0.6,
        width: 0.1,
        color: Colors.orange,
      ),
      // ボーナスライン
      _buildTappableArea(
        area: CourtArea.bonusLine,
        left: 0.2,
        width: 0.1,
        color: Colors.yellow,
      ),
      _buildTappableArea(
        area: CourtArea.bonusLine,
        left: 0.7,
        width: 0.1,
        color: Colors.yellow,
      ),
      // ミッドライン
      _buildTappableArea(
        area: CourtArea.midLine,
        left: 0.45,
        width: 0.1,
        color: Colors.white,
      ),
      // ロビー
      _buildTappableArea(
        area: CourtArea.lobby,
        left: 0,
        width: 0.1,
        color: Colors.brown,
      ),
      _buildTappableArea(
        area: CourtArea.lobby,
        left: 0.9,
        width: 0.1,
        color: Colors.brown,
      ),
    ];
  }

  Widget _buildTappableArea({
    required CourtArea area,
    required double left,
    required double width,
    required Color color,
  }) {
    final isSelected = _selectedArea == area;
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Positioned(
            left: constraints.maxWidth * left,
            width: constraints.maxWidth * width,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => setState(() => _selectedArea = area),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: isSelected ? color.withAlpha(150) : Colors.transparent,
                child: isSelected
                    ? Center(
                        child: Icon(Icons.info, color: Colors.white, size: 24),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExplanationPanel() {
    if (_selectedArea == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'コート上のエリアをタップして\nルールの説明を見てみましょう',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                _selectedArea!.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedArea = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _selectedArea!.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesList() {
    final rules = [
      {
        'title': '基本ルール',
        'icon': Icons.book,
        'content':
            '1チーム7人がコート上でプレー。攻撃側は1人のレイダーを送り込み、'
            '守備側の選手にタッチして戻ることで得点を獲得します。',
      },
      {
        'title': 'タッチポイント',
        'icon': Icons.touch_app,
        'content':
            'レイダーがタッチした守備選手1人につき1ポイント獲得。'
            'タッチされた選手はアウトになります。',
      },
      {
        'title': 'ボーナスポイント',
        'icon': Icons.star,
        'content':
            '守備側が6人以上いる場合、レイダーがボーナスラインを越えると'
            '+1ポイント獲得できます。',
      },
      {
        'title': 'タックル',
        'icon': Icons.sports_mma,
        'content':
            '守備側がレイダーを捕まえて自陣に戻らせなかった場合、'
            '守備側に1ポイント。レイダーはアウトになります。',
      },
      {
        'title': 'スーパータックル',
        'icon': Icons.flash_on,
        'content':
            '守備側が3人以下の状態でタックル成功すると、'
            '通常の1点に加えてボーナス1点、計2点獲得！',
      },
      {
        'title': '復活',
        'icon': Icons.refresh,
        'content':
            '得点を獲得すると、アウトになった味方選手が復活します。'
            '先にアウトになった選手から順番に復活します。',
      },
      {
        'title': 'ローナ',
        'icon': Icons.celebration,
        'content':
            '相手チーム全員をアウトにすると「ローナ」となり、'
            '+2ポイントのボーナスを獲得。相手チーム全員が復活します。',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
        return Card(
          child: ExpansionTile(
            leading: Icon(
              rule['icon'] as IconData,
              color: AppTheme.primaryColor,
            ),
            title: Text(
              rule['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(rule['content'] as String),
              ),
            ],
          ),
        );
      },
    );
  }
}
