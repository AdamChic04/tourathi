import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class PlaceDetailsScreen extends StatefulWidget {
  const PlaceDetailsScreen({super.key, required this.placeId});

  final String placeId;

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  int _carouselIndex = 0;

  Place? _findPlace(String id) {
    for (final place in [...MockData.popularPlaces, ...MockData.hiddenGems]) {
      if (place.id == id) return place;
    }
    return null;
  }

  List<String> _carouselImages(Place place) {
    // These four destination illustrations are included with the Flutter app.
    const local = <String, String>{
      'petra': 'assets/images/home/petra.jpg',
      'jerash': 'assets/images/home/jerash.jpg',
      'wadi-rum': 'assets/images/home/wadi_rum.jpg',
      'dead-sea': 'assets/images/home/dead_sea.jpg',
    };
    return [local[place.id] ?? place.imageUrl];
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isArabic = app.isArabic;
    final _isSaved = app.isFavorite(widget.placeId);
    final place = _findPlace(widget.placeId);

    if (place == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            isArabic ? 'المكان غير موجود' : 'Place not found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

    final name = isArabic ? place.nameAr : place.name;
    final description = isArabic ? place.descriptionAr : place.description;
    final location = isArabic ? place.locationAr : place.location;
    final story = isArabic
        ? (place.historicalStoryAr ?? place.historicalStory)
        : place.historicalStory;
    final images = _carouselImages(place);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: images.length,
                  options: CarouselOptions(
                    height: 320,
                    viewportFraction: 1,
                    enableInfiniteScroll: images.length > 1,
                    autoPlay: images.length > 1,
                    autoPlayInterval: const Duration(seconds: 4),
                    onPageChanged: (index, _) =>
                        setState(() => _carouselIndex = index),
                  ),
                  itemBuilder: (context, index, _) {
                    final photo = images[index];
                    if (photo.startsWith('assets/')) {
                      return Image.asset(photo, height: 320,
                          width: double.infinity, fit: BoxFit.cover);
                    }
                    return AppNetworkImage(
                      imageUrl: photo,
                      height: 320,
                      width: double.infinity,
                      borderRadius: 0,
                    );
                  },
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleButton(
                          icon: Icons.arrow_back,
                          onTap: () => context.pop(),
                        ),
                        Row(
                          children: [
                            _CircleButton(
                              icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                              onTap: () => context.read<AppProvider>().toggleFavorite(widget.placeId),
                            ),
                            const SizedBox(width: 8),
                            _CircleButton(
                              icon: Icons.share_outlined,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _carouselIndex == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _carouselIndex == i
                              ? AppColors.desertGold
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ).animate().fadeIn(duration: 400.ms),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.desertGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.desertGold, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${place.rating}',
                              style: AppTypography.textStyle(
                                isArabic: isArabic,
                                fontWeight: FontWeight.bold,
                                color: AppColors.desertGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.warmBrown),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(location, style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      if (place.distance != null)
                        Text(
                          place.distance!,
                          style: TextStyle(
                            color: AppColors.desertGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: AppStrings.get('overview', isArabic)),
                  const SizedBox(height: 8),
                  Text(description, style: Theme.of(context).textTheme.bodyLarge)
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms),
                  if (story != null) ...[
                    const SizedBox(height: 24),
                    _SectionTitle(title: AppStrings.get('historicalStory', isArabic)),
                    const SizedBox(height: 8),
                    GlassCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldShimmer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.history_edu, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              story,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.6,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 450.ms),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.access_time,
                          label: AppStrings.get('visitingHours', isArabic),
                          value: place.visitingHours ??
                              (isArabic ? '9:00 ص - 5:00 م' : '9:00 AM - 5:00 PM'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.payments_outlined,
                          label: AppStrings.get('entryFees', isArabic),
                          value: place.entryFee ?? place.price ?? (isArabic ? 'مجاني' : 'Free'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DirectionsCard(isArabic: isArabic)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: '${AppStrings.get('reviews', isArabic)} (${place.reviewCount})',
                  ),
                  const SizedBox(height: 12),
                  _ReviewsSection(isArabic: isArabic, rating: place.rating),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.view_in_ar,
                          label: AppStrings.get('viewAncientVersion', isArabic),
                          gradient: AppColors.aiGlow,
                          onTap: () => context.push('/ar-hub'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.auto_stories,
                          label: AppStrings.get('aiStorytelling', isArabic),
                          gradient: AppColors.desertGradient,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.read<AppProvider>().toggleFavorite(widget.placeId),
                          icon: Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: AppColors.desertGold,
                          ),
                          label: Text(AppStrings.get('save', isArabic)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.desertGold,
                            side: const BorderSide(color: AppColors.desertGold),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined, color: AppColors.warmBrown),
                          label: Text(AppStrings.get('share', isArabic)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warmBrown,
                            side: BorderSide(color: AppColors.sandBeige),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: AppStrings.get('addToItinerary', isArabic),
                    icon: Icons.add_road,
                    width: double.infinity,
                    onPressed: () => context.push('/ai-planner'),
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.desertGold, size: 22),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DirectionsCard extends StatelessWidget {
  const _DirectionsCard({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions, color: AppColors.emerald),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('directions', isArabic),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  isArabic ? '25 دقيقة بالسيارة' : '25 min drive',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.desertGold),
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.isArabic, required this.rating});

  final bool isArabic;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final reviews = [
      (isArabic ? 'سارة المصري' : 'Sara Al-Masri', 5, isArabic
          ? 'تجربة لا تُنسى! المكان ساحر والتاريخ حي.'
          : 'Unforgettable experience! The place is magical.'),
      (isArabic ? 'عمر الراشد' : 'Omar Al-Rashid', 4, isArabic
          ? 'مكان رائع، أنصح بزيارته في الصباح الباكر.'
          : 'Amazing place, visit early morning for best light.'),
    ];

    return Column(
      children: reviews.asMap().entries.map((entry) {
        final index = entry.key;
        final (author, stars, text) = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppColors.sandBeige.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.sandBeige,
                    child: Text(
                      author[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      author,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        size: 14,
                        color: AppColors.desertGold,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (100 * index).ms, duration: 400.ms);
      }).toList(),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.desertGold.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
