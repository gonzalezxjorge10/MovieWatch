import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/movie_providers.dart';
import '../home/widgets/shimmer_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isNotEmpty
        ? ref.watch(searchMoviesProvider(_query))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Título, actor, director…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(results),
    );
  }

  Widget _buildBody(AsyncValue<List>? results) {
    if (_query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('Escribe para buscar películas',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (results == null) return const SizedBox.shrink();

    return results.when(
      loading: () => ListView.builder(
        itemCount: 8,
        itemBuilder: (_, __) => const MovieListShimmer(),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error: $e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ),
      data: (movies) {
        if (movies.isEmpty) {
          return const Center(
            child: Text('Sin resultados',
                style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, i) {
            final movie = movies[i];
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: movie.fullPosterUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: movie.fullPosterUrl,
                        width: 50,
                        height: 75,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const PosterShimmer(
                            width: 50, height: 75),
                        errorWidget: (_, __, ___) => Container(
                          width: 50,
                          height: 75,
                          color: AppColors.cardColor,
                          child: const Icon(Icons.movie_outlined,
                              color: AppColors.textSecondary, size: 20),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 75,
                        color: AppColors.cardColor,
                        child: const Icon(Icons.movie_outlined,
                            color: AppColors.textSecondary, size: 20),
                      ),
              ),
              title: Text(
                movie.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                children: [
                  Text(movie.year,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(width: 12),
                  const Icon(Icons.star_rounded,
                      size: 13, color: Colors.amber),
                  const SizedBox(width: 3),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              onTap: () => context.push('/movie/${movie.id}'),
            );
          },
        );
      },
    );
  }
}
