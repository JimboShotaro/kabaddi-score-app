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
  int _benchCountA = 0;
  int _benchCountB = 0;
  bool _isLoading = false;

  final List<TextEditingController> _playerNameControllersA = [];
  final List<TextEditingController> _playerNameControllersB = [];
  final List<TextEditingController> _benchNameControllersA = [];
  final List<TextEditingController> _benchNameControllersB = [];

  final List<FocusNode> _playerFocusNodesA = [];
  final List<FocusNode> _playerFocusNodesB = [];
  final List<FocusNode> _benchFocusNodesA = [];
  final List<FocusNode> _benchFocusNodesB = [];

  List<String> _savedRosterNames = const [];

  @override
  void initState() {
    super.initState();
    _resizeControllers(
      controllers: _playerNameControllersA,
      newLength: _playerCountA,
      defaultText: (i) => '選手${i + 1}',
    );
    _resizeFocusNodes(focusNodes: _playerFocusNodesA, newLength: _playerCountA);
    _resizeControllers(
      controllers: _playerNameControllersB,
      newLength: _playerCountB,
      defaultText: (i) => '選手${i + 1}',
    );
    _resizeFocusNodes(focusNodes: _playerFocusNodesB, newLength: _playerCountB);

    Future(() async {
      final names = await ref.read(rosterRepositoryProvider).getRosterNames();
      if (!mounted) return;
      setState(() => _savedRosterNames = names);
    });
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();

    for (final c in _playerNameControllersA) {
      c.dispose();
    }
    for (final c in _playerNameControllersB) {
      c.dispose();
    }
    for (final c in _benchNameControllersA) {
      c.dispose();
    }
    for (final c in _benchNameControllersB) {
      c.dispose();
    }

    for (final f in _playerFocusNodesA) {
      f.dispose();
    }
    for (final f in _playerFocusNodesB) {
      f.dispose();
    }
    for (final f in _benchFocusNodesA) {
      f.dispose();
    }
    for (final f in _benchFocusNodesB) {
      f.dispose();
    }

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
                benchCount: _benchCountA,
                onPlayerCountChanged: (count) {
                  setState(() {
                    _playerCountA = count;
                    _resizeControllers(
                      controllers: _playerNameControllersA,
                      newLength: _playerCountA,
                      defaultText: (i) => '選手${i + 1}',
                    );
                    _resizeFocusNodes(
                      focusNodes: _playerFocusNodesA,
                      newLength: _playerCountA,
                    );
                  });
                },
                onBenchCountChanged: (count) {
                  setState(() {
                    _benchCountA = count;
                    _resizeControllers(
                      controllers: _benchNameControllersA,
                      newLength: _benchCountA,
                      defaultText: (i) => '控え${i + 1}',
                    );
                    _resizeFocusNodes(
                      focusNodes: _benchFocusNodesA,
                      newLength: _benchCountA,
                    );
                  });
                },
                playerNameControllers: _playerNameControllersA,
                benchNameControllers: _benchNameControllersA,
                playerFocusNodes: _playerFocusNodesA,
                benchFocusNodes: _benchFocusNodesA,
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
                benchCount: _benchCountB,
                onPlayerCountChanged: (count) {
                  setState(() {
                    _playerCountB = count;
                    _resizeControllers(
                      controllers: _playerNameControllersB,
                      newLength: _playerCountB,
                      defaultText: (i) => '選手${i + 1}',
                    );
                    _resizeFocusNodes(
                      focusNodes: _playerFocusNodesB,
                      newLength: _playerCountB,
                    );
                  });
                },
                onBenchCountChanged: (count) {
                  setState(() {
                    _benchCountB = count;
                    _resizeControllers(
                      controllers: _benchNameControllersB,
                      newLength: _benchCountB,
                      defaultText: (i) => '控え${i + 1}',
                    );
                    _resizeFocusNodes(
                      focusNodes: _benchFocusNodesB,
                      newLength: _benchCountB,
                    );
                  });
                },
                playerNameControllers: _playerNameControllersB,
                benchNameControllers: _benchNameControllersB,
                playerFocusNodes: _playerFocusNodesB,
                benchFocusNodes: _benchFocusNodesB,
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
    required int benchCount,
    required ValueChanged<int> onPlayerCountChanged,
    required ValueChanged<int> onBenchCountChanged,
    required List<TextEditingController> playerNameControllers,
    required List<TextEditingController> benchNameControllers,
    required List<FocusNode> playerFocusNodes,
    required List<FocusNode> benchFocusNodes,
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
                      .map(
                        (count) => DropdownMenuItem(
                          value: count,
                          child: Text('$count 人'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onPlayerCountChanged(value);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 控え人数選択
            Row(
              children: [
                const Text('控え: '),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: benchCount,
                  items: List.generate(8, (i) => i)
                      .map(
                        (count) => DropdownMenuItem(
                          value: count,
                          child: Text('$count 人'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onBenchCountChanged(value);
                    }
                  },
                ),
              ],
            ),

            // 選手一覧表示
            const SizedBox(height: 8),
            ...List.generate(
              playerCount,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRosterNameField(
                  controller: playerNameControllers[index],
                  focusNode: playerFocusNodes[index],
                  labelText: '選手${index + 1}',
                  icon: Icons.person,
                  color: color,
                ),
              ),
            ),

            if (benchCount > 0) ...[
              const SizedBox(height: 8),
              const Text(
                '控え',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                benchCount,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildRosterNameField(
                    controller: benchNameControllers[index],
                    focusNode: benchFocusNodes[index],
                    labelText: '控え${index + 1}',
                    icon: Icons.event_seat,
                    color: color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRosterNameField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required IconData icon,
    required Color color,
  }) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) {
          return _savedRosterNames.take(20);
        }

        return _savedRosterNames
            .where((name) => name.toLowerCase().contains(query))
            .take(20);
      },
      onSelected: (selection) {
        controller.text = selection;
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            prefixIcon: Icon(icon, color: color),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '選手名を入力してください';
            }
            return null;
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _resizeControllers({
    required List<TextEditingController> controllers,
    required int newLength,
    required String Function(int index) defaultText,
  }) {
    if (newLength < 0) return;

    while (controllers.length > newLength) {
      final last = controllers.removeLast();
      last.dispose();
    }
    while (controllers.length < newLength) {
      controllers.add(TextEditingController(text: defaultText(controllers.length)));
    }
  }

  void _resizeFocusNodes({
    required List<FocusNode> focusNodes,
    required int newLength,
  }) {
    if (newLength < 0) return;

    while (focusNodes.length > newLength) {
      final last = focusNodes.removeLast();
      last.dispose();
    }
    while (focusNodes.length < newLength) {
      focusNodes.add(FocusNode());
    }
  }

  Future<void> _startMatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(rosterRepositoryProvider).addRosterNames([
        ..._playerNameControllersA.map((c) => c.text),
        ..._benchNameControllersA.map((c) => c.text),
        ..._playerNameControllersB.map((c) => c.text),
        ..._benchNameControllersB.map((c) => c.text),
      ]);

      // チームを作成
      final teamA = Team(
        id: _uuid.v4(),
        name: _teamAController.text,
        players: [
          ...List.generate(
            _playerCountA,
            (i) => Player(
              id: _uuid.v4(),
              jerseyNumber: i + 1,
              name: _playerNameControllersA[i].text.trim(),
              status: PlayerStatus.active,
            ),
          ),
          ...List.generate(
            _benchCountA,
            (i) => Player(
              id: _uuid.v4(),
              jerseyNumber: _playerCountA + i + 1,
              name: _benchNameControllersA[i].text.trim(),
              status: PlayerStatus.bench,
            ),
          ),
        ],
      );

      final teamB = Team(
        id: _uuid.v4(),
        name: _teamBController.text,
        players: [
          ...List.generate(
            _playerCountB,
            (i) => Player(
              id: _uuid.v4(),
              jerseyNumber: i + 1,
              name: _playerNameControllersB[i].text.trim(),
              status: PlayerStatus.active,
            ),
          ),
          ...List.generate(
            _benchCountB,
            (i) => Player(
              id: _uuid.v4(),
              jerseyNumber: _playerCountB + i + 1,
              name: _benchNameControllersB[i].text.trim(),
              status: PlayerStatus.bench,
            ),
          ),
        ],
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
