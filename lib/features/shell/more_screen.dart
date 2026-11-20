import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _sections = <_MoreSectionData>[
    _MoreSectionData('Plan your journey', 'خطط لرحلتك', [
      _MoreEntry(
        'My itineraries',
        'خططي المحفوظة',
        'Continue a saved trip',
        'تابع رحلة محفوظة',
        Icons.route_rounded,
        '/my-plans',
      ),
      _MoreEntry(
        'Plan together',
        'خططوا معاً',
        'Build a group itinerary',
        'أنشئوا خطة جماعية',
        Icons.auto_awesome_rounded,
        '/ai-group-planner',
      ),
      _MoreEntry(
        'Travel groups',
        'مجموعات السفر',
        'Find your travel community',
        'اعثر على مجتمع رحلتك',
        Icons.groups_rounded,
        '/travel-groups',
      ),
      _MoreEntry(
        'Travel journal',
        'مذكرات السفر',
        'Keep your memories and stories',
        'احتفظ بذكرياتك وقصصك',
        Icons.auto_stories_rounded,
        '/social-journal',
      ),
    ]),
    _MoreSectionData('Discover more', 'اكتشف المزيد', [
      _MoreEntry(
        'Food in Jordan',
        'الطعام في الأردن',
        'Local dishes and food experiences',
        'أطباق وتجارب طعام محلية',
        Icons.restaurant_menu_rounded,
        '/food',
      ),
      _MoreEntry(
        'Jordan marketplace',
        'سوق الأردن',
        'Shop from local makers',
        'تسوّق من صُنّاع محليين',
        Icons.storefront_rounded,
        '/marketplace',
      ),
      _MoreEntry(
        'Jordan passport',
        'جواز الأردن',
        'Collect digital destination stamps',
        'اجمع أختام الوجهات الرقمية',
        Icons.confirmation_number_rounded,
        '/jordan-passport',
      ),
      _MoreEntry(
        'Adventure rewards',
        'مكافآت المغامرة',
        'Collect rewards as you explore',
        'اجمع المكافآت أثناء الاستكشاف',
        Icons.stars_rounded,
        '/rewards',
      ),
    ]),
    _MoreSectionData('Experiences & help', 'التجارب والمساعدة', [
      _MoreEntry(
        'Explore in AR',
        'استكشف بالواقع المعزز',
        'Travel through place stories',
        'اكتشف حكايات الأماكن',
        Icons.view_in_ar_rounded,
        '/ar-hub',
      ),
      _MoreEntry(
        'Time traveler AI',
        'مسافر عبر الزمن',
        'Imagine Jordan through history',
        'تخيّل الأردن عبر التاريخ',
        Icons.auto_awesome_rounded,
        '/ai-image-generator',
      ),
      _MoreEntry(
        'Emergency & safety',
        'الطوارئ والسلامة',
        'Important numbers in Jordan',
        'أرقام مهمة في الأردن',
        Icons.health_and_safety_outlined,
        '/emergency',
      ),
    ]),
    _MoreSectionData('Account', 'الحساب', [
      _MoreEntry(
        'Profile and settings',
        'الملف الشخصي والإعدادات',
        'Manage your Tourathi account',
        'إدارة حساب تراثي',
        Icons.person_outline_rounded,
        '/profile',
      ),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final ar = context.watch<AppProvider>().isArabic;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF8F2E9) : const Color(0xFF28241F);
    final muted = dark ? const Color(0xFFB7AEA2) : const Color(0xFF81796D);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ar ? 'المزيد' : 'More',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 720 ? 3 : 2;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(21),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A4033), Color(0xFF28251F)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.explore_rounded,
                      color: Color(0xFFE4C98E),
                      size: 27,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ar
                                ? 'كل أدوات رحلتك'
                                : 'Your journey, all together',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ar
                                ? 'خطط، اكتشف، واحتفظ بذكريات الأردن.'
                                : 'Plan, explore, and keep your Jordan memories.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              for (final section in _sections) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 6),
                  child: Text(
                    ar ? section.titleAr : section.title,
                    style: TextStyle(
                      color: ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: section.items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 128,
                  ),
                  itemBuilder: (context, index) {
                    final entry = section.items[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.push(entry.route),
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.desertGold.withValues(
                                    alpha: .14,
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  entry.icon,
                                  color: AppColors.warmBrown,
                                  size: 19,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                ar ? entry.titleAr : entry.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                ar ? entry.detailAr : entry.detail,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 10.5,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 17),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MoreSectionData {
  const _MoreSectionData(this.title, this.titleAr, this.items);
  final String title, titleAr;
  final List<_MoreEntry> items;
}

class _MoreEntry {
  const _MoreEntry(
    this.title,
    this.titleAr,
    this.detail,
    this.detailAr,
    this.icon,
    this.route,
  );
  final String title, titleAr, detail, detailAr, route;
  final IconData icon;
}
