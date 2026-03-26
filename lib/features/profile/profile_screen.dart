import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../home/widgets/shimmer_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final historyAsync = ref.watch(watchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(watchHistoryProvider),
        child: CustomScrollView(
          slivers: [
            // ── User info ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withAlpha(51), width: 1),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withAlpha(51),
                      child: Text(
                        (user?.email?.isNotEmpty == true)
                            ? user!.email![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Usuario',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '—',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Watch history title ────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded,
                        color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Historial de vistas',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),

            // ── Watch history list ─────────────────────────────────────────
            historyAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const MovieListShimmer(),
                  childCount: 6,
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Error: $e',
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                  ),
                ),
              ),
              data: (history) {
                if (history.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.movie_filter_outlined,
                                size: 64,
                                color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text('No has visto ninguna película aún',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final item = history[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.fullPosterUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: item.fullPosterUrl,
                                  width: 50,
                                  height: 75,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      const PosterShimmer(
                                          width: 50, height: 75),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 50,
                                    height: 75,
                                    color: AppColors.cardColor,
                                    child: const Icon(
                                        Icons.movie_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20),
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 75,
                                  color: AppColors.cardColor,
                                  child: const Icon(Icons.movie_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20),
                                ),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 12,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(item.watchedAt),
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                        onTap: () =>
                            context.push('/movie/${item.movieId}'),
                      );
                    },
                    childCount: history.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(supabaseServiceProvider).signOut();
      if (context.mounted) context.go('/login');
    }
  }
}
