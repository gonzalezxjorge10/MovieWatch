import 'package:dio/dio.dart';

import '../../models/movie.dart';
import '../constants/app_constants.dart';

class TmdbService {
  late final Dio _dio;

  TmdbService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.tmdbBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Authorization': 'Bearer ${AppConstants.tmdbBearerToken}',
          'accept': 'application/json',
        },
      ),
    );
  }

  Future<List<Movie>> getPopular({int page = 1}) async {
    final response = await _dio.get(
      '/3/movie/popular',
      queryParameters: {'page': page, 'language': 'es-MX'},
    );
    return _parseMovieList(response.data);
  }

  Future<List<Movie>> getTrending() async {
    final response = await _dio.get(
      '/3/trending/movie/week',
      queryParameters: {'language': 'es-MX'},
    );
    return _parseMovieList(response.data);
  }

  Future<Movie> getRandomMovie() async {
    final randomPage = 1 + (DateTime.now().millisecond % 10);
    final response = await _dio.get(
      '/3/movie/popular',
      queryParameters: {'page': randomPage, 'language': 'es-MX'},
    );
    final movies = _parseMovieList(response.data);
    if (movies.isEmpty) throw Exception('No se encontraron películas');
    movies.shuffle();
    return movies.first;
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await _dio.get(
      '/3/search/movie',
      queryParameters: {'query': query.trim(), 'language': 'es-MX'},
    );
    return _parseMovieList(response.data);
  }

  Future<Movie> getMovieDetail(int id) async {
    final response = await _dio.get(
      '/3/movie/$id',
      queryParameters: {'language': 'es-MX'},
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    // Normalize: detail endpoint returns 'genres' objects, list endpoints return 'genre_ids'
    if (data['genre_ids'] == null && data['genres'] != null) {
      data['genre_ids'] = (data['genres'] as List)
          .map((g) => (g as Map<String, dynamic>)['id'] as int)
          .toList();
    }
    return Movie.fromJson(data);
  }

  Future<List<Movie>> discoverByGenre(int genreId, {int page = 1}) async {
    final response = await _dio.get(
      '/3/discover/movie',
      queryParameters: {
        'with_genres': genreId.toString(),
        'sort_by': 'popularity.desc',
        'page': page,
        'language': 'es-MX',
      },
    );
    return _parseMovieList(response.data);
  }

  List<Movie> _parseMovieList(dynamic data) {
    final results =
        (data as Map<String, dynamic>)['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
