import 'package:flutter_test/flutter_test.dart';
import 'package:rail_one/main.dart';

void main() {
  testWidgets('Registration page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const RailOneApp());

    expect(find.text('New User Registration'), findsOneWidget);
    expect(find.text('Login Here'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Or Register with'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
  });
}
