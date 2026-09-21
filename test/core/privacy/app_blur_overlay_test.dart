import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/privacy/app_blur_overlay.dart';

void main() {
  testWidgets('shows and hides the privacy overlay on lifecycle changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppBlurOverlay(
          child: Scaffold(
            body: SizedBox.expand(),
          ),
        ),
      ),
    );

    expect(_overlayOpacity(tester), 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();

    expect(_overlayOpacity(tester), 1);
    expect(_overlayColor(tester).a, 1);
    expect(find.byIcon(Icons.shield_moon_rounded), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(_overlayOpacity(tester), 0);
  });
}

Color _overlayColor(WidgetTester tester) {
  return tester
      .widget<ColoredBox>(
        find.descendant(
          of: find.byType(AnimatedOpacity),
          matching: find.byType(ColoredBox),
        ),
      )
      .color;
}

double _overlayOpacity(WidgetTester tester) {
  return tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
}
