import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';

/// Generic shimmer skeleton for a poster card.
class PosterShimmer extends StatelessWidget {
  final double width;
  final double height;

  const PosterShimmer({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        color: AppColors.shimmerBase,
      ),
    );
  }
}

/// Shimmer for a horizontal-scroll movie card (120×220).
class MovieCardShimmer extends StatelessWidget {
  const MovieCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                  height: 170, color: AppColors.shimmerHighlight),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 10,
                      width: 80,
                      color: AppColors.shimmerHighlight),
                  const SizedBox(height: 6),
                  Container(
                      height: 10,
                      width: 50,
                      color: AppColors.shimmerHighlight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for a grid card.
class MovieGridShimmer extends StatelessWidget {
  const MovieGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Shimmer for a list-row item (search / history).
class MovieListShimmer extends StatelessWidget {
  const MovieListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.shimmerHighlight,
                  borderRadius: BorderRadius.circular(8),
                )),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 14,
                      width: double.infinity,
                      color: AppColors.shimmerHighlight),
                  const SizedBox(height: 6),
                  Container(
                      height: 12,
                      width: 80,
                      color: AppColors.shimmerHighlight),
                  const SizedBox(height: 6),
                  Container(
                      height: 12,
                      width: 50,
                      color: AppColors.shimmerHighlight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
