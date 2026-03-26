import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../home/widgets/shimmer_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis favoritos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(favoritesProvider),
          ),
        ],
      ),
      body: favoritesAsync.when(
        loading: () => ListView.builder(
          itemCount: 6,
          itemBuilder: (_, __) => const MovieListShimmer(),
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
                Text('Error: $e',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 80, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Aún no tienes favoritos',
                      style: TextStyle(
                          fontSize: 18, color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Text('Toca ❤️ en cualquier película para guardarla',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, i) {
              final fav = favorites[i];
              return Dismissible(
                key: Key('fav_${fav.movieId}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red[700],
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 28),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: const Text('Eliminar favorito'),
                          content: Text(
                              '¿Quitar "${fav.title}" de favoritos?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Eliminar',
                                  style:
                                      TextStyle(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) async {
                  try {
                    await ref
                        .read(supabaseServiceProvider)
                        .removeFavorite(fav.movieId);
                    ref.invalidate(favoritesProvider);
                    ref.invalidate(isFavoriteProvider(fav.movieId));
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar: $e'),
                          backgroundColor: Colors.red[700],
                        ),
                      );
                    }
                  }
                },
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: fav.fullPosterUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: fav.fullPosterUrl,
                            width: 54,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const PosterShimmer(
                                width: 54, height: 80),
                            errorWidget: (_, __, ___) => Container(
                              width: 54,
                              height: 80,
                              color: AppColors.cardColor,
                              child: const Icon(Icons.movie_outlined,
                                  color: AppColors.textSecondary),
                            ),
                          )
                        : Container(
                            width: 54,
                            height: 80,
                            color: AppColors.cardColor,
                            child: const Icon(Icons.movie_outlined,
                                color: AppColors.textSecondary),
                          ),
                  ),
                  title: Text(
                    fav.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Guardado el ${_formatDate(fav.createdAt)}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                  onTap: () => context.push('/movie/${fav.movieId}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
