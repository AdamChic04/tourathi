import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/section_header.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  static const _categories = [
    'hiking',
    'camping',
    'photography',
    'cultural',
    'food',
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final featured = MockData.activities.first;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('activities', isArabic),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ).animate().fadeIn(duration: 400.ms),
                  TextButton.icon(
                    onPressed: () => context.push('/travel-groups'),
                    icon: const Icon(Icons.groups, size: 18),
                    label: Text(AppStrings.get('travelGroups', isArabic)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.desertGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _FeaturedBanner(
              activity: featured,
              isArabic: isArabic,
              onTap: () => context.push('/activity/${featured.id}'),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 500.ms)
                .slideY(begin: 0.08, end: 0),
          ),
          ..._categories.map((category) {
            final activities = MockData.activities
                .where((a) => a.category == category)
                .toList();
            if (activities.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: AppStrings.get(category, isArabic),
                    viewAllLabel: AppStrings.get('viewAll', isArabic),
                    onViewAll: () => context.push('/travel-groups'),
                  ),
                  const SizedBox(height: 8),
                  ...activities.asMap().entries.map((entry) {
                    final index = entry.key;
                    final activity = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _ActivityCard(
                        activity: activity,
                        isArabic: isArabic,
                        onTap: () => context.push('/activity/${activity.id}'),
                      )
                          .animate()
                          .fadeIn(delay: (80 * index).ms, duration: 400.ms)
                          .slideX(begin: 0.05, end: 0),
                    );
                  }),
                ],
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({
    required this.activity,
    required this.isArabic,
    required this.onTap,
  });

  final Activity activity;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = isArabic ? activity.titleAr : activity.title;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(20),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.desertGold.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(imageUrl: activity.imageUrl, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldShimmer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isArabic ? '⭐ مميز' : '⭐ Featured',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.textStyle(
                        isArabic: isArabic,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _BannerChip(
                          icon: Icons.star,
                          label: activity.rating.toString(),
                        ),
                        const SizedBox(width: 8),
                        _BannerChip(
                          icon: Icons.hiking,
                          label: activity.difficulty,
                        ),
                        const SizedBox(width: 8),
                        _BannerChip(
                          icon: Icons.payments_outlined,
                          label: activity.price,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerChip extends StatelessWidget {
  const _BannerChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.isArabic,
    required this.onTap,
  });

  final Activity activity;
  final bool isArabic;
  final VoidCallback onTap;

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.emerald;
      case 'moderate':
        return AppColors.desertGold;
      case 'hard':
        return AppColors.softRed;
      default:
        return AppColors.warmBrown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isArabic ? activity.titleAr : activity.title;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.warmBrown.withValues(alpha: 0.1),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(AppTheme.radiusMedium),
                bottomStart: Radius.circular(AppTheme.radiusMedium),
              ),
              child: AppNetworkImage(
                imageUrl: activity.imageUrl,
                width: 120,
                height: 130,
                borderRadius: 0,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: AppColors.warmBrown),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activity.host,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _MetaChip(
                          icon: Icons.star,
                          label: activity.rating.toString(),
                          color: AppColors.desertGold,
                        ),
                        _MetaChip(
                          icon: Icons.speed,
                          label: activity.difficulty,
                          color: _difficultyColor(activity.difficulty),
                        ),
                        _MetaChip(
                          icon: Icons.payments_outlined,
                          label: activity.price,
                          color: AppColors.emerald,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 13, color: AppColors.warmBrown),
                        const SizedBox(width: 4),
                        Text(
                          activity.date,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.desertGold,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (activity.voucherDiscount != null) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.softRed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-${activity.voucherDiscount}%',
                              style: TextStyle(
                                color: AppColors.softRed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
