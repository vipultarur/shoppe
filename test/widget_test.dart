import 'package:flutter_test/flutter_test.dart';
import 'package:demoapp/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const GroceryApp());
    expect(find.text('Shoppe'), findsOneWidget);
  });
}
