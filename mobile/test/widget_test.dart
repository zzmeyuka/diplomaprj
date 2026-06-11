import 'package:flutter_test/flutter_test.dart';
import 'package:smartfly/app.dart';

void main() {
  testWidgets('SmartFly app loads', (tester) async {
    await tester.pumpWidget(const SmartFlyApp());
    await tester.pump();
    expect(find.byType(SmartFlyApp), findsOneWidget);
  });
}
