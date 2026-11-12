import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourathi/core/widgets/tourathi_brand_mark.dart';

void main() {
  testWidgets('Uses splash compass and TouRathi wordmark at low opacity',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: TouRathiBrandWatermark(opacity: 0.09)),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('tourathi_watermark_compass')),
        findsOneWidget);
    expect(find.byKey(const Key('tourathi_watermark_wordmark')),
        findsOneWidget);
    expect(find.text('TouRathi'), findsOneWidget);
    expect(find.byType(TouRathiCompassMark), findsOneWidget);
    final watermarkOpacity =
        tester.widget<Opacity>(find.ancestor(
          of: find.byKey(const Key('tourathi_watermark_compass')),
          matching: find.byType(Opacity),
        ).first);
    expect(watermarkOpacity.opacity, 0.09);
  });

  testWidgets('Watermark never blocks buttons beneath it', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () => tapped = true,
                  child: const Text('Continue'),
                ),
              ),
              const Positioned.fill(
                child: TouRathiBrandWatermark(),
              ),
            ],
          ),
        ),
      ),
    );

    final ignore = tester.widget<IgnorePointer>(
        find.byKey(const Key('tourathi_watermark_ignores_taps')));
    expect(ignore.ignoring, isTrue);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('Watermark is present in dark mode', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        themeMode: ThemeMode.dark,
        home: Scaffold(body: TouRathiBrandWatermark()),
      ),
    );
    expect(find.byKey(const Key('tourathi_watermark_compass')),
        findsOneWidget);
  });
}
