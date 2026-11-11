import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/app_provider.dart';
import '../../data/content/destination_guides.dart';
import '../../data/media/place_photo_credits.dart';
import '../../data/mock/jordan_place_seed.dart';
import '../../data/models/models.dart';
import '../ai_planner/jordan_price_catalog.dart';
import '../ai_planner/jordan_visit_info.dart';

/// A source-conscious place guide. The main photo, names and category are
/// available offline. Ticket prices and seasonal hours are *references*, not
/// claims of live availability.
class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    Place? place;
    for (final item in JordanPlaceSeed.places) {
      if (item.id == placeId) {
        place = item;
        break;
      }
    }
    if (place == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('TouRathi')),
        body: Center(
          child: Text(app.isArabic ? 'المكان غير موجود' : 'Destination not found'),
        ),
      );
    }

    final p = place;
    final ar = app.isArabic;
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    final credit = PlacePhotoCredits.forId(p.id);
    final guide = DestinationGuides.forId(p.id);
    final visits = JordanVisitInfoCatalog.forPlace(p.id);
    final price = JordanPriceCatalog.forPlaceId(p.id);
    final name = ar ? p.nameAr : p.name;
    final location = ar ? p.locationAr : p.location;
    final text = ar
        ? (p.descriptionAr.startsWith('سجل استكشاف')
            ? guide?.ar ?? p.descriptionAr
            : p.descriptionAr)
        : (p.description.contains('discovery record')
            ? guide?.en ?? p.description
            : p.description);
    final region = p.location.split(',').first.trim();
    final sameGovernorate = JordanPlaceSeed.places
        .where((other) => other.id != p.id && other.location == p.location)
        .take(4)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 325,
            backgroundColor: const Color(0xFF5C422F),
            foregroundColor: Colors.white,
            surfaceTintColor: const Color(0xFF5C422F),
            title: const Text('TouRathi'),
            actions: [
              IconButton(
                key: const Key('detail_favorite'),
                tooltip: ar ? 'المفضلة' : 'Save destination',
                onPressed: () => context.read<AppProvider>().toggleFavorite(p.id),
                icon: Icon(app.isFavorite(p.id)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded),
                color: app.isFavorite(p.id)
                    ? const Color(0xFFFFC6C6)
                    : Colors.white,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                key: const Key('detail_photo_open'),
                onTap: () => _showFullScreenImage(context, p, credit, ar),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _PlacePhoto(asset: p.imageUrl),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x770C0905),
                            Colors.transparent,
                            Color(0xBF14100D),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      right: 22,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xB5211A15),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              credit?.isRepresentative == true
                                  ? (ar ? 'صورة من المنطقة' : 'Area photo')
                                  : (ar ? 'صورة واحدة متاحة' : '1 photo · tap to zoom'),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 30,
                              height: 1.1,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: [
                          _InfoChip(
                            icon: Icons.location_on_outlined,
                            label: location,
                            accent: accent,
                          ),
                          _InfoChip(
                            icon: Icons.local_offer_outlined,
                            label: _categoryLabel(p.category, ar),
                            accent: accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SectionHeading(
                        title: ar ? 'عن الوجهة' : 'About this place',
                        subtitle: ar ? 'لمحة تعريفية' : 'Destination overview',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.65,
                          color: scheme.onSurface.withValues(alpha: 0.86),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ar
                            ? 'المعلومات التعريفية أولية. تحقق من شروط الزيارة الحالية قبل السفر.'
                            : 'Overview is editorial. Confirm current visitor conditions before traveling.',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: 0.60),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _SectionHeading(
                        title: ar ? 'خطط زيارتك' : 'Plan your visit',
                        subtitle: ar
                            ? 'المعلومات الموثقة فقط'
                            : 'Source-based information only',
                      ),
                      const SizedBox(height: 12),
                      _DetailPanel(
                        icon: Icons.schedule_outlined,
                        title: ar ? 'ساعات الزيارة' : 'Visiting hours',
                        child: visits == null
                            ? Text(ar
                                ? 'لم تُتحقق ساعات الزيارة بعد. تواصل مع الجهة المسؤولة قبل الذهاب.'
                                : 'Hours have not been verified for this place. Check with the venue before visiting.')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(visits.hours,
                                    style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text(visits.season),
                                  const SizedBox(height: 6),
                                  Text(visits.conditions,
                                    style: Theme.of(context).textTheme.bodySmall),
                                  _ReferenceLink(
                                    label: ar ? 'المصدر الرسمي للساعات' : 'Official hours reference',
                                    url: visits.sourceUrl,
                                  ),
                                  Text('Checked ${visits.checkedAt}',
                                    style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),
                      _DetailPanel(
                        icon: Icons.confirmation_number_outlined,
                        title: ar ? 'الرسوم والتذاكر' : 'Tickets and prices',
                        child: price.confidence == PriceConfidence.notVerified
                            ? Text(ar
                                ? 'لا تتوفر أسعار دخول موثقة لهذا الموقع. تحقق من الجهة الرسمية.'
                                : 'No verified admission price is available for this destination.')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(price.label,
                                    style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text(
                                    price.confidence == PriceConfidence.officialFixed
                                        ? (ar ? 'مرجع رسوم منشور' : 'Published official fee reference')
                                        : (ar ? 'سعر مشغل أو تقدير منشور' : 'Provider rate or published estimate'),
                                    style: TextStyle(color: accent, fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  if (price.jordanian != null)
                                    _PriceLine(
                                      label: ar ? 'أردني' : 'Jordanian',
                                      amount: price.jordanian!),
                                  if (price.resident != null)
                                    _PriceLine(
                                      label: ar ? 'مقيم' : 'Resident',
                                      amount: price.resident!),
                                  if (price.international != null)
                                    _PriceLine(
                                      label: ar ? 'زائر دولي' : 'International',
                                      amount: price.international!),
                                  if (price.dayVisitor != null)
                                    _PriceLine(
                                      label: ar ? 'زائر ليوم واحد' : 'Same-day visitor',
                                      amount: price.dayVisitor!),
                                  if (price.low != null || price.high != null)
                                    Text(
                                      'JOD ${_money(price.low ?? price.high!)}'
                                      '${price.low != null && price.high != null && price.low != price.high ? '–${_money(price.high!)}' : ''}'
                                      ' · ${price.unit}',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  const SizedBox(height: 7),
                                  Text(price.conditions,
                                    style: Theme.of(context).textTheme.bodySmall),
                                  if (price.sourceUrl.isNotEmpty)
                                    _ReferenceLink(
                                      label: ar ? 'تحقق من مصدر السعر' : 'Check price source',
                                      url: price.sourceUrl,
                                    ),
                                  Text('Checked ${price.checkedAt}',
                                    style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),
                      _DetailPanel(
                        icon: Icons.map_outlined,
                        title: ar ? 'الموقع والخريطة' : 'Location and maps',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(location),
                            const SizedBox(height: 8),
                            Text(
                              ar
                                  ? 'يفتح الزر بحثاً باسم الوجهة في خرائط Google، وليس دبوساً بإحداثيات موثقة. تحقق من الموقع الصحيح.'
                                  : 'Maps opens a place-name search, not a verified GPS pin. Check the result before navigating.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              key: const Key('detail_map_search'),
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: Text(ar ? 'اعرض على الخريطة' : 'Find on Google Maps'),
                              onPressed: () => _openMaps(
                                  context, p, directions: false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      _SectionHeading(
                        title: ar ? 'الصورة وحقوقها' : 'Photo and attribution',
                        subtitle: ar ? 'صورة مرخصة قابلة للتكبير' : 'Licensed and zoomable',
                      ),
                      const SizedBox(height: 12),
                      if (credit != null)
                        _DetailPanel(
                          icon: Icons.photo_library_outlined,
                          title: credit.isRepresentative
                              ? (ar ? 'صورة تمثيلية للمنطقة' : 'Representative area photo')
                              : (ar ? 'صورة الوجهة' : 'Destination photo'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${credit.creator} · ${credit.license}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(credit.note,
                                style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 14,
                                children: [
                                  _ReferenceLink(
                                    label: ar ? 'الصورة الأصلية' : 'View source photo',
                                    url: credit.sourceUrl,
                                  ),
                                  _ReferenceLink(
                                    label: ar ? 'الترخيص' : 'License details',
                                    url: credit.licenseUrl,
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                key: const Key('detail_gallery_button'),
                                onPressed: () => _showFullScreenImage(
                                    context, p, credit, ar),
                                icon: const Icon(Icons.zoom_out_map_rounded),
                                label: Text(ar ? 'تكبير الصورة' : 'Open photo gallery'),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(ar
                            ? 'معلومات مصدر الصورة غير متوفرة.'
                            : 'Photo source information is unavailable.'),
                      if (sameGovernorate.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _SectionHeading(
                          title: ar
                              ? 'أماكن أخرى في نفس المحافظة'
                              : 'More in this governorate',
                          subtitle: ar ? 'اكتشف وجهات أخرى' : 'Keep exploring',
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 173,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: sameGovernorate.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final other = sameGovernorate[index];
                              return SizedBox(
                                width: 164,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () => context.push('/place/${other.id}'),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: SizedBox(
                                          height: 112,
                                          width: 164,
                                          child: _PlacePhoto(asset: other.imageUrl),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        ar ? other.nameAr : other.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(
              top: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.6)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('detail_directions'),
                  onPressed: () => _openMaps(context, p, directions: true),
                  icon: const Icon(Icons.directions_outlined),
                  label: Text(ar ? 'الاتجاهات' : 'Directions'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('detail_plan_trip'),
                  onPressed: () => context.push('/ai-planner'),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: Text(ar ? 'خطط للرحلة' : 'Plan a trip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _money(double value) =>
    value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);

String _categoryLabel(String category, bool ar) => switch (category) {
  'heritage' => ar ? 'تراث وآثار' : 'Heritage',
  'museums' => ar ? 'متاحف' : 'Museums',
  'food' => ar ? 'طعام وحرف' : 'Food & Crafts',
  'hiking' => ar ? 'طبيعة ومشي' : 'Nature & Hiking',
  'religious' => ar ? 'مواقع دينية' : 'Religious Heritage',
  'adventure' => ar ? 'مغامرات' : 'Adventure',
  _ => category,
};

Future<void> _openMaps(
    BuildContext context, Place place, {required bool directions}) async {
  // The dataset does NOT include verified GPS coordinates. Avoid false pins.
  final query = '${place.name}, Jordan';
  final url = directions
      ? Uri.https('www.google.com', '/maps/dir/',
          {'api': '1', 'destination': query})
      : Uri.https('www.google.com', '/maps/search/',
          {'api': '1', 'query': query});
  await _openExternal(context, url);
}

Future<void> _openExternal(BuildContext context, Uri uri) async {
  try {
    if (uri.scheme != 'https' ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link.')),
        );
      }
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }
}

void _showFullScreenImage(
    BuildContext context, Place place, PlacePhotoCredit? credit, bool ar) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(ar ? place.nameAr : place.name),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: _PlacePhoto(asset: place.imageUrl, fit: BoxFit.contain),
                  ),
                ),
              ),
              if (credit != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                  child: Column(
                    children: [
                      Text(
                        credit.isRepresentative
                            ? (ar ? 'صورة تمثيلية للمنطقة' : 'Representative area photograph')
                            : (ar ? 'صورة مرخصة' : 'Licensed photograph'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${credit.creator} · ${credit.license}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      TextButton(
                        onPressed: () => _openExternal(context, Uri.parse(credit.sourceUrl)),
                        child: Text(ar ? 'المصدر' : 'Image source'),
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

class _PlacePhoto extends StatelessWidget {
  const _PlacePhoto({required this.asset, this.fit = BoxFit.cover});
  final String asset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (asset.isEmpty) {
      return const ColoredBox(
        color: Color(0xFF795D47),
        child: Center(
          child: Icon(Icons.landscape_outlined, size: 46, color: Colors.white70),
        ),
      );
    }
    return Image.asset(
      asset,
      fit: fit,
      errorBuilder: (context, error, stack) => const ColoredBox(
        color: Color(0xFF795D47),
        child: Center(
          child: Icon(Icons.landscape_outlined, size: 46, color: Colors.white70),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          )),
        const SizedBox(height: 2),
        Text(subtitle,
          style: TextStyle(
            color: scheme.onSurface.withValues(alpha: .60),
            fontSize: 12)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon, required this.label, required this.accent});
  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.08),
      border: Border.all(color: accent.withValues(alpha: 0.18)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: accent, size: 17),
        const SizedBox(width: 6),
        Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.icon, required this.title, required this.child});
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 21, color: scheme.primary),
                const SizedBox(width: 9),
                Expanded(child: Text(title,
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 11),
            child,
          ],
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.label, required this.amount});
  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text('JOD ${_money(amount)}',
          style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _ReferenceLink extends StatelessWidget {
  const _ReferenceLink({required this.label, required this.url});
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: TextButton.icon(
      onPressed: () => _openExternal(context, Uri.parse(url)),
      icon: const Icon(Icons.open_in_new_rounded, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      ),
    ),
  );
}
