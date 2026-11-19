import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_provider.dart';
import '../../data/mock/jordan_place_seed.dart';
import '../../data/models/models.dart';

/// TouRathi — streamlined Home screen.
/// Featured destinations use their bundled, attributed location photographs.
const Map<String, String> _photos = {
  'maan-petra': 'assets/images/places/maan-petra.jpg',
  'jerash-roman-city': 'assets/images/places/jerash-roman-city.jpg',
  'maan-wadi-rum': 'assets/images/places/maan-wadi-rum.jpg',
  'tafilah-dana': 'assets/images/places/tafilah-dana.jpg',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onSelectTab, this.onExploreCategory});

  /// MainShell owns the tab navigation. Home never pushes a nonexistent route.
  final ValueChanged<int>? onSelectTab;
  final ValueChanged<String>? onExploreCategory;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _carouselController;
  Timer? _slideTimer;
  int _slide = 0;

  /// Full catalog for the scrolling destination list.
  List<Place> get _places => JordanPlaceSeed.places;

  /// Keep the hero carousel curated without hiding the rest of Jordan.
  List<Place> get _featuredPlaces => JordanPlaceSeed.places
      .where((place) => _photos.containsKey(place.id))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
    _slideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted ||
          !_carouselController.hasClients ||
          _featuredPlaces.isEmpty) {
        return;
      }
      final next = (_slide + 1) % _featuredPlaces.length;
      _carouselController.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  void _explore() => widget.onSelectTab?.call(1);

  void _viewPlace(Place place) => context.push('/place/${place.id}');

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _HomePalette(isDark);
    final places = _places;
    final featuredPlaces = _featuredPlaces;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 34),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    decoration: BoxDecoration(
                      color: palette.accent.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.explore_rounded,
                      color: palette.accent,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'TouRathi',
                      style: TextStyle(
                        color: palette.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 21,
                        letterSpacing: -.7,
                      ),
                    ),
                  ),
                  Material(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      key: const Key('home_profile_button'),
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => context.push('/profile'),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: palette.ink,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'أهلاً بك في الأردن' : 'WELCOME TO JORDAN',
                    style: TextStyle(
                      color: palette.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: isArabic ? 0 : 2.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isArabic ? 'إلى أين رحلتك القادمة؟' : 'Where to next?',
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 31,
                      height: 1.15,
                      letterSpacing: -.9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Material(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      key: const Key('home_search_button'),
                      borderRadius: BorderRadius.circular(15),
                      onTap: _explore,
                      child: Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: palette.muted,
                              size: 23,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isArabic
                                    ? 'ابحث عن وجهة...'
                                    : 'Search for a destination...',
                                style: TextStyle(
                                  color: palette.muted,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: palette.muted,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isArabic ? 'وجهات تستحق الزيارة' : 'Featured places',
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    isArabic ? 'اسحب للاستكشاف' : 'Swipe to explore',
                    style: TextStyle(color: palette.muted, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            SizedBox(
              height: 300,
              child: PageView.builder(
                key: const Key('home_featured_carousel'),
                controller: _carouselController,
                itemCount: featuredPlaces.length,
                onPageChanged: (index) => setState(() => _slide = index),
                itemBuilder: (context, index) {
                  final place = featuredPlaces[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _HeroSlide(
                      place: place,
                      photo: _photos[place.id]!,
                      isArabic: isArabic,
                      onTap: () => _viewPlace(place),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(featuredPlaces.length, (index) {
                final active = _slide == index;
                return GestureDetector(
                  key: Key('home_dot_$index'),
                  onTap:
                      () => _carouselController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                      ),
                  child: Container(
                    width: active ? 23 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color:
                          active
                              ? palette.accent
                              : palette.muted.withValues(alpha: .27),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 38),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Material(
                color: palette.card,
                borderRadius: BorderRadius.circular(19),
                child: InkWell(
                  key: const Key('home_ai_planner_button'),
                  borderRadius: BorderRadius.circular(19),
                  onTap: () => context.push('/ai-planner'),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 51,
                          height: 51,
                          decoration: BoxDecoration(
                            color: palette.accent.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: palette.accent,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic
                                    ? 'خطط رحلتك بالذكاء الاصطناعي'
                                    : 'Plan your perfect trip',
                                style: TextStyle(
                                  color: palette.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isArabic
                                    ? 'دع الذكاء الاصطناعي يقترح رحلتك'
                                    : 'A personal itinerary, made for you',
                                style: TextStyle(
                                  color: palette.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: palette.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Material(
                color: const Color(0xFF3A3028),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  key: const Key('home_journal_button'),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/social-journal'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF594332), Color(0xFF342C25)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: Color(0xFFF2D8B8),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic
                                    ? 'مذكرات تراثي'
                                    : 'Your travel journal',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isArabic
                                    ? 'احفظ ذكرياتك وشارك قصتك'
                                    : 'Keep your memories, share your story',
                                style: const TextStyle(
                                  color: Color(0xFFD5C8B9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFFF2D8B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
            const SizedBox(height: 29),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic
                              ? 'استكشف حسب اهتمامك'
                              : 'Explore by interest',
                          style: TextStyle(
                            color: palette.ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic
                              ? 'اختر نوع التجربة التي تناسبك'
                              : 'Choose the kind of day you want',
                          style: TextStyle(color: palette.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    key: const Key('home_see_all_button'),
                    onPressed: _explore,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text(
                      isArabic ? 'كل الوجهات' : 'All places',
                      style: TextStyle(
                        color: palette.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 680 ? 4 : 2;
                  const categories =
                      <({String id, String en, String ar, IconData icon})>[
                        (
                          id: 'heritage',
                          en: 'Heritage',
                          ar: 'التراث',
                          icon: Icons.account_balance_rounded,
                        ),
                        (
                          id: 'hiking',
                          en: 'Nature',
                          ar: 'الطبيعة',
                          icon: Icons.park_rounded,
                        ),
                        (
                          id: 'adventure',
                          en: 'Adventure',
                          ar: 'المغامرة',
                          icon: Icons.landscape_rounded,
                        ),
                        (
                          id: 'food',
                          en: 'Food & crafts',
                          ar: 'الطعام والحرف',
                          icon: Icons.restaurant_rounded,
                        ),
                      ];
                  return GridView.builder(
                    key: const Key('home_interest_grid'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 11,
                      mainAxisSpacing: 11,
                      childAspectRatio: columns == 4 ? 1.35 : 1.48,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final matching = places.where(
                        (p) => p.category == category.id,
                      );
                      if (matching.isEmpty) return const SizedBox.shrink();
                      final place = matching.first;
                      final count = matching.length;
                      return _InterestCard(
                        key: Key('home_interest_${category.id}'),
                        title: isArabic ? category.ar : category.en,
                        subtitle: isArabic ? '$count أماكن' : '$count places',
                        photo: place.imageUrl,
                        icon: category.icon,
                        onTap: () {
                          final selectCategory = widget.onExploreCategory;
                          if (selectCategory == null) {
                            _explore();
                          } else {
                            selectCategory(category.id);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _HomePalette {
  _HomePalette(bool dark)
    : background = dark ? const Color(0xFF181714) : const Color(0xFFF8F7F4),
      card = dark ? const Color(0xFF292721) : Colors.white,
      ink = dark ? const Color(0xFFF8F2E9) : const Color(0xFF22221F),
      muted = dark ? const Color(0xFFAEA89F) : const Color(0xFF89867F),
      border = dark ? const Color(0xFF403D35) : const Color(0xFFEBE9E2),
      accent = dark ? const Color(0xFFD9A67D) : const Color(0xFF9B6548);

  final Color background;
  final Color card;
  final Color ink;
  final Color muted;
  final Color border;
  final Color accent;
}

class _InterestCard extends StatelessWidget {
  const _InterestCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.photo,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String photo;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Material(
      color: const Color(0xFF514335),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              photo,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => const ColoredBox(
                    color: Color(0xFF514335),
                    child: Icon(
                      Icons.landscape_rounded,
                      color: Colors.white54,
                      size: 34,
                    ),
                  ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x18000000), Color(0xD9000000)],
                ),
              ),
            ),
            Positioned(
              top: 11,
              right: 11,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
            ),
            Positioned(
              left: 13,
              right: 13,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
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

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({
    required this.place,
    required this.photo,
    required this.isArabic,
    required this.onTap,
  });

  final Place place;
  final String photo;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: Material(
        color: const Color(0xFF79543C),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                photo,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const ColoredBox(
                      color: Color(0xFF79543C),
                      child: Center(
                        child: Icon(
                          Icons.landscape_outlined,
                          color: Colors.white70,
                          size: 38,
                        ),
                      ),
                    ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, .45, 1],
                    colors: [
                      Color(0x30000000),
                      Color(0x08000000),
                      Color(0xE9000000),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 17,
                left: 17,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .24),
                    ),
                  ),
                  child: Text(
                    isArabic ? 'اكتشف الأردن' : 'JORDAN HIGHLIGHTS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 21,
                left: 21,
                right: 21,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isArabic ? place.locationAr : place.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isArabic ? place.nameAr : place.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isArabic ? 'ابدأ المغامرة' : 'Discover the story',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_outward_rounded,
                            color: Color(0xFF2D2925),
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
    );
  }
}
