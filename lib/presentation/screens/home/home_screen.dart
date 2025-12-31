import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../providers/match_provider.dart';
import '../match/match_screen.dart';
import '../rulebook/rulebook_screen.dart';
import '../new_match/new_match_screen.dart';
import '../history/match_history_screen.dart';

/// ホーム画面
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アプリロゴ（仮）
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.sports_kabaddi,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 48),
              
              // タイトル
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'カバディ競技支援アプリケーション',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              
              // 新規試合ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startNewMatch(context, ref),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('新規試合を開始'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // デモ試合ボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _startDemoMatch(context, ref),
                  icon: const Icon(Icons.science),
                  label: const Text('デモ試合で体験'),
                ),
              ),
              const SizedBox(height: 16),
              
              // ルールブックボタン
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _openRulebook(context),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('ルールブックを見る'),
                ),
              ),
              const SizedBox(height: 8),
              
              // 試合履歴ボタン
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _openMatchHistory(context),
                  icon: const Icon(Icons.history),
                  label: const Text('試合履歴を見る'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startNewMatch(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewMatchScreen()),
    );
  }

  void _openRulebook(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RulebookScreen()),
    );
  }

  void _openMatchHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MatchHistoryScreen()),
    );
  }

  void _startDemoMatch(BuildContext context, WidgetRef ref) {
    ref.read(matchProvider.notifier).startDemoMatch();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MatchScreen()),
    );
  }
}
