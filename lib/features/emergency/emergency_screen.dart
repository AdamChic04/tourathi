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

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  static const _sections = [
    ('hospital', 'Hospitals', 'مستشفيات', Icons.local_hospital_rounded,
        AppColors.softRed),
    ('pharmacy', 'Pharmacies', 'صيدليات', Icons.local_pharmacy_rounded,
        AppColors.emerald),
    ('health_center', 'Health Centers', 'مراكز صحية',
        Icons.medical_services_rounded, AppColors.royalBlue),
    ('police', 'Police', 'شرطة', Icons.local_police_rounded,
        AppColors.darkCharcoal),
    ('tourist_police', 'Tourist Police', 'شرطة السياحة',
        Icons.support_agent_rounded, AppColors.desertGold),
  ];

  List<EmergencyPlace> _placesFor(String type) =>
      MockData.emergencyPlaces.where((p) => p.type == type).toList();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'chat',
            backgroundColor: AppColors.royalBlue,
            onPressed: () {},
            icon: const Icon(Icons.chat_rounded),
            label: Text(isArabic ? 'دعم' : 'Support'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'sos',
            backgroundColor: AppColors.softRed,
            onPressed: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sos_rounded, size: 28),
                Text(
                  AppStrings.get('sos', isArabic),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppStrings.get('emergency', isArabic)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.softRed,
                      Color(0xFFB84343),
                      AppColors.warmBrown,
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      Icons.shield_rounded,
                      size: 80,
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
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.softRed.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: AppColors.softRed,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic
                                    ? 'المساعدة الطارئة'
                                    : 'Emergency Assistance',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                isArabic
                                    ? 'خدمات قريبة من موقعك'
                                    : 'Services near your location',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: AppStrings.get('callEmergency', isArabic),
                            icon: Icons.phone_in_talk_rounded,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.softRed,
                                AppColors.softRed.withValues(alpha: 0.8),
                              ],
                            ),
                            height: 48,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GradientButton(
                            label: AppStrings.get('callPolice', isArabic),
                            icon: Icons.local_police_rounded,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.darkCharcoal,
                                AppColors.warmBrown,
                              ],
                            ),
                            height: 48,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.sandBeige.withValues(alpha: 0.4),
                        AppColors.ivoryWhite,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: _MapGridPainter(),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map_rounded,
                              size: 40,
                              color: AppColors.desertGold.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isArabic ? 'خريطة تفاعلية' : 'Interactive Map',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 60,
                        left: 100,
                        child: _MapPin(color: AppColors.softRed),
                      ),
                      Positioned(
                        top: 80,
                        right: 80,
                        child: _MapPin(color: AppColors.emerald),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 140,
                        child: _MapPin(color: AppColors.royalBlue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ..._sections.expand((section) {
            final (type, titleEn, titleAr, icon, color) = section;
            final places = _placesFor(type);
            return [
              SliverToBoxAdapter(
                child: SectionHeader(title: isArabic ? titleAr : titleEn),
              ),
              if (places.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      isArabic ? 'لا توجد نتائج قريبة' : 'No nearby results',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _EmergencyPlaceCard(
                            place: places[index],
                            isArabic: isArabic,
                            icon: icon,
                            accentColor: color,
                          ),
                        );
                      },
                      childCount: places.length,
                    ),
                  ),
                ),
            ];
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _EmergencyPlaceCard extends StatelessWidget {
  const _EmergencyPlaceCard({
    required this.place,
    required this.isArabic,
    required this.icon,
    required this.accentColor,
  });

  final EmergencyPlace place;
  final bool isArabic;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? place.nameAr : place.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.near_me_rounded,
                      size: 14,
                      color: AppColors.desertGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place.distance,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.emerald,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(14),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.phone_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.warmBrown.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
