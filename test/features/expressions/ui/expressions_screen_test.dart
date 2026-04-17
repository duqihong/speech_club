import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:speech_club/features/expressions/ui/expressions_screen.dart';
import 'package:speech_club/l10n/app_localizations.dart';

void main() {
  testWidgets('Expressions screen renders repository-backed content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ExpressionsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Expressions'), findsOneWidget);
    expect(find.text('English Expressions'), findsOneWidget);
    expect(find.text('Chinese Expressions'), findsOneWidget);
    expect(find.text('Break the ice'), findsOneWidget);
    expect(find.text('打破僵局'), findsOneWidget);

    await tester.tap(find.text('Chinese Expressions'));
    await tester.pumpAndSettle();

    expect(find.text('勇敢迈出第一步'), findsOneWidget);
  });
}
