import '../core/constants/app_constants.dart';

class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final double voteAverage;
  final List<int> genreIds;
  final List<String> genreNames;
  final String releaseDate;

  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.voteAverage,
    required this.genreIds,
    this.genreNames = const [],
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      genreNames: (json['genres'] as List<dynamic>?)
              ?.map((g) =>
                  (g as Map<String, dynamic>)['name'] as String? ?? '')
              .where((n) => n.isNotEmpty)
              .toList() ??
          [],
      releaseDate: json['release_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toSupabase() => {
        'movie_id': id,
        'title': title,
        'poster_path': posterPath,
        'genre_ids': genreIds,
      };

  String get fullPosterUrl => posterPath.isNotEmpty
      ? '${AppConstants.tmdbImageBaseUrl}$posterPath'
      : '';

  String get year =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '—';
}
