import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:speech_club/localization/app_locale_controller.dart';
import 'package:speech_club/main.dart';

void main() {
  testWidgets('Home screen shows primary module buttons without expressions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      SpeechClubApp(localeController: AppLocaleController()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Speech Club'), findsWidgets);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Expressions'), findsNothing);
    expect(find.text('Topic Selection'), findsOneWidget);
    expect(find.text('Table Topics'), findsOneWidget);
    expect(find.text('Role Assistant'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Committees'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Committees'), findsOneWidget);
  });
}
