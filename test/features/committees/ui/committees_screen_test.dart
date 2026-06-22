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

    expect(find.text('执委职责'), findsOneWidget);
    expect(find.text('委员职责'), findsNothing);
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

    for (final String title in <String>[
      '执委职责',
      '会长',
      '教育副会长',
      '会员副会长',
      '公关副会长',
      '秘书',
      '财务',
      '礼宾司',
      '前任会长',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    for (final String obsoleteTitle in <String>[
      '委员职责',
      '主席',
      '教育副主席',
      '会员副主席',
      '公关副主席',
      '前任主席',
      '事务官',
      'VPE',
      'VPM',
      'VPPR',
    ]) {
      expect(find.text(obsoleteTitle), findsNothing);
    }
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
    await tester.tap(find.text('会长'));
    await tester.pumpAndSettle();

    expect(find.text('🧭 会长'), findsOneWidget);
    expect(find.text('角色定位'), findsOneWidget);
    expect(find.text('主要责任'), findsOneWidget);
    expect(find.text('小提示'), findsOneWidget);
    expect(find.textContaining('你带领俱乐部'), findsOneWidget);
  });
}
