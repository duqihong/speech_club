import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/committees/ui/committees_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';
import 'package:speech_club/localization/app_locale_controller.dart';
import 'package:speech_club/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('English Committees screen renders committee guide roles',
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
    expect(find.text('Vice President Education'), findsOneWidget);
    expect(find.text('Vice President Membership'), findsOneWidget);
    expect(find.text('Vice President Public Relations'), findsOneWidget);
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

  testWidgets('Chinese home shows Committees as officer responsibilities',
      (WidgetTester tester) async {
    final AppLocaleController localeController = AppLocaleController();
    await localeController.setLocale(AppLocaleController.simplifiedChinese);

    await tester.pumpWidget(
      SpeechClubApp(localeController: localeController),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('委员职责'), findsOneWidget);
  });

  testWidgets('Chinese Committees screen renders localized guide roles',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CommitteesScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('委员职责'), findsOneWidget);
    expect(find.text('主席'), findsOneWidget);
    expect(find.text('教育副主席'), findsOneWidget);
    expect(find.text('会员副主席'), findsOneWidget);
    expect(find.text('公关副主席'), findsOneWidget);
    expect(find.text('VPE'), findsOneWidget);
    expect(find.text('VPM'), findsOneWidget);
    expect(find.text('VPPR'), findsOneWidget);
  });

  testWidgets('tapping Chinese President opens localized detail screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CommitteesScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('主席'));
    await tester.pumpAndSettle();

    expect(find.text('🧭 主席'), findsOneWidget);
    expect(find.text('角色定位'), findsOneWidget);
    expect(find.text('主要责任'), findsOneWidget);
    expect(find.text('小提示'), findsOneWidget);
    expect(find.textContaining('你带领俱乐部'), findsOneWidget);
  });
}
