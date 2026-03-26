import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/tmdb_service.dart';
import '../models/movie.dart';
import 'auth_provider.dart';

final tmdbServiceProvider = Provider<TmdbService>((ref) => TmdbService());

final popularMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.read(tmdbServiceProvider).getPopular();
});

final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.read(tmdbServiceProvider).getTrending();
});

final recommendedMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  final tmdbService = ref.read(tmdbServiceProvider);

  try {
    final favorites = await supabaseService.getFavorites();
    if (favorites.isEmpty) {
      return tmdbService.getPopular(page: 2);
    }

    final genreCount = <int, int>{};
    for (final fav in favorites) {
      for (final genreId in fav.genreIds) {
        genreCount[genreId] = (genreCount[genreId] ?? 0) + 1;
      }
    }

    if (genreCount.isEmpty) return tmdbService.getPopular(page: 2);

    final topGenre =
        genreCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final movies = await tmdbService.discoverByGenre(topGenre);
    return movies.take(10).toList();
  } catch (_) {
    return tmdbService.getPopular(page: 2);
  }
});

final movieDetailProvider =
    FutureProvider.family<Movie, int>((ref, id) {
  return ref.read(tmdbServiceProvider).getMovieDetail(id);
});

final searchMoviesProvider =
    FutureProvider.family<List<Movie>, String>((ref, query) {
  return ref.read(tmdbServiceProvider).searchMovies(query);
});
