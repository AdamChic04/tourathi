import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tourathi/core/providers/app_provider.dart';
import 'package:tourathi/data/food/food_discovery_catalog.dart';
import 'package:tourathi/data/mock/jordan_place_seed.dart';
import 'package:tourathi/features/food/food_screen.dart';

void main() {
  test('Food discovery uses the existing 61-place dataset, no fake restaurants', () {
    final food = FoodDiscoveryCatalog.experiences(JordanPlaceSeed.offlinePlaces);
    expect(food.length, 7);
    expect(food.map((place) => place.id).toSet().length, 7);
    expect(food.every((place) => place.category == 'food'), isTrue);
    expect(food.every((place) => place.imageUrl.endsWith('${place.id}.jpg')),
        isTrue);
    expect(FoodDiscoveryCatalog.governorates(food).length, 6);
    expect(FoodDiscoveryCatalog.dishes.length, 6);
  });

  test('Kind, governorate and bilingual search filter the food catalog', () {
    final places = JordanPlaceSeed.offlinePlaces;
    final villages = FoodDiscoveryCatalog.filter(
      places: places,
      kind: FoodExperienceKind.villages,
    );
    expect(villages.map((p) => p.id).toSet(),
        {'jerash-sakib', 'ajloun-rason'});

    final madaba = FoodDiscoveryCatalog.filter(
      places: places,
      governorate: 'Madaba',
    );
    expect(madaba.map((p) => p.id).toList(),
        ['madaba-mosaic-workshops']);

    final arabicSearch = FoodDiscoveryCatalog.filter(
      places: places,
      query: 'رأسون',
    );
    expect(arabicSearch.single.id, 'ajloun-rason');

    final noMatch = FoodDiscoveryCatalog.filter(
      places: places,
      query: 'Not a restaurant',
    );
    expect(noMatch, isEmpty);
  });

  testWidgets('Food page shows dishes and its seven catalog experiences',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MaterialApp(home: FoodScreen()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('food_page_title')), findsOneWidget);
    expect(find.text('Taste of Jordan'), findsOneWidget);
    expect(find.text('7 experiences'), findsOneWidget);
    expect(find.byKey(const Key('food_dishes_list')), findsOneWidget);
    expect(find.byKey(const Key('food_search')), findsOneWidget);
    expect(find.text('7 places to explore'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Food search narrows results and reset restores the catalog',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MaterialApp(home: FoodScreen()),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('food_search')), 'Rasoun');
    await tester.pump();
    expect(find.text('1 place to explore'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('food_search')), 'No matching place');
    await tester.pump();
    expect(find.text('0 places to explore'), findsOneWidget);
    expect(find.byKey(const Key('food_empty')), findsWidgets);

    await tester.tap(find.byKey(const Key('food_reset_filters')));
    await tester.pump();
    expect(find.text('7 places to explore'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
