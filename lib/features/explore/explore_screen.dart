import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/app_provider.dart';
import '../../data/mock/jordan_place_seed.dart';
import '../../data/services/place_map_links.dart';
import '../../data/models/models.dart';

/// Explore Jordan — a deliberately simple, photo-led discovery screen.
///
/// The 61-place catalog is loaded from Supabase after sign-in; the same
/// 61-place list and licensed local images remain available offline.
const _categoryKeys = [
  'all', 'heritage', 'museums', 'religious', 'hiking', 'adventure', 'food',
];

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

  List<Place> get _places => JordanPlaceSeed.places;

  String _categoryOf(Place place) => place.category;

  List<Place> _filtered(List<Place> source, AppProvider provider) {
    final text = _searchController.text.trim().toLowerCase();
    final results = source.where((place) {
      final categoryMatch = _category == 'all' ||
          _categoryOf(place) == _category;
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

  Future<void> _openLocation(Place place) async {
    try {
      final opened = await launchUrl(
        PlaceMapLinks.search(place),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    }
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
                          ar ? '${results.length} وجهة من الأردن' : '${results.length} Jordan destinations',
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
                    label: ar ? 'المواقع' : 'Locations',
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
                        photo: place.imageUrl,
                        category: _categoryLabel(_categoryOf(place), ar),
                        palette: palette,
                        isArabic: ar,
                        saved: provider.isFavorite(place.id),
                        onFavorite: () => context.read<AppProvider>()
                            .toggleFavorite(place.id),
                        onMap: () => _openLocation(place),
                        onTap: () => context.push('/place/${place.id}'),
                      );
                    },
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: _DestinationLocations(
                  places: results,
                  ar: ar,
                  palette: palette,
                  onPlace: (place) => context.push('/place/${place.id}'),
                  onMap: _openLocation,
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
    case 'museums':
      return isArabic ? 'المتاحف' : 'Museums';
    case 'religious':
      return isArabic ? 'الدينية' : 'Religious';
    case 'hiking':
      return isArabic ? 'المشي والطبيعة' : 'Nature & Hiking';
    case 'food':
      return isArabic ? 'الطعام والحرف' : 'Food & Crafts';
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
    required this.onMap,
    required this.onTap,
  });

  final Place place;
  final String photo;
  final String category;
  final _ExplorePalette palette;
  final bool isArabic;
  final bool saved;
  final VoidCallback onFavorite;
  final VoidCallback onMap;
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
                        left: 9,
                        child: Material(
                          color: Colors.white.withValues(alpha: .96),
                          shape: const CircleBorder(),
                          child: IconButton(
                            key: Key('explore_map_${place.id}'),
                            tooltip: isArabic ? 'فتح خرائط Google' : 'Open Google Maps',
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: const EdgeInsets.all(7),
                            iconSize: 19,
                            onPressed: onMap,
                            icon: const Icon(Icons.map_outlined, color: Color(0xFF5B524B)),
                          ),
                        ),
                      ),
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


/// Location directory for all selected destinations.
///
/// This replaces the former illustrative map with outdated IDs. Each entry
/// opens a real Google Maps search, or a government-sourced site point when
/// available; names and images remain visible without a map service.
class _DestinationLocations extends StatelessWidget {
  const _DestinationLocations({
    required this.places,
    required this.ar,
    required this.palette,
    required this.onPlace,
    required this.onMap,
  });

  final List<Place> places;
  final bool ar;
  final _ExplorePalette palette;
  final ValueChanged<Place> onPlace;
  final ValueChanged<Place> onMap;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Place>>{};
    for (final place in places) {
      final governorate = place.location.split(' Governorate').first.trim();
      groups.putIfAbsent(governorate, () => <Place>[]).add(place);
    }
    final regions = groups.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: palette.accent.withValues(alpha: .09),
            border: Border.all(color: palette.accent.withValues(alpha: .20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ar
                    ? '${places.length} موقعاً في ${regions.length} محافظات'
                    : '${places.length} locations across ${regions.length} governorates',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ar
                    ? 'اضغط رمز الخريطة لفتح الموقع في خرائط Google. بعض الأماكن لا تملك إحداثيات مدخل موثقة؛ تحقق من النتيجة قبل السفر.'
                    : 'Tap the map icon to open Google Maps. Many places lack verified entrance coordinates, so check the search result before traveling.',
                style: TextStyle(
                  color: palette.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final region in regions) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(3, 10, 3, 10),
            child: Row(
              children: [
                Icon(Icons.place_outlined, color: palette.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    region,
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text('${groups[region]!.length}',
                    style: TextStyle(color: palette.muted)),
              ],
            ),
          ),
          for (final place in groups[region]!)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Material(
                color: palette.card,
                borderRadius: BorderRadius.circular(15),
                child: ListTile(
                  key: Key('location_item_${place.id}'),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: palette.border),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 54,
                      width: 60,
                      child: Image.asset(
                        place.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: palette.accent.withValues(alpha: .14),
                          child: Icon(
                            Icons.landscape_outlined,
                            color: palette.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    ar ? place.nameAr : place.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    ar ? place.locationAr : place.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.muted, fontSize: 11),
                  ),
                  trailing: IconButton(
                    key: Key('location_map_${place.id}'),
                    tooltip: ar ? 'البحث في خرائط Google' : 'Find on Google Maps',
                    onPressed: () => onMap(place),
                    icon: Icon(Icons.map_outlined, color: palette.accent),
                  ),
                  onTap: () => onPlace(place),
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
