import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/app/app.dart';
import 'package:hananote/app/di/injection.dart';

void main() {
  setUpAll(configureDependencies);

  testWidgets('renders the localized app title on launch', (tester) async {
    await tester.pumpWidget(const HanaApp());
    await tester.pumpAndSettle();

    expect(find.text('HanaNote'), findsOneWidget);
  });
}
