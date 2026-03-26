import '../core/constants/app_constants.dart';

class UserMovie {
  final String id;
  final String userId;
  final int movieId;
  final String title;
  final String posterPath;
  final List<int> genreIds;
  final DateTime createdAt;

  const UserMovie({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.title,
    required this.posterPath,
    required this.genreIds,
    required this.createdAt,
  });

  factory UserMovie.fromJson(Map<String, dynamic> json) {
    return UserMovie(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      movieId: json['movie_id'] as int,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get fullPosterUrl => posterPath.isNotEmpty
      ? '${AppConstants.tmdbImageBaseUrl}$posterPath'
      : '';
}

class WatchHistory {
  final String id;
  final String userId;
  final int movieId;
  final String title;
  final String posterPath;
  final DateTime watchedAt;

  const WatchHistory({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.title,
    required this.posterPath,
    required this.watchedAt,
  });

  factory WatchHistory.fromJson(Map<String, dynamic> json) {
    return WatchHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      movieId: json['movie_id'] as int,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      watchedAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get fullPosterUrl => posterPath.isNotEmpty
      ? '${AppConstants.tmdbImageBaseUrl}$posterPath'
      : '';
}
