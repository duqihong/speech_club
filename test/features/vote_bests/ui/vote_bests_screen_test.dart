import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/data/vote_bests_repository.dart';
import 'package:speech_club/features/vote_bests/data/vote_models.dart';
import 'package:speech_club/features/vote_bests/ui/vote_bests_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';
import 'package:speech_club/localization/app_locale_controller.dart';
import 'package:speech_club/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpVoteBests(
    WidgetTester tester, {
    VoteBestsRepository? repository,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openBestSpeaker(WidgetTester tester) async {
    await tester.tap(find.text('Best Speaker'));
    await tester.pumpAndSettle();
  }

  Future<void> addCandidate(WidgetTester tester, String name) async {
    await tester.tap(find.text('Add Candidate'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), name);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('English home opens Vote Bests mode selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      SpeechClubApp(localeController: AppLocaleController()),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Vote Bests'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Vote Bests'), findsOneWidget);
    await tester.tap(find.text('Vote Bests'));
    await tester.pumpAndSettle();

    expect(
      find.text('Choose how you want to count meeting award votes.'),
      findsOneWidget,
    );
    expect(find.text('Manual Count'), findsOneWidget);
    expect(find.text('Online Count'), findsOneWidget);
  });

  testWidgets('Chinese home opens Vote Bests mode selection',
      (WidgetTester tester) async {
    final AppLocaleController localeController = AppLocaleController();
    await localeController.setLocale(AppLocaleController.simplifiedChinese);

    await tester.pumpWidget(
      SpeechClubApp(localeController: localeController),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('最佳投票'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('最佳投票'), findsOneWidget);
    await tester.tap(find.text('最佳投票'));
    await tester.pumpAndSettle();

    expect(find.text('选择本次例会奖项的计票方式。'), findsOneWidget);
    expect(find.text('手动计票'), findsOneWidget);
    expect(find.text('在线计票'), findsOneWidget);
  });

  testWidgets('Manual Count screen shows English award categories',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Manual Count'), findsOneWidget);
    expect(find.text('Best Speaker'), findsOneWidget);
    expect(find.text('Best Table Topics Speaker'), findsOneWidget);
    expect(find.text('Best Evaluator'), findsOneWidget);
  });

  testWidgets('Manual Count screen shows Chinese award categories',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('手动计票'), findsOneWidget);
    expect(find.text('最佳演讲者'), findsOneWidget);
    expect(find.text('最佳即席演讲者'), findsOneWidget);
    expect(find.text('最佳点评者'), findsOneWidget);
  });

  testWidgets('tapping Best Speaker opens detail page',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Best Speaker'));
    await tester.pumpAndSettle();

    expect(find.text('🗣️ Best Speaker'), findsOneWidget);
    expect(find.text('Add Candidate'), findsOneWidget);
  });

  testWidgets('adding a candidate and tapping +1 updates vote count',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VoteBestsScreen(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Best Speaker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Candidate'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsWidgets);
    expect(find.text('Votes: 0'), findsOneWidget);

    await tester.tap(find.text('+1').first);
    await tester.pumpAndSettle();

    expect(find.text('Votes: 1'), findsOneWidget);
    expect(find.text('Current leader: Alice'), findsOneWidget);
  });

  testWidgets('duplicate candidate names show a gentle warning',
      (WidgetTester tester) async {
    await pumpVoteBests(tester);
    await openBestSpeaker(tester);
    await addCandidate(tester, 'Alice');

    await tester.tap(find.text('Add Candidate'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), ' alice ');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('This name already exists.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('equal top votes show a current tie',
      (WidgetTester tester) async {
    final VoteBestsRepository repository = VoteBestsRepository();
    VoteBestsState state = await repository.addCandidate(
      categoryId: 'best_speaker',
      name: 'Alice',
    );
    state = await repository.addCandidate(
      categoryId: 'best_speaker',
      name: 'Bob',
    );
    for (final VoteCandidate candidate
        in state.categoryById('best_speaker').candidates) {
      await repository.incrementVote(
        categoryId: 'best_speaker',
        candidateId: candidate.id,
      );
    }

    await pumpVoteBests(tester, repository: repository);
    await openBestSpeaker(tester);
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Current tie'), findsOneWidget);
    expect(find.text('Alice: 1'), findsOneWidget);
    expect(find.text('Bob: 1'), findsOneWidget);
  });

  testWidgets('delete candidate requires confirmation',
      (WidgetTester tester) async {
    final VoteBestsRepository repository = VoteBestsRepository();
    await pumpVoteBests(tester, repository: repository);
    await openBestSpeaker(tester);
    await addCandidate(tester, 'Alice');

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Remove this candidate?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsWidgets);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsNothing);
    final VoteBestsState state = await repository.loadState();
    expect(state.categoryById('best_speaker').candidates, isEmpty);
  });

  testWidgets('reset meeting votes requires confirmation',
      (WidgetTester tester) async {
    final VoteBestsRepository repository = VoteBestsRepository();
    await repository.addCandidate(
      categoryId: 'best_speaker',
      name: 'Alice',
    );
    await pumpVoteBests(tester, repository: repository);

    await tester.scrollUntilVisible(
      find.text('Reset Meeting Votes'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Reset Meeting Votes'));
    await tester.pumpAndSettle();
    expect(
      find.text('Reset all candidates and votes for this meeting?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      (await repository.loadState()).categoryById('best_speaker').candidates,
      hasLength(1),
    );

    await tester.scrollUntilVisible(
      find.text('Reset Meeting Votes'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Reset Meeting Votes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    final VoteBestsState state = await repository.loadState();
    expect(
      state.categories.every(
        (VoteAwardCategory category) => category.candidates.isEmpty,
      ),
      isTrue,
    );
  });
}
