import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_theme.dart';
import '../../../data/models/player.dart';
import '../../../data/models/team.dart';
import '../../providers/match_provider.dart';
import '../match/match_screen.dart';

const _uuid = Uuid();

/// 新規試合作成画面
class NewMatchScreen extends ConsumerStatefulWidget {
  const NewMatchScreen({super.key});

  @override
  ConsumerState<NewMatchScreen> createState() => _NewMatchScreenState();
}

class _NewMatchScreenState extends ConsumerState<NewMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamAController = TextEditingController(text: 'チームA');
  final _teamBController = TextEditingController(text: 'チームB');
  
  int _playerCountA = 7;
  int _playerCountB = 7;
  bool _isLoading = false;

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規試合'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // チームA設定
              _buildTeamCard(
                title: 'チームA（先攻）',
                color: AppTheme.teamAColor,
                controller: _teamAController,
                playerCount: _playerCountA,
                onPlayerCountChanged: (count) {
                  setState(() => _playerCountA = count);
                },
              ),
              const SizedBox(height: 16),
              
              // VS表示
              const Center(
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // チームB設定
              _buildTeamCard(
                title: 'チームB（後攻）',
                color: AppTheme.teamBColor,
                controller: _teamBController,
                playerCount: _playerCountB,
                onPlayerCountChanged: (count) {
                  setState(() => _playerCountB = count);
                },
              ),
              const SizedBox(height: 32),
              
              // 試合開始ボタン
              ElevatedButton(
                onPressed: _isLoading ? null : _startMatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '試合開始',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard({
    required String title,
    required Color color,
    required TextEditingController controller,
    required int playerCount,
    required ValueChanged<int> onPlayerCountChanged,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // チーム名入力
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'チーム名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.groups),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'チーム名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // 選手数選択
            Row(
              children: [
                const Text('選手数: '),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: playerCount,
                  items: List.generate(7, (i) => i + 1)
                      .map((count) => DropdownMenuItem(
                            value: count,
                            child: Text('$count 人'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onPlayerCountChanged(value);
                    }
                  },
                ),
              ],
            ),
            
            // 選手一覧表示
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(
                playerCount,
                (index) => Chip(
                  avatar: CircleAvatar(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    child: Text('${index + 1}'),
                  ),
                  label: Text('選手${index + 1}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startMatch() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // チームを作成
      final teamA = Team(
        id: _uuid.v4(),
        name: _teamAController.text,
        players: List.generate(
          _playerCountA,
          (i) => Player(
            id: _uuid.v4(),
            jerseyNumber: i + 1,
            name: '選手${i + 1}',
          ),
        ),
      );
      
      final teamB = Team(
        id: _uuid.v4(),
        name: _teamBController.text,
        players: List.generate(
          _playerCountB,
          (i) => Player(
            id: _uuid.v4(),
            jerseyNumber: i + 1,
            name: '選手${i + 1}',
          ),
        ),
      );
      
      // 試合を初期化
      ref.read(matchProvider.notifier).initializeMatch(teamA, teamB);
      
      // 試合画面へ遷移
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MatchScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
