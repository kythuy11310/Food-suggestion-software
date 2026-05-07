import 'package:flutter_test/flutter_test.dart';

import 'package:kitchen_search_flutter/main.dart';

void main() {
  testWidgets('Kitchen Search renders initial UI', (WidgetTester tester) async {
    await tester.pumpWidget(const KitchenSearchApp());
    await tester.pump();

    expect(find.textContaining('Kitchen Search'), findsOneWidget);
    expect(find.text('Tìm'), findsOneWidget);
  });
}
