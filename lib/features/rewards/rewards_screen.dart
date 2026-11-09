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
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/section_header.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  static const int _pointsBalance = 2450;
  static const int _level = 7;
  static const int _pointsToNextLevel = 3000;
  static const String _levelTitle = 'Explorer';

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final progress = _pointsBalance / _pointsToNextLevel;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppStrings.get('rewards', isArabic)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.desertGradient,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PointsBalanceCard(
                    isArabic: isArabic,
                    points: _pointsBalance,
                    level: _level,
                    levelTitle: _levelTitle,
                    progress: progress,
                    pointsToNext: _pointsToNextLevel - _pointsBalance,
                  ).animate().fadeIn().scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                      ),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: isArabic ? 'المهمات' : 'Missions',
                  ),
                  const SizedBox(height: 12),
                  ...MockData.missions.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MissionCard(
                        mission: entry.value,
                        isArabic: isArabic,
                      )
                          .animate()
                          .fadeIn(delay: (entry.key * 80).ms)
                          .slideX(begin: 0.05, end: 0),
                    );
                  }),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: isArabic ? 'استبدال المكافآت' : 'Redemption',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isArabic
                        ? 'اجمع الطوابع وافتح وجهات جديدة'
                        : 'Collect stamps and unlock new destinations',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.warmBrown,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _PassportStampGrid(isArabic: isArabic),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: isArabic ? 'استبدال النقاط' : 'Redeem Points',
                    icon: Icons.redeem,
                    onPressed: () {},
                    width: double.infinity,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsBalanceCard extends StatelessWidget {
  const _PointsBalanceCard({
    required this.isArabic,
    required this.points,
    required this.level,
    required this.levelTitle,
    required this.progress,
    required this.pointsToNext,
  });

  final bool isArabic;
  final int points;
  final int level;
  final String levelTitle;
  final double progress;
  final int pointsToNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.goldShimmer,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.desertGold.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'رصيد النقاط' : 'Points Balance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      isArabic ? 'المستوى $level' : 'Level $level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      levelTitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? '$pointsToNext نقطة للمستوى ${level + 1}'
                : '$pointsToNext points to Level ${level + 1}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.isArabic});

  final Mission mission;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final title = isArabic ? mission.titleAr : mission.title;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: mission.isCompleted
                  ? AppColors.emerald.withValues(alpha: 0.15)
                  : AppColors.desertGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(mission.icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 14,
                      color: AppColors.desertGold,
                    ),
                    Text(
                      ' +${mission.reward} ${isArabic ? 'نقطة' : 'pts'}',
                      style: TextStyle(
                        color: AppColors.desertGold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (mission.isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, color: AppColors.emerald, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    isArabic ? 'مكتمل' : 'Done',
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            Icon(Icons.chevron_right, color: AppColors.warmBrown),
        ],
      ),
    );
  }
}

class _PassportStampGrid extends StatelessWidget {
  const _PassportStampGrid({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: MockData.passportStamps.length,
      itemBuilder: (context, index) {
        final stamp = MockData.passportStamps[index];
        return _StampTile(stamp: stamp, isArabic: isArabic)
            .animate()
            .fadeIn(delay: (index * 60).ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
      },
    );
  }
}

class _StampTile extends StatelessWidget {
  const _StampTile({required this.stamp, required this.isArabic});

  final PassportStamp stamp;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final name = isArabic ? stamp.nameAr : stamp.name;
    final unlocked = stamp.isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.ivoryWhite
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: unlocked
              ? AppColors.desertGold.withValues(alpha: 0.6)
              : AppColors.sandBeige.withValues(alpha: 0.4),
          width: unlocked ? 2 : 1,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: AppColors.desertGold.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (unlocked)
            Positioned(
              top: 6,
              right: 6,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.softRed.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'STAMP',
                    style: TextStyle(
                      color: AppColors.softRed.withValues(alpha: 0.7),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          Center(
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
                const SizedBox(height: 6),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight:
                            unlocked ? FontWeight.w600 : FontWeight.normal,
                        color: unlocked
                            ? AppColors.darkCharcoal
                            : AppColors.warmBrown.withValues(alpha: 0.5),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (unlocked && stamp.date != null)
                  Text(
                    stamp.date!,
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.warmBrown.withValues(alpha: 0.6),
                    ),
                  ),
                if (!unlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: AppColors.warmBrown.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
