import 'package:flutter_test/flutter_test.dart';

import 'package:speech_club/main.dart';
import 'package:speech_club/localization/app_locale_controller.dart';

void main() {
  testWidgets('Home screen shows primary module buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      SpeechClubApp(localeController: AppLocaleController()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Speech Club'), findsWidgets);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Expressions'), findsOneWidget);
    expect(find.text('Table Topics'), findsOneWidget);
    expect(find.text('Role Assistant'), findsOneWidget);
  });
}
