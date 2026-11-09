import 'package:flutter_test/flutter_test.dart';

import 'package:tourathi/app.dart';

void main() {
  testWidgets('TouRathi app launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TouRathiApp());
    await tester.pump();

    expect(find.text('TouRathi'), findsOneWidget);
  });
}
