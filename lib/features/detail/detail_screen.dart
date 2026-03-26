import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/movie.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/movie_providers.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final int movieId;

  const DetailScreen({super.key, required this.movieId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool? _isFavorite;
  double? _userRating;
  bool _historyRecorded = false;

  @override
  Widget build(BuildContext context) {
    final movieAsync = ref.watch(movieDetailProvider(widget.movieId));

    // Sync isFavorite from provider (first load only)
    ref.listen(isFavoriteProvider(widget.movieId), (_, next) {
      if (next.hasValue && _isFavorite == null) {
        setState(() => _isFavorite = next.value);
      }
    });

    // Sync user rating from provider (first load only)
    ref.listen(userRatingProvider(widget.movieId), (_, next) {
      if (next.hasValue && _userRating == null) {
        setState(() => _userRating = next.value);
      }
    });

    // Record watch history once movie data is available
    ref.listen(movieDetailProvider(widget.movieId), (prev, next) {
      if (!_historyRecorded && next.hasValue) {
        _historyRecorded = true;
        ref
            .read(supabaseServiceProvider)
            .addToWatchHistory(next.value!)
            .ignore();
      }
    });

    return Scaffold(
      body: movieAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.primary, size: 56),
                const SizedBox(height: 12),
                Text('No se pudo cargar la película\n$e',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        data: (movie) => CustomScrollView(
          slivers: [
            // ── Hero app bar with poster ────────────────────────────────
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: AppColors.background,
              leading: const _BackButton(),
              actions: [
                IconButton(
                  tooltip: _isFavorite == true
                      ? 'Quitar de favoritos'
                      : 'Agregar a favoritos',
                  icon: Icon(
                    _isFavorite == true
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isFavorite == true
                        ? AppColors.primary
                        : Colors.white,
                    size: 28,
                  ),
                  onPressed: () => _toggleFavorite(movie),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    movie.fullPosterUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: '${AppConstants.tmdbImageBaseUrl}'
                                '${movie.posterPath}',
                            fit: BoxFit.cover,
                          )
                        : Container(color: AppColors.cardColor),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.background],
                          stops: [0.55, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + year
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (movie.year.isNotEmpty) ...[
                          const Icon(Icons.calendar_today_rounded,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(movie.year,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                          const SizedBox(width: 16),
                        ],
                        const Icon(Icons.star_rounded,
                            size: 15, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.voteAverage.toStringAsFixed(1)} / 10',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Genre chips
                    if (movie.genreNames.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: movie.genreNames
                            .map((g) => _GenreChip(label: g))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Overview
                    const Text(
                      'Sinopsis',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview.isNotEmpty
                          ? movie.overview
                          : 'Sin sinopsis disponible.',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    // Rating
                    const Text(
                      'Tu calificación',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    RatingBar.builder(
                      initialRating: _userRating ?? 0,
                      minRating: 0.5,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 32,
                      unratedColor: AppColors.cardColor,
                      itemPadding:
                          const EdgeInsets.symmetric(horizontal: 3),
                      itemBuilder: (_, __) => const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() => _userRating = rating);
                        _saveRating(movie.id, rating);
                      },
                    ),
                    if (_userRating != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Tu nota: ${_userRating!.toStringAsFixed(1)} / 5.0',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(Movie movie) async {
    final current = _isFavorite ?? false;
    setState(() => _isFavorite = !current);
    try {
      final service = ref.read(supabaseServiceProvider);
      if (!current) {
        await service.addFavorite(movie);
      } else {
        await service.removeFavorite(movie.id);
      }
      ref.invalidate(favoritesProvider);
      ref.invalidate(isFavoriteProvider(movie.id));
      ref.invalidate(recommendedMoviesProvider);
    } catch (e) {
      // Revert on error
      setState(() => _isFavorite = current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _saveRating(int movieId, double rating) async {
    try {
      await ref
          .read(supabaseServiceProvider)
          .setRating(movieId: movieId, rating: rating);
      ref.invalidate(userRatingProvider(movieId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo guardar la calificación: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  const _GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withAlpha(102), width: 0.8),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.primary, fontSize: 11)),
    );
  }
}
