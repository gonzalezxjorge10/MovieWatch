import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_movie.dart';
import 'auth_provider.dart';

final favoritesProvider = FutureProvider<List<UserMovie>>((ref) async {
  ref.watch(authStateProvider); // Rebuild when auth changes
  return ref.read(supabaseServiceProvider).getFavorites();
});

final isFavoriteProvider =
    FutureProvider.family<bool, int>((ref, movieId) async {
  ref.watch(authStateProvider);
  return ref.read(supabaseServiceProvider).isFavorite(movieId);
});

final userRatingProvider =
    FutureProvider.family<double?, int>((ref, movieId) async {
  ref.watch(authStateProvider);
  return ref.read(supabaseServiceProvider).getUserRating(movieId);
});
