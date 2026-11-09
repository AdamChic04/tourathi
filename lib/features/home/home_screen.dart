import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_provider.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';

/// TouRathi — streamlined Home screen.
/// All four assets are bundled in pubspec.yaml and work offline.
/// These are AI-generated demo illustrations, not verified site photographs.
const Map<String, String> _photos = {
  'petra': 'assets/images/home/petra.jpg',
  'jerash': 'assets/images/home/jerash.jpg',
  'wadi-rum': 'assets/images/home/wadi_rum.jpg',
  'dead-sea': 'assets/images/home/dead_sea.jpg',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onSelectTab});

  /// MainShell owns the tab navigation. Home never pushes a nonexistent route.
  final ValueChanged<int>? onSelectTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _carouselController;
  Timer? _slideTimer;
  int _slide = 0;

  List<Place> get _places => MockData.popularPlaces
      .where((place) => _photos.containsKey(place.id))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
    _slideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_carouselController.hasClients || _places.isEmpty) {
        return;
      }
      final next = (_slide + 1) % _places.length;
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

  void _toggleFavorite(String id) =>
      context.read<AppProvider>().toggleFavorite(id);

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<AppProvider>().isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _HomePalette(isDark);
    final places = _places;

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
                    child: Icon(Icons.explore_rounded, color: palette.accent, size: 25),
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
                        child: Icon(Icons.person_outline_rounded, color: palette.ink, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'اكتشف جمال الأردن' : 'DISCOVER JORDAN',
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
                  const SizedBox(height: 17),
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
                            Icon(Icons.search_rounded, color: palette.muted, size: 23),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isArabic ? 'ابحث عن وجهة...' : 'Search for a destination...',
                                style: TextStyle(color: palette.muted, fontSize: 14),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, color: palette.muted, size: 13),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isArabic ? 'وجهات تستحق الزيارة' : 'Featured places',
                      style: TextStyle(color: palette.ink, fontSize: 19, fontWeight: FontWeight.w800),
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
                itemCount: places.length,
                onPageChanged: (index) => setState(() => _slide = index),
                itemBuilder: (context, index) {
                  final place = places[index];
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
              children: List.generate(places.length, (index) {
                final active = _slide == index;
                return GestureDetector(
                  key: Key('home_dot_$index'),
                  onTap: () => _carouselController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  ),
                  child: Container(
                    width: active ? 23 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: active ? palette.accent : palette.muted.withValues(alpha: .27),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
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
                          child: Icon(Icons.auto_awesome_rounded, color: palette.accent, size: 25),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'خطط رحلتك بالذكاء الاصطناعي' : 'Plan your perfect trip',
                                style: TextStyle(color: palette.ink, fontWeight: FontWeight.w800, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isArabic ? 'دع الذكاء الاصطناعي يقترح رحلتك' : 'A personal itinerary, made for you',
                                style: TextStyle(color: palette.muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded, color: palette.accent),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 29),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isArabic ? 'أماكن مميزة' : 'Popular destinations',
                      style: TextStyle(color: palette.ink, fontWeight: FontWeight.w800, fontSize: 19),
                    ),
                  ),
                  TextButton(
                    key: const Key('home_see_all_button'),
                    onPressed: _explore,
                    child: Text(
                      isArabic ? 'عرض الكل' : 'See all',
                      style: TextStyle(color: palette.accent, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 210,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                scrollDirection: Axis.horizontal,
                itemCount: places.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final place = places[index];
                  return _DestinationCard(
                    key: Key('home_place_${place.id}'),
                    place: place,
                    photo: _photos[place.id]!,
                    isArabic: isArabic,
                    palette: palette,
                    saved: context.watch<AppProvider>().isFavorite(place.id),
                    onTap: () => _viewPlace(place),
                    onFavorite: () => _toggleFavorite(place.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: _SmallShortcut(
                      label: isArabic ? 'استكشف بالواقع المعزز' : 'Explore in AR',
                      icon: Icons.view_in_ar_rounded,
                      palette: palette,
                      onTap: () => context.push('/ar-hub'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SmallShortcut(
                      label: isArabic ? 'مذكرات السفر' : 'Travel journal',
                      icon: Icons.auto_stories_outlined,
                      palette: palette,
                      onTap: () => context.push('/social-journal'),
                    ),
                  ),
                ],
              ),
            ),
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
              Image.asset(photo, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, .45, 1],
                    colors: [Color(0x30000000), Color(0x08000000), Color(0xE9000000)],
                  ),
                ),
              ),
              Positioned(
                top: 17,
                left: 17,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: .24)),
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
                        const Icon(Icons.place_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          isArabic ? place.locationAr : place.location,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_outward_rounded, color: Color(0xFF2D2925)),
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

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    super.key,
    required this.place,
    required this.photo,
    required this.isArabic,
    required this.palette,
    required this.saved,
    required this.onTap,
    required this.onFavorite,
  });

  final Place place;
  final String photo;
  final bool isArabic;
  final _HomePalette palette;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Material(
        color: palette.card,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(photo, fit: BoxFit.cover),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Material(
                            color: Colors.white.withValues(alpha: .94),
                            shape: const CircleBorder(),
                            child: InkWell(
                              key: Key('home_favorite_${place.id}'),
                              customBorder: const CircleBorder(),
                              onTap: onFavorite,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: saved ? const Color(0xFFD46161) : const Color(0xFF453B35),
                                  size: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? place.nameAr : place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: palette.ink, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: 12, color: palette.muted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              isArabic ? place.locationAr : place.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: palette.muted, fontSize: 11),
                            ),
                          ),
                          const Icon(Icons.star_rounded, color: Color(0xFFD9A047), size: 14),
                          const SizedBox(width: 3),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: TextStyle(color: palette.ink, fontSize: 11, fontWeight: FontWeight.w700),
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
      ),
    );
  }
}

class _SmallShortcut extends StatelessWidget {
  const _SmallShortcut({
    required this.label,
    required this.icon,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final _HomePalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: palette.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: palette.accent, size: 23),
              const SizedBox(height: 11),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: palette.ink, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
