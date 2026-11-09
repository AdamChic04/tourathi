import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class ActivityDetailsScreen extends StatefulWidget {
  const ActivityDetailsScreen({super.key, required this.activityId});

  final String activityId;

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  bool _isBooking = false;

  Activity get _activity => MockData.activities.firstWhere(
        (a) => a.id == widget.activityId,
        orElse: () => MockData.activities.first,
      );

  Future<void> _bookNow() async {
    setState(() => _isBooking = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _isBooking = false);
      _showTicketDialog();
    }
  }

  void _showTicketDialog() {
    final isArabic = context.read<AppProvider>().isArabic;
    final activity = _activity;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.goldShimmer,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.confirmation_number,
                  size: 64, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'تم الحجز!' : 'Booking Confirmed!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? activity.titleAr : activity.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'TR-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: isArabic ? 'عرض التذاكر' : 'View Tickets',
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/tickets');
                },
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final activity = _activity;
    final title = isArabic ? activity.titleAr : activity.title;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: activity.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 0,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.desertGold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppStrings.get(activity.category, isArabic),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: AppColors.desertGold, size: 18),
                            Text(
                              ' ${activity.rating}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              activity.date,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Section(
                    letter: 'A',
                    title: isArabic ? 'الوجهة' : 'Destination',
                    icon: Icons.place,
                    child: Text(
                      activity.destination ?? activity.host,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  _Section(
                    letter: 'B',
                    title: isArabic ? 'خريطة المسار' : 'Route Map',
                    icon: Icons.map_outlined,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.sandBeige.withValues(alpha: 0.3),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: AppColors.sandBeige.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map,
                              size: 48,
                              color: AppColors.warmBrown.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text(
                            isArabic ? 'خريطة تفاعلية قريباً' : 'Interactive map coming soon',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _Section(
                    letter: 'C',
                    title: isArabic ? 'المنظم' : 'Organizer',
                    icon: Icons.person_outline,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.desertGold,
                          child: Text(
                            (activity.organizer ?? activity.host)[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.organizer ?? activity.host,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              activity.host,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (activity.communityName != null)
                    _Section(
                      letter: 'D',
                      title: isArabic ? 'المجتمع' : 'Community',
                      icon: Icons.groups,
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.verified,
                                color: AppColors.emerald),
                            const SizedBox(width: 12),
                            Text(
                              activity.communityName!,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (activity.historicalSummary != null)
                    _Section(
                      letter: 'E',
                      title: isArabic ? 'ملخص تاريخي' : 'Historical Summary',
                      icon: Icons.history_edu,
                      child: Text(
                        activity.historicalSummary!,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(height: 1.6),
                      ),
                    ),
                  _Section(
                    letter: 'F',
                    title: isArabic ? 'مستوى الصعوبة' : 'Difficulty',
                    icon: Icons.fitness_center,
                    child: _DifficultyBadge(level: activity.difficulty),
                  ),
                  if (activity.whatToBring != null)
                    _Section(
                      letter: 'G',
                      title: isArabic ? 'ماذا تحضر' : 'What to Bring',
                      icon: Icons.backpack_outlined,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: activity.whatToBring!
                            .map(
                              (item) => Chip(
                                label: Text(item),
                                backgroundColor:
                                    AppColors.sandBeige.withValues(alpha: 0.3),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  if (activity.schedule != null)
                    _Section(
                      letter: 'H',
                      title: isArabic ? 'الجدول الزمني' : 'Timeline Schedule',
                      icon: Icons.schedule,
                      child: Column(
                        children: activity.schedule!.asMap().entries.map((e) {
                          final isLast = e.key == activity.schedule!.length - 1;
                          return _TimelineItem(
                            time: e.value.time,
                            activity: e.value.activity,
                            isLast: isLast,
                          );
                        }).toList(),
                      ),
                    ),
                  _Section(
                    letter: 'I',
                    title: isArabic ? 'التكلفة' : 'Cost',
                    icon: Icons.payments_outlined,
                    child: Row(
                      children: [
                        Text(
                          activity.price,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.desertGold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? 'للشخص' : 'per person',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (activity.voucherDiscount != null)
                    _Section(
                      letter: 'J',
                      title: isArabic ? 'القسائم' : 'Vouchers',
                      icon: Icons.local_offer,
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.emerald.withValues(alpha: 0.15),
                            AppColors.desertGold.withValues(alpha: 0.1),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.discount,
                                color: AppColors.emerald, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isArabic
                                    ? 'خصم ${activity.voucherDiscount}% متاح — استخدم نقاط المكافآت'
                                    : '${activity.voucherDiscount}% discount available — use reward points',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (activity.safetyInstructions != null)
                    _Section(
                      letter: 'K',
                      title: isArabic ? 'السلامة' : 'Safety',
                      icon: Icons.health_and_safety,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: activity.safetyInstructions!
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_outline,
                                        color: AppColors.emerald, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(s)),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BookingBar(
        price: activity.price,
        isArabic: isArabic,
        isLoading: _isBooking,
        onBook: _bookNow,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.letter,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String letter;
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppColors.desertGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: AppColors.desertGold, size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.level});

  final String level;

  Color get _color {
    switch (level.toLowerCase()) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.time,
    required this.activity,
    required this.isLast,
  });

  final String time;
  final String activity;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.desertGold,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.sandBeige,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: AppColors.desertGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(activity,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({
    required this.price,
    required this.isArabic,
    required this.isLoading,
    required this.onBook,
  });

  final String price;
  final bool isArabic;
  final bool isLoading;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'السعر' : 'Price',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.desertGold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: GradientButton(
                label: AppStrings.get('bookNow', isArabic),
                icon: Icons.confirmation_number_outlined,
                isLoading: isLoading,
                onPressed: onBook,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
