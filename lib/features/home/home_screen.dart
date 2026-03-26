import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/movie_providers.dart';
import 'widgets/movie_card.dart';
import 'widgets/movie_grid_card.dart';
import 'widgets/shimmer_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popular = ref.watch(popularMoviesProvider);
    final trending = ref.watch(trendingMoviesProvider);
    final recommended = ref.watch(recommendedMoviesProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(popularMoviesProvider);
        ref.invalidate(trendingMoviesProvider);
        ref.invalidate(recommendedMoviesProvider);
      },
      child: CustomScrollView(
        slivers: [
          // App bar
          const SliverAppBar(
            title: Text(
              'MovieMatch',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
          ),

          // ── Para ti ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionTitle(
              icon: Icons.recommend_rounded,
              title: 'Para ti',
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: recommended.when(
                loading: () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 6,
                  itemBuilder: (_, __) => const MovieCardShimmer(),
                ),
                error: (e, _) =>
                    _ErrorRow(message: e.toString()),
                data: (movies) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: movies.length,
                  itemBuilder: (_, i) => MovieCard(
                    movie: movies[i],
                    onTap: () =>
                        context.push('/movie/${movies[i].id}'),
                  ),
                ),
              ),
            ),
          ),

          // ── Populares ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionTitle(
              icon: Icons.local_fire_department_rounded,
              title: 'Populares',
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: popular.when(
                loading: () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 6,
                  itemBuilder: (_, __) => const MovieCardShimmer(),
                ),
                error: (e, _) =>
                    _ErrorRow(message: e.toString()),
                data: (movies) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: movies.length,
                  itemBuilder: (_, i) => MovieCard(
                    movie: movies[i],
                    onTap: () =>
                        context.push('/movie/${movies[i].id}'),
                  ),
                ),
              ),
            ),
          ),

          // ── En Tendencia ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionTitle(
              icon: Icons.trending_up_rounded,
              title: 'En tendencia',
            ),
          ),
          trending.when(
            loading: () => SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const MovieGridShimmer(),
                childCount: 6,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: _ErrorRow(message: e.toString()),
            ),
            data: (movies) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => MovieGridCard(
                    movie: movies[i],
                    onTap: () =>
                        context.push('/movie/${movies[i].id}'),
                  ),
                  childCount: movies.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  const _ErrorRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error: $message',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
