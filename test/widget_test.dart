import 'package:flutter_test/flutter_test.dart';
import 'package:elora/main.dart';

void main() {
  testWidgets('Elora app basic load smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EloraApp());
    expect(find.byType(EloraApp), findsOneWidget);
  });
}
