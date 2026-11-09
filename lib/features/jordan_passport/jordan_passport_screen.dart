import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/section_header.dart';

class JordanPassportScreen extends StatelessWidget {
  const JordanPassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final stamps = MockData.passportStamps;
    final missions = MockData.missions;
    final unlockedCount = stamps.where((s) => s.isUnlocked).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppStrings.get('passport', isArabic)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4A3728),
                      AppColors.warmBrown,
                      AppColors.sandBeige,
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 72,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _PassportBook(
                isArabic: isArabic,
                unlockedCount: unlockedCount,
                totalCount: stamps.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: isArabic ? 'أختام الزيارة' : 'Visit Stamps',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _StampTile(
                    stamp: stamps[index],
                    isArabic: isArabic,
                  );
                },
                childCount: stamps.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: isArabic ? 'إنجازات المغامرة' : 'Adventure Achievements',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AchievementBadge(
                      mission: missions[index],
                      isArabic: isArabic,
                    ),
                  );
                },
                childCount: missions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassportBook extends StatelessWidget {
  const _PassportBook({
    required this.isArabic,
    required this.unlockedCount,
    required this.totalCount,
  });

  final bool isArabic;
  final int unlockedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5C4033),
            Color(0xFF8B6914),
            Color(0xFFC89B3C),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.desertGold.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 12,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'جواز الأردن' : 'Jordan Passport',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            MockData.userName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'الأختام المفتوحة' : 'Stamps Collected',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$unlockedCount / $totalCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: unlockedCount / totalCount,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class _StampTile extends StatelessWidget {
  const _StampTile({
    required this.stamp,
    required this.isArabic,
  });

  final PassportStamp stamp;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final unlocked = stamp.isUnlocked;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: AppTheme.radiusMedium,
      gradient: unlocked
          ? LinearGradient(
              colors: [
                AppColors.desertGold.withValues(alpha: 0.15),
                AppColors.sandBeige.withValues(alpha: 0.1),
              ],
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stamp.icon,
            style: TextStyle(
              fontSize: 32,
              color: unlocked ? null : Colors.grey.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? stamp.nameAr : stamp.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: unlocked
                      ? null
                      : Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.4),
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (unlocked && stamp.date != null) ...[
            const SizedBox(height: 4),
            Text(
              stamp.date!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.desertGold,
                  ),
            ),
          ] else if (!unlocked)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.mission,
    required this.isArabic,
  });

  final Mission mission;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: mission.isCompleted
                  ? AppColors.goldShimmer
                  : LinearGradient(
                      colors: [
                        Colors.grey.withValues(alpha: 0.2),
                        Colors.grey.withValues(alpha: 0.1),
                      ],
                    ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(mission.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? mission.titleAr : mission.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${mission.reward} ${isArabic ? 'نقطة' : 'pts'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.desertGold,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            mission.isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: mission.isCompleted
                ? AppColors.emerald
                : AppColors.warmBrown.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
