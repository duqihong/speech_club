import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/features/committees/ui/committees_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Committees screen renders committee guide roles',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CommitteesScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Committees'), findsOneWidget);
    expect(find.text('President'), findsOneWidget);
    expect(find.text('VPE'), findsOneWidget);
    expect(find.text('VPM'), findsOneWidget);
    expect(find.text('VPPR'), findsOneWidget);
    expect(find.text('Secretary'), findsOneWidget);
    expect(find.text('Treasurer'), findsOneWidget);
    expect(find.text('Sergeant at Arms'), findsOneWidget);
    expect(find.text('Immediate Past President'), findsOneWidget);
  });

  testWidgets('tapping President opens committee detail screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CommitteesScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('President'));
    await tester.pumpAndSettle();

    expect(find.text('🧭 President'), findsOneWidget);
    expect(find.text('Role Purpose'), findsOneWidget);
    expect(find.text('Key Responsibilities'), findsOneWidget);
    expect(find.text('Quick Tips'), findsOneWidget);
  });
}
