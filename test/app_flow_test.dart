import 'package:flutter_test/flutter_test.dart';
import 'package:bill_validator/main.dart' as app;

void main() {
  testWidgets('App launches and shows primary actions', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Bill Validator'), findsWidgets);
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Select from Gallery'), findsOneWidget);
  });
}
