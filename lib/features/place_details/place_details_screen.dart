import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_provider.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';

const _photos = <String, String>{
  'petra': 'assets/images/home/petra.jpg',
  'jerash': 'assets/images/home/jerash.jpg',
  'wadi-rum': 'assets/images/home/wadi_rum.jpg',
  'dead-sea': 'assets/images/home/dead_sea.jpg',
};

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({super.key, required this.placeId});
  final String placeId;

  @override
  Widget build(BuildContext context) {
    Place? place;
    for (final candidate in MockData.popularPlaces) {
      if (candidate.id == placeId) {
        place = candidate;
        break;
      }
    }
    if (place == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Destination')),
        body: const Center(child: Text('Destination not found')),
      );
    }

    final p = place;
    final provider = context.watch<AppProvider>();
    final arabic = provider.isArabic;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? const Color(0xFFD9A67D) : const Color(0xFF9B6548);
    final image = _photos[p.id];

    return Scaffold(
      appBar: AppBar(
        title: Text(arabic ? p.nameAr : p.name),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: provider.isFavorite(p.id) ? 'Remove favorite' : 'Save favorite',
            onPressed: () => context.read<AppProvider>().toggleFavorite(p.id),
            icon: Icon(provider.isFavorite(p.id)
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
                color: provider.isFavorite(p.id) ? Colors.redAccent : null),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (image != null)
            AspectRatio(
              aspectRatio: 1.3,
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(arabic ? p.nameAr : p.name,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: accent, size: 19),
                    const SizedBox(width: 6),
                    Expanded(child: Text(arabic ? p.locationAr : p.location)),
                  ],
                ),
                const SizedBox(height: 20),
                Text(arabic ? p.descriptionAr : p.description,
                    style: const TextStyle(fontSize: 16, height: 1.55)),
                const SizedBox(height: 24),
                Text(arabic ? 'صورة توضيحية' : 'Illustrative demo image',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 30),
                OutlinedButton.icon(
                  onPressed: () => context.push('/ai-planner'),
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(arabic ? 'مخطط الرحلات — قريباً' : 'AI Trip Planner — coming soon'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
