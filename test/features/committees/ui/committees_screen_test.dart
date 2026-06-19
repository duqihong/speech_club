import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/committees/ui/committees_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Committees screen renders default roles',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CommitteesScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Committees'), findsOneWidget);
    expect(
      find.text('Keep a simple local list of club officers and helpers.'),
      findsOneWidget,
    );
    expect(find.text('President'), findsOneWidget);
    expect(find.text('Vice President Education'), findsOneWidget);
    expect(find.text('Not assigned'), findsWidgets);
  });
}
