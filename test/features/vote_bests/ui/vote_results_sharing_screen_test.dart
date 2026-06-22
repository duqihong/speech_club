import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/data/vote_bests_repository.dart';
import 'package:speech_club/features/vote_bests/data/vote_results_recipient_repository.dart';
import 'package:speech_club/features/vote_bests/ui/vote_bests_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpManualCount(
    WidgetTester tester, {
    Locale? locale,
    VoteBestsRepository? voteRepository,
    VoteResultsRecipientRepository? recipientRepository,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsScreen(
          repository: voteRepository,
          recipientRepository: recipientRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollTo(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(
      find.byType(Scrollable).first,
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('English Manual Count shows result sharing controls',
      (WidgetTester tester) async {
    await pumpManualCount(tester);

    expect(find.text('Send Results to President'), findsOneWidget);
    expect(find.text('Copy Results'), findsOneWidget);
    await scrollTo(tester, 'President Contact');
    expect(find.text('President Contact'), findsOneWidget);
    expect(find.text('Not set'), findsOneWidget);
  });

  testWidgets('Chinese Manual Count shows result sharing controls',
      (WidgetTester tester) async {
    await pumpManualCount(tester, locale: const Locale('zh'));

    expect(find.text('发送结果给会长'), findsOneWidget);
    expect(find.text('复制结果'), findsOneWidget);
    expect(find.text('会长联系方式'), findsOneWidget);
    expect(find.text('未设置'), findsOneWidget);
  });

  testWidgets('English Send Results prompts for missing contact',
      (WidgetTester tester) async {
    await pumpManualCount(tester);
    await scrollTo(tester, 'Send Results to President');

    await tester.tap(find.text('Send Results to President'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'President contact is not set. Please add president name and phone number first.',
      ),
      findsOneWidget,
    );
    expect(find.text('Set Now'), findsOneWidget);
    await tester.tap(find.text('Set Now'));
    await tester.pumpAndSettle();
    expect(find.text('President name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
  });

  testWidgets('Chinese Send Results prompts for missing contact',
      (WidgetTester tester) async {
    await pumpManualCount(tester, locale: const Locale('zh'));
    await scrollTo(tester, '发送结果给会长');

    await tester.tap(find.text('发送结果给会长'));
    await tester.pumpAndSettle();

    expect(
      find.text('还没有设置会长联系方式。请先填写会长姓名和电话号码。'),
      findsOneWidget,
    );
    expect(find.text('现在设置'), findsOneWidget);
  });

  testWidgets('contact dialog validates and saves president contact',
      (WidgetTester tester) async {
    await pumpManualCount(tester);
    await scrollTo(tester, 'President Contact');

    await tester.tap(find.text('President Contact'));
    await tester.pumpAndSettle();
    expect(find.text('President name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Please enter president name.'), findsOneWidget);
    expect(find.text('Please enter phone number.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('presidentNameField')),
      'David',
    );
    await tester.enterText(
      find.byKey(const Key('presidentPhoneField')),
      '+65 9123 4567',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('David · +65 9123 4567'), findsOneWidget);
  });

  testWidgets('Chinese contact dialog uses localized field labels',
      (WidgetTester tester) async {
    await pumpManualCount(tester, locale: const Locale('zh'));
    await scrollTo(tester, '会长联系方式');

    await tester.tap(find.text('会长联系方式'));
    await tester.pumpAndSettle();

    expect(find.text('会长姓名'), findsOneWidget);
    expect(find.text('电话号码'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
  });

  testWidgets('Copy Results copies summary and shows confirmation',
      (WidgetTester tester) async {
    await pumpManualCount(tester);
    await scrollTo(tester, 'Copy Results');

    await tester.tap(find.text('Copy Results'));
    await tester.pumpAndSettle();

    expect(
      find.text('Results copied. You can paste them into SMS or WhatsApp.'),
      findsOneWidget,
    );
  });

  testWidgets('Send Results copies summary when contact is set',
      (WidgetTester tester) async {
    final VoteResultsRecipientRepository recipientRepository =
        VoteResultsRecipientRepository();
    await recipientRepository.save(
      name: 'David',
      phoneNumber: '+65 9123 4567',
    );
    await pumpManualCount(
      tester,
      recipientRepository: recipientRepository,
    );
    await scrollTo(tester, 'Send Results to President');

    await tester.tap(find.text('Send Results to President'));
    await tester.pumpAndSettle();

    expect(
      find.text('Results copied. You can paste them into SMS or WhatsApp.'),
      findsOneWidget,
    );
  });
}
