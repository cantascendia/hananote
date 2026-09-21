import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_app_bar.dart';

void main() {
  testWidgets('test: app bar consumes status inset without moving body twice',
      (tester) async {
    const statusBarHeight = 32.0;
    const toolbarHeight = 56.0;
    const bodyKey = Key('body');
    const appBar = HoyoAppBar(title: 'HanaNote');
    expect(appBar.preferredSize.height, toolbarHeight);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(top: statusBarHeight),
            viewPadding: EdgeInsets.only(top: statusBarHeight),
          ),
          child: child!,
        ),
        home: const Scaffold(
          appBar: appBar,
          body: SizedBox(key: bodyKey, width: double.infinity),
        ),
      ),
    );

    final titleBounds = tester.getRect(find.text('HanaNote'));
    final bodyTop = tester.getTopLeft(find.byKey(bodyKey)).dy;
    expect(titleBounds.top, greaterThanOrEqualTo(statusBarHeight));
    expect(
        titleBounds.bottom, lessThanOrEqualTo(statusBarHeight + toolbarHeight));
    expect(bodyTop, statusBarHeight + toolbarHeight);
  });
}
