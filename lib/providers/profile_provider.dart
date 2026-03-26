import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_movie.dart';
import 'auth_provider.dart';

final watchHistoryProvider = FutureProvider<List<WatchHistory>>((ref) async {
  ref.watch(authStateProvider);
  return ref.read(supabaseServiceProvider).getWatchHistory();
});
