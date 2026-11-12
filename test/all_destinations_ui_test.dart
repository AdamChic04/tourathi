import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tourathi/core/providers/app_provider.dart';
import 'package:tourathi/data/mock/jordan_place_seed.dart';
import 'package:tourathi/data/models/models.dart';
import 'package:tourathi/data/models/place_visit_facts.dart';
import 'package:tourathi/data/services/place_map_links.dart';
import 'package:tourathi/features/home/home_screen.dart';
import 'package:tourathi/features/explore/explore_screen.dart';

void main() {
  test('partial Supabase results never hide bundled locations or pictures', () {
    final first = JordanPlaceSeed.offlinePlaces.first;
    final remote = Place(
      id: first.id,
      name: 'Updated in database',
      nameAr: first.nameAr,
      description: first.description,
      descriptionAr: first.descriptionAr,
      location: first.location,
      locationAr: first.locationAr,
      imageUrl: first.imageUrl,
      rating: 0,
      category: first.category,
    );
    JordanPlaceSeed.setRemotePlaces([remote]);
    expect(JordanPlaceSeed.places.length, 61);
    expect(JordanPlaceSeed.places.first.name, 'Updated in database');
    expect(JordanPlaceSeed.places.last.imageUrl,
        JordanPlaceSeed.offlinePlaces.last.imageUrl);
    expect(JordanPlaceSeed.places.map((p) => p.id).toSet().length, 61);
    JordanPlaceSeed.setRemotePlaces(JordanPlaceSeed.offlinePlaces);
  });

  test('Google Maps links do not invent pins for unverified locations', () {
    final place = JordanPlaceSeed.offlinePlaces
        .firstWhere((p) => p.id == 'balqa-wadi-shuaib');
    final url = PlaceMapLinks.search(place);
    expect(url.host, 'www.google.com');
    expect(url.queryParameters['query'], contains('Wadi Shuaib'));
    expect(url.queryParameters['query'], contains('Balqa'));
  });

  test('map uses site points, but not UNESCO area reference points', () {
    final place = JordanPlaceSeed.offlinePlaces
        .firstWhere((p) => p.id == 'amman-citadel');
    const site = PlaceVisitFacts(
      placeId: 'amman-citadel',
      gpsLat: 31.95401697,
      gpsLon: 35.93486821,
      gpsPrecision: 'site_point',
      gpsSourceUrl: 'https://doa.gov.jo',
    );
    const area = PlaceVisitFacts(
      placeId: 'amman-citadel',
      gpsLat: 31.95401697,
      gpsLon: 35.93486821,
      gpsPrecision: 'area_reference',
      gpsSourceUrl: 'https://whc.unesco.org',
    );
    expect(PlaceMapLinks.search(place, research: site)
        .queryParameters['query'], '31.95401697,35.93486821');
    expect(PlaceMapLinks.search(place, research: area)
        .queryParameters['query'], contains('Amman Citadel'));
  });

  testWidgets('Home makes all 61 available, while the hero stays curated',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump();
    expect(find.text('See all 61'), findsOneWidget);
    expect(find.byKey(const Key('home_featured_carousel')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Explore shows 61 destination cards and 12 governorates',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MaterialApp(home: ExploreScreen()),
    ));
    await tester.pump();
    expect(find.text('61 Jordan destinations'), findsOneWidget);
    expect(find.byKey(const Key('explore_place_grid')), findsOneWidget);
    expect(find.byKey(const Key('explore_place_amman-roman-theatre')),
        findsWidgets);

    final locationTab = find.byKey(const Key('explore_map_view'));
    await tester.ensureVisible(locationTab);
    await tester.tap(locationTab);
    await tester.pump();
    expect(find.text('61 locations across 12 governorates'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
