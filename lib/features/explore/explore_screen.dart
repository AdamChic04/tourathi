import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_provider.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';

/// Explore Jordan — a deliberately simple, photo-led discovery screen.
///
/// This version uses four *sample* destinations and bundled offline image
/// illustrations. When the places dataset arrives, replace the data source in
/// [_places] and the asset mapping without changing this view's layout.
const Map<String, String> _localImages = {
  'petra': 'assets/images/home/petra.jpg',
  'jerash': 'assets/images/home/jerash.jpg',
  'wadi-rum': 'assets/images/home/wadi_rum.jpg',
  'dead-sea': 'assets/images/home/dead_sea.jpg',
};

const _categoryKeys = ['all', 'heritage', 'adventure', 'nature'];

enum _ExploreSort { featured, name }
enum _ExploreView { grid, overview }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _category = 'all';
  bool _savedOnly = false;
  _ExploreSort _sort = _ExploreSort.featured;
  _ExploreView _view = _ExploreView.grid;

  List<Place> get _places => MockData.popularPlaces
      .where((place) => _localImages.containsKey(place.id))
      .toList(growable: false);

  String _categoryOf(String id) {
    switch (id) {
      case 'petra':
      case 'jerash':
        return 'heritage';
      case 'wadi-rum':
        return 'adventure';
      case 'dead-sea':
        return 'nature';
      default:
        return 'all';
    }
  }

  List<Place> _filtered(List<Place> source, AppProvider provider) {
    final text = _searchController.text.trim().toLowerCase();
    final results = source.where((place) {
      final categoryMatch = _category == 'all' ||
          _categoryOf(place.id) == _category;
      final savedMatch = !_savedOnly || provider.isFavorite(place.id);
      final queryMatch = text.isEmpty ||
          [
            place.name,
            place.nameAr,
            place.description,
            place.descriptionAr,
            place.location,
            place.locationAr,
          ].any((value) => value.toLowerCase().contains(text));
      return categoryMatch && savedMatch && queryMatch;
    }).toList();
    if (_sort == _ExploreSort.name) {
      results.sort((a, b) => a.name.compareTo(b.name));
    }
    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _category = 'all';
      _savedOnly = false;
      _sort = _ExploreSort.featured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final ar = provider.isArabic;
    final palette = _ExplorePalette(Theme.of(context).brightness == Brightness.dark);
    final results = _filtered(_places, provider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('explore_scroll'),
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 38),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 21, 22, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: palette.accent.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.travel_explore_rounded,
                        color: palette.accent, size: 23),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ar ? 'استكشف الأردن' : 'Explore Jordan',
                          style: TextStyle(
                            fontSize: 23,
                            height: 1.2,
                            letterSpacing: -.7,
                            fontWeight: FontWeight.w800,
                            color: palette.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ar ? 'أماكن تستحق الاكتشاف' : 'Find somewhere unforgettable',
                          style: TextStyle(fontSize: 12.5, color: palette.muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('explore_saved_filter'),
                    tooltip: ar ? 'المفضلة فقط' : 'Saved places only',
                    onPressed: () => setState(() => _savedOnly = !_savedOnly),
                    style: IconButton.styleFrom(
                      backgroundColor: _savedOnly
                          ? palette.accent.withValues(alpha: .13)
                          : palette.card,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: Icon(
                      _savedOnly ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      color: _savedOnly ? palette.accent : palette.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 17),
                    Icon(Icons.search_rounded, color: palette.accent, size: 23),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        key: const Key('explore_search'),
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        style: TextStyle(color: palette.ink, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: ar ? 'ابحث عن مكان أو مدينة' : 'Search a place or city',
                          hintStyle: TextStyle(color: palette.muted, fontSize: 14),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          filled: false,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        tooltip: ar ? 'مسح البحث' : 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: Icon(Icons.close_rounded,
                            color: palette.muted, size: 19),
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                itemCount: _categoryKeys.length,
                separatorBuilder: (_, __) => const SizedBox(width: 9),
                itemBuilder: (context, index) {
                  final key = _categoryKeys[index];
                  final selected = _category == key;
                  final label = _categoryLabel(key, ar);
                  return Material(
                    color: selected ? palette.accent : palette.card,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      key: Key('explore_category_$key'),
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => setState(() => _category = key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: selected ? palette.accent : palette.border,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: selected ? Colors.white : palette.ink,
                            fontSize: 12.5,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ar ? 'أماكن تستحق الزيارة' : 'Places to discover',
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 19,
                            letterSpacing: -.45,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ar ? '${results.length} وجهات تجريبية' : '${results.length} sample destinations',
                          style: TextStyle(color: palette.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_ExploreSort>(
                    key: const Key('explore_sort'),
                    tooltip: ar ? 'ترتيب الأماكن' : 'Sort places',
                    onSelected: (value) => setState(() => _sort = value),
                    color: palette.card,
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _ExploreSort.featured,
                        child: Text(ar ? 'مميزة' : 'Featured',
                            style: TextStyle(color: palette.ink)),
                      ),
                      PopupMenuItem(
                        value: _ExploreSort.name,
                        child: Text(ar ? 'بالاسم' : 'Name A–Z',
                            style: TextStyle(color: palette.ink)),
                      ),
                    ],
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: palette.card,
                        border: Border.all(color: palette.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 16, color: palette.accent),
                          const SizedBox(width: 5),
                          Text(ar ? 'ترتيب' : 'Sort',
                              style: TextStyle(color: palette.ink,
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  _ViewOption(
                    key: const Key('explore_grid_view'),
                    icon: Icons.grid_view_rounded,
                    label: ar ? 'الأماكن' : 'Places',
                    selected: _view == _ExploreView.grid,
                    palette: palette,
                    onTap: () => setState(() => _view = _ExploreView.grid),
                  ),
                  const SizedBox(width: 10),
                  _ViewOption(
                    key: const Key('explore_map_view'),
                    icon: Icons.map_outlined,
                    label: ar ? 'نظرة على الخريطة' : 'Map overview',
                    selected: _view == _ExploreView.overview,
                    palette: palette,
                    onTap: () => setState(() => _view = _ExploreView.overview),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19),
            if (results.isEmpty)
              _EmptyPlaces(
                isArabic: ar,
                palette: palette,
                onReset: _resetFilters,
              )
            else if (_view == _ExploreView.grid)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: LayoutBuilder(
                  builder: (context, constraints) => GridView.builder(
                    key: const Key('explore_place_grid'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: results.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                      mainAxisExtent: 255,
                      mainAxisSpacing: 13,
                      crossAxisSpacing: 13,
                    ),
                    itemBuilder: (context, i) {
                      final place = results[i];
                      return _ExplorePlaceCard(
                        key: Key('explore_place_${place.id}'),
                        place: place,
                        photo: _localImages[place.id]!,
                        category: _categoryLabel(_categoryOf(place.id), ar),
                        palette: palette,
                        isArabic: ar,
                        saved: provider.isFavorite(place.id),
                        onFavorite: () => context.read<AppProvider>()
                            .toggleFavorite(place.id),
                        onTap: () => context.push('/place/${place.id}'),
                      );
                    },
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: _IllustrativeMap(
                  places: results,
                  ar: ar,
                  palette: palette,
                  onPlace: (place) => context.push('/place/${place.id}'),
                ),
              ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Material(
                color: palette.card,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  key: const Key('explore_ai_planner'),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/ai-planner'),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 51,
                          height: 51,
                          decoration: BoxDecoration(
                            color: palette.accent.withValues(alpha: .11),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.auto_awesome_rounded,
                              color: palette.accent, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ar ? 'خطط رحلتك' : 'Make it a journey',
                                style: TextStyle(
                                  color: palette.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                ar ? 'رتب وجهاتك بمساعدة الذكاء الاصطناعي'
                                    : 'Plan an itinerary with AI',
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
          ],
        ),
      ),
    );
  }
}

String _categoryLabel(String key, bool isArabic) {
  switch (key) {
    case 'all':
      return isArabic ? 'الكل' : 'All';
    case 'heritage':
      return isArabic ? 'التراث' : 'Heritage';
    case 'nature':
      return isArabic ? 'الطبيعة' : 'Nature';
    case 'adventure':
      return isArabic ? 'المغامرة' : 'Adventure';
    default:
      return key;
  }
}

class _ExplorePalette {
  _ExplorePalette(bool dark)
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

class _ViewOption extends StatelessWidget {
  const _ViewOption({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final _ExplorePalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? palette.accent.withValues(alpha: .1) : palette.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? palette.accent.withValues(alpha: .5)
                    : palette.border,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17,
                    color: selected ? palette.accent : palette.muted),
                const SizedBox(width: 7),
                Text(label,
                    style: TextStyle(
                      color: selected ? palette.accent : palette.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
        ),
      );
}

class _ExplorePlaceCard extends StatelessWidget {
  const _ExplorePlaceCard({
    super.key,
    required this.place,
    required this.photo,
    required this.category,
    required this.palette,
    required this.isArabic,
    required this.saved,
    required this.onFavorite,
    required this.onTap,
  });

  final Place place;
  final String photo;
  final String category;
  final _ExplorePalette palette;
  final bool isArabic;
  final bool saved;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: palette.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 165,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(photo, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: palette.accent.withValues(alpha: .12),
                            child: Icon(Icons.landscape_rounded,
                                color: palette.accent, size: 45),
                          )),
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Material(
                          color: Colors.white.withValues(alpha: .96),
                          shape: const CircleBorder(),
                          child: IconButton(
                            key: Key('explore_favorite_${place.id}'),
                            tooltip: saved
                                ? (isArabic ? 'إزالة من المفضلة' : 'Remove from saved')
                                : (isArabic ? 'حفظ المكان' : 'Save place'),
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                            padding: const EdgeInsets.all(7),
                            iconSize: 19,
                            onPressed: onFavorite,
                            icon: Icon(saved ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                                color: saved ? const Color(0xFFB65B4B)
                                    : const Color(0xFF5B524B)),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .52),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(category,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 11, 8, 0),
                  child: Text(
                    isArabic ? place.nameAr : place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.ink, fontSize: 15,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 8, 0),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13, color: palette.accent),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          isArabic ? place.locationAr : place.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: palette.muted, fontSize: 11),
                        ),
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

class _EmptyPlaces extends StatelessWidget {
  const _EmptyPlaces({
    required this.isArabic,
    required this.palette,
    required this.onReset,
  });

  final bool isArabic;
  final _ExplorePalette palette;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
        child: Column(
          children: [
            Icon(Icons.travel_explore_outlined, size: 48, color: palette.muted),
            const SizedBox(height: 12),
            Text(isArabic ? 'لا توجد نتائج' : 'No places found',
                style: TextStyle(color: palette.ink, fontSize: 17,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(isArabic ? 'جرّب بحثاً أو تصنيفاً آخر'
                    : 'Try a different search or category',
                style: TextStyle(color: palette.muted, fontSize: 13)),
            TextButton(
              key: const Key('explore_reset'),
              onPressed: onReset,
              child: Text(isArabic ? 'إعادة تعيين' : 'Reset filters',
                  style: TextStyle(color: palette.accent)),
            ),
          ],
        ),
      );
}

/// A *schematic* location overview using approximate geographical coordinates.
/// Not a road map or live Mapbox rendering; no invented routes or travel times.
class _IllustrativeMap extends StatelessWidget {
  const _IllustrativeMap({
    required this.places,
    required this.ar,
    required this.palette,
    required this.onPlace,
  });

  final List<Place> places;
  final bool ar;
  final _ExplorePalette palette;
  final ValueChanged<Place> onPlace;

  // Approximate positions, only to orient the demo; validated map data later.
  static const coordinates = <String, (double, double)>{
    'petra': (30.3285, 35.4444),
    'jerash': (32.2747, 35.8912),
    'wadi-rum': (29.5761, 35.4197),
    'dead-sea': (31.56, 35.48),
  };

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE5DECC),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 350,
              child: LayoutBuilder(
                builder: (context, area) => ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(21)),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _MapTerrainPainter()),
                      ),
                      Positioned(
                        top: 16, left: 16,
                        child: Text(ar ? 'الأردن' : 'JORDAN',
                          style: const TextStyle(color: Color(0xFF8C765D),
                              letterSpacing: 2.5, fontSize: 11,
                              fontWeight: FontWeight.w900)),
                      ),
                      ...places.map((place) {
                        final position = coordinates[place.id];
                        if (position == null) return const SizedBox.shrink();
                        // Normalized longitude/latitude within a Jordan view box.
                        final x = .17 + ((position.$2 - 35.3) / 1.0) * .60;
                        final y = .13 + ((32.7 - position.$1) / 3.5) * .73;
                        return Positioned(
                          left: (area.maxWidth * x - 46).clamp(0,
                              (area.maxWidth - 92).clamp(0.0, double.infinity)).toDouble(),
                          top: (area.maxHeight * y - 25).clamp(0,
                              (area.maxHeight - 66).clamp(0.0, double.infinity)).toDouble(),
                          child: GestureDetector(
                            key: Key('explore_map_pin_${place.id}'),
                            onTap: () => onPlace(place),
                            child: Column(
                              children: [
                                Container(
                                  width: 34, height: 34,
                                  decoration: BoxDecoration(
                                    color: palette.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: const [BoxShadow(
                                      color: Color(0x33000000), blurRadius: 10,
                                      offset: Offset(0, 4))],
                                  ),
                                  child: const Icon(Icons.place,
                                      color: Colors.white, size: 18),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 92),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBF9F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(ar ? place.nameAr : place.name,
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.w800,
                                        fontSize: 10.5, color: Color(0xFF3D342C))),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 17, color: palette.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ar ? 'عرض توضيحي تقريبي — سنضيف Mapbox لاحقاً'
                          : 'Illustrative overview · Mapbox integration later',
                      style: TextStyle(color: palette.muted, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _MapTerrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final faint = Paint()
      ..color = const Color(0x40FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < 8; i++) {
      final startY = i * size.height / 7;
      final path = Path()
        ..moveTo(-10, startY)
        ..cubicTo(size.width * .3, startY - 42,
            size.width * .65, startY + 55, size.width + 20, startY - 15);
      canvas.drawPath(path, faint);
    }
    final lake = Paint()..color = const Color(0x336CA4B3);
    canvas.drawOval(Rect.fromLTWH(size.width * .18,
        size.height * .28, size.width * .12, size.height * .23), lake);
    final tracks = Paint()
      ..color = const Color(0x559B856C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(size.width * .8, -10)
      ..cubicTo(size.width * .35, size.height * .25,
          size.width * .7, size.height * .61,
          size.width * .34, size.height + 20);
    canvas.drawPath(path, tracks);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
