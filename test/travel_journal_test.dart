import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tourathi/core/providers/app_provider.dart';
import 'package:tourathi/features/journal/journal_entry.dart';
import 'package:tourathi/features/journal/journal_repository.dart';
import 'package:tourathi/features/journal/travel_journal_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      publishableKey: 'tourathi-local-test-key',
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('offline journal save persists and retry does not duplicate', () async {
    final entry = JournalEntry(
      id: 'journal-retry-test',
      userId: 'demo:tourist',
      title: 'Petra at sunset',
      body: 'A memorable walk through Petra.',
      visibility: 'private',
      createdAt: DateTime.utc(2026, 11, 19),
      updatedAt: DateTime.utc(2026, 11, 19),
      placeId: 'maan-petra',
      placeName: 'Petra',
    );

    expect(await JournalRepository.instance.save(entry), isFalse);
    expect(await JournalRepository.instance.save(entry), isFalse);
    final saved = await JournalRepository.instance.loadMine();
    expect(saved, hasLength(1));
    expect(saved.single.title, 'Petra at sunset');
    expect(saved.single.visibility, 'private');
  });

  testWidgets('user can create and revisit a private journal entry',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MaterialApp(home: TravelJournalScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'A day in Petra');
    await tester.ensureVisible(find.text('Save entry'));
    await tester.tap(find.text('Save entry'));
    await tester.pumpAndSettle();

    expect(find.text('A day in Petra'), findsOneWidget);
    final saved = await JournalRepository.instance.loadMine();
    expect(saved, hasLength(1));
    expect(saved.single.visibility, 'private');

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Petra, revisited');
    await tester.ensureVisible(find.text('Save entry'));
    await tester.tap(find.text('Save entry'));
    await tester.pumpAndSettle();
    expect(find.text('Petra, revisited'), findsOneWidget);
    expect(await JournalRepository.instance.loadMine(), hasLength(1));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('Petra, revisited'), findsNothing);
    expect(await JournalRepository.instance.loadMine(), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
