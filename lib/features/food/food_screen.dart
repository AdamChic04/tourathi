import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_provider.dart';
import '../../data/food/food_discovery_catalog.dart';
import '../../data/mock/jordan_place_seed.dart';
import '../../data/models/models.dart';

/// Taste of Jordan: cuisine inspiration and discovery of the existing
/// market, village, farm and craft destinations from the 61-place catalog.
///
/// The destination records are not verified restaurant or dining listings.
/// No unverified meals, fees, reservations or opening hours are advertised.
class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  String? _governorate;
  FoodExperienceKind? _kind;

  static const _arabicRegions = <String, String>{
    'Amman': 'عمّان',
    'Balqa': 'البلقاء',
    'Jerash': 'جرش',
    'Ajloun': 'عجلون',
    'Madaba': 'مادبا',
    'Ma’an': 'معان',
  };

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _reset() {
    _search.clear();
    setState(() {
      _governorate = null;
      _kind = null;
    });
  }

  void _jumpToDiscover() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      610,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final ar = app.isArabic;
    final palette = _FoodPalette(Theme.of(context).brightness == Brightness.dark);
    final all = FoodDiscoveryCatalog.experiences(JordanPlaceSeed.places);
    final regions = FoodDiscoveryCatalog.governorates(all);
    final results = FoodDiscoveryCatalog.filter(
      places: JordanPlaceSeed.places,
      query: _search.text,
      governorate: _governorate,
      kind: _kind,
    );

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1160),
            child: CustomScrollView(
              key: const Key('food_scroll'),
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: palette.accent.withValues(alpha: .13),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(Icons.restaurant_menu_rounded,
                                  color: palette.accent, size: 25),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ar ? 'المطبخ والثقافة' : 'FOOD & CULTURE',
                                    style: TextStyle(
                                      color: palette.accent,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: ar ? 0 : 2.2,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    ar ? 'تذوّق الأردن' : 'Taste of Jordan',
                                    key: const Key('food_page_title'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 27,
                                      color: palette.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 7),
                              decoration: BoxDecoration(
                                color: palette.card,
                                border: Border.all(color: palette.border),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                ar ? '${all.length} تجارب' : '${all.length} experiences',
                                key: const Key('food_total_count'),
                                style: TextStyle(
                                  color: palette.ink,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: SizedBox(
                            key: const Key('food_hero'),
                            height: 238,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/places/amman-al-balad-markets.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const ColoredBox(
                                    color: Color(0xFF71523F),
                                    child: Center(
                                      child: Icon(Icons.storefront_rounded,
                                          color: Colors.white70, size: 74),
                                    ),
                                  ),
                                ),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xDE201811),
                                        Color(0x96201811),
                                        Color(0x30201811),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(22),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        ar ? 'من أسواقنا إلى موائدنا' :
                                            'FROM MARKETS TO MEMORIES',
                                        style: const TextStyle(
                                          color: Color(0xFFF7D5A8),
                                          letterSpacing: 1.1,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        ar ? 'اكتشف نكهات\nالأردن' :
                                            'Explore the flavors\nof Jordan',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 29,
                                          fontWeight: FontWeight.w900,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      FilledButton.icon(
                                        key: const Key('food_hero_discover'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(0xFFF3D09C),
                                          foregroundColor: const Color(0xFF352314),
                                        ),
                                        onPressed: _jumpToDiscover,
                                        icon: const Icon(Icons.arrow_downward_rounded,
                                            size: 17),
                                        label: Text(ar ? 'استكشف التجارب' :
                                            'Explore experiences'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _SectionTitle(
                          title: ar ? 'أطباق أردنية شهيرة' : 'Flavors worth trying',
                          caption: ar
                              ? 'تعرّف على أطباق محبوبة في الأردن'
                              : 'A quick introduction to dishes enjoyed in Jordan',
                          palette: palette,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 187,
                          child: ListView.separated(
                            key: const Key('food_dishes_list'),
                            scrollDirection: Axis.horizontal,
                            itemCount: FoodDiscoveryCatalog.dishes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 11),
                            itemBuilder: (context, index) => _DishCard(
                              dish: FoodDiscoveryCatalog.dishes[index],
                              ar: ar,
                              palette: palette,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _SectionTitle(
                          title: ar ? 'أسواق وتجارب محلية' :
                              'Markets & local experiences',
                          caption: ar
                              ? 'اكتشف وجهات من قائمة تراثي'
                              : 'Discover experiences from the TouRathi catalog',
                          palette: palette,
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          key: const Key('food_search'),
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.search,
                          style: TextStyle(color: palette.ink),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded,
                                color: palette.accent),
                            hintText: ar ? 'ابحث عن الأسواق أو القرى أو الحرف...' :
                                'Search markets, villages or workshops...',
                            hintStyle: TextStyle(
                              color: palette.muted, fontSize: 13),
                            filled: true,
                            fillColor: palette.card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: palette.border)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: palette.border)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: palette.accent,
                                  width: 1.5)),
                            suffixIcon: _search.text.isEmpty ? null :
                                IconButton(
                                  tooltip: ar ? 'مسح البحث' : 'Clear search',
                                  onPressed: () => setState(_search.clear),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 43,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _KindChip(
                                label: ar ? 'الكل' : 'All',
                                selected: _kind == null,
                                palette: palette,
                                onTap: () => setState(() => _kind = null),
                                key: const Key('food_kind_all'),
                              ),
                              for (final kind in FoodExperienceKind.values)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 7),
                                  child: _KindChip(
                                    key: Key('food_kind_${kind.name}'),
                                    label: FoodDiscoveryCatalog.kindLabel(kind, ar),
                                    selected: _kind == kind,
                                    palette: palette,
                                    onTap: () => setState(() => _kind = kind),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                color: palette.accent, size: 19),
                            const SizedBox(width: 7),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                key: const Key('food_governorate'),
                                value: _governorate ?? '',
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: palette.card,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: BorderSide(color: palette.border)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: BorderSide(color: palette.border)),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: '',
                                    child: Text(ar ? 'كل المحافظات' :
                                        'All governorates'),
                                  ),
                                  for (final region in regions)
                                    DropdownMenuItem(
                                      value: region,
                                      child: Text(ar
                                          ? (_arabicRegions[region] ?? region)
                                          : region),
                                    ),
                                ],
                                onChanged: (value) => setState(() {
                                  _governorate =
                                      value == null || value.isEmpty
                                          ? null : value;
                                }),
                              ),
                            ),
                            if (_governorate != null ||
                                _kind != null || _search.text.isNotEmpty)
                              TextButton(
                                key: const Key('food_reset_filters'),
                                onPressed: _reset,
                                child: Text(ar ? 'مسح' : 'Reset'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ar ? '${results.length} وجهات متاحة للاستكشاف' :
                                    '${results.length} ${results.length == 1 ? 'place' : 'places'} to explore',
                                key: const Key('food_results_count'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: palette.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                if (results.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                      child: Container(
                        key: const Key('food_empty'),
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: palette.card,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(color: palette.border),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 41, color: palette.muted),
                            const SizedBox(height: 8),
                            Text(
                              ar ? 'لا توجد نتائج مطابقة' :
                                  'No matching experiences',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: palette.ink,
                              ),
                            ),
                            TextButton(
                              onPressed: _reset,
                              child: Text(ar ? 'عرض كل التجارب' :
                                  'Show all experiences'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;
                      final columns = width >= 870 ? 3 :
                          width >= 580 ? 2 : 1;
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final place = results[index];
                              return _FoodExperienceCard(
                                key: Key('food_place_${place.id}'),
                                place: place,
                                ar: ar,
                                palette: palette,
                                saved: app.isFavorite(place.id),
                                onFavorite: () =>
                                    context.read<AppProvider>()
                                        .toggleFavorite(place.id),
                                onOpen: () => context.push('/place/${place.id}'),
                              );
                            },
                            childCount: results.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            mainAxisExtent: 333,
                          ),
                        ),
                      );
                    },
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 42),
                    child: Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: palette.card,
                        border: Border.all(color: palette.border),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                            color: palette.accent, size: 19),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ar
                                  ? 'هذه قائمة للأسواق والتجارب الثقافية والريفية وليست دليلاً لمطاعم تم التحقق منها. لا تتوفر حجوزات أو أسعار أو أوقات طعام مؤكدة؛ تواصل مع الجهة المحلية قبل الزيارة.'
                                  : 'These are markets, villages and cultural experiences—not verified restaurants or bookable food tours. Confirm hosts, food availability, opening hours and prices before visiting.',
                              style: TextStyle(
                                color: palette.muted,
                                height: 1.45,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _FoodPalette {
  _FoodPalette(bool dark)
      : background = dark ? const Color(0xFF181714) : const Color(0xFFF8F7F4),
        card = dark ? const Color(0xFF292721) : Colors.white,
        ink = dark ? const Color(0xFFF8F2E9) : const Color(0xFF22221F),
        muted = dark ? const Color(0xFFAEA89F) : const Color(0xFF817D76),
        border = dark ? const Color(0xFF403D35) : const Color(0xFFE9E5DD),
        accent = dark ? const Color(0xFFE5B47A) : const Color(0xFF97623C);

  final Color background;
  final Color card;
  final Color ink;
  final Color muted;
  final Color border;
  final Color accent;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.caption,
    required this.palette,
  });

  final String title;
  final String caption;
  final _FoodPalette palette;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(
        fontSize: 21, fontWeight: FontWeight.w900, color: palette.ink)),
      const SizedBox(height: 5),
      Text(caption, style: TextStyle(
        fontSize: 12, height: 1.4, color: palette.muted)),
    ],
  );
}

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.dish,
    required this.ar,
    required this.palette,
  });

  final JordanianDish dish;
  final bool ar;
  final _FoodPalette palette;

  @override
  Widget build(BuildContext context) => Container(
    width: 184,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: palette.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: palette.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dish.symbol, style: const TextStyle(fontSize: 34)),
        const SizedBox(height: 10),
        Text(ar ? dish.nameAr : dish.name,
          style: TextStyle(
            color: palette.ink, fontWeight: FontWeight.w900, fontSize: 15)),
        const SizedBox(height: 6),
        Text(ar ? dish.descriptionAr : dish.description,
          maxLines: 3, overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.muted, fontSize: 11, height: 1.35)),
      ],
    ),
  );
}

class _KindChip extends StatelessWidget {
  const _KindChip({
    super.key,
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final _FoodPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    selectedColor: palette.accent.withValues(alpha: .19),
    backgroundColor: palette.card,
    side: BorderSide(
      color: selected ? palette.accent : palette.border),
    labelStyle: TextStyle(
      color: selected ? palette.accent : palette.ink,
      fontWeight: selected ? FontWeight.w800 : FontWeight.w500),
  );
}

class _FoodExperienceCard extends StatelessWidget {
  const _FoodExperienceCard({
    super.key,
    required this.place,
    required this.ar,
    required this.palette,
    required this.saved,
    required this.onFavorite,
    required this.onOpen,
  });

  final Place place;
  final bool ar;
  final _FoodPalette palette;
  final bool saved;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final kind = FoodDiscoveryCatalog.kindFor(place.id);
    final name = ar ? place.nameAr : place.name;
    final description = ar ? place.descriptionAr : place.description;

    return Material(
      color: palette.card,
      elevation: 0,
      borderRadius: BorderRadius.circular(19),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: palette.border),
            borderRadius: BorderRadius.circular(19),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 165,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      place.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: palette.accent.withValues(alpha: .2),
                        child: Icon(Icons.storefront_outlined,
                            color: palette.accent, size: 43),
                      ),
                    ),
                    PositionedDirectional(
                      top: 12,
                      start: 11,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xEAF9F4EC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          FoodDiscoveryCatalog.kindLabel(kind, ar),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF503B2B),
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 7,
                      end: 7,
                      child: Material(
                        color: const Color(0xEAF9F4EC),
                        shape: const CircleBorder(),
                        child: IconButton(
                          key: Key('food_favorite_${place.id}'),
                          tooltip: ar ? 'أضف للمفضلة' : 'Toggle favorite',
                          iconSize: 21,
                          onPressed: onFavorite,
                          icon: Icon(
                            saved ? Icons.favorite_rounded :
                                Icons.favorite_border_rounded,
                            color: saved ? const Color(0xFFD45D5D) :
                                const Color(0xFF503B2B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        )),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.muted,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16, color: palette.accent),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ar ? place.locationAr : place.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_rounded,
                              size: 19, color: palette.accent),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
