import 'package:flutter_test/flutter_test.dart';
import 'package:skills_to_pump/main.dart';
void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const LifePilotApp());
    expect(find.byType(LifePilotApp), findsOneWidget);
  });
}
