import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'match_provider.dart';
import '../../data/repositories/sync_repository.dart';

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final matchRepository = ref.read(matchRepositoryProvider);
  return SyncRepository(matchRepository);
});
