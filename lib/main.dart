import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_routes.dart';
import 'features/expressions/ui/expressions_screen.dart';
import 'features/table_topics/ui/table_topics_setup_screen.dart';
import 'l10n/app_localizations.dart';
import 'localization/app_locale_controller.dart';
import 'role_assistant/ui/role_assistant_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/timer/timer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppLocaleController localeController = AppLocaleController();
  await localeController.loadSavedLocale();

  runApp(SpeechClubApp(localeController: localeController));
}

class SpeechClubApp extends StatelessWidget {
  SpeechClubApp({
    super.key,
    AppLocaleController? localeController,
  }) : localeController = localeController ?? AppLocaleController();

  final AppLocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          locale: localeController.locale,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.home,
          routes: <String, WidgetBuilder>{
            AppRoutes.home: (_) =>
                HomeScreen(localeController: localeController),
            AppRoutes.timer: (_) => const TimerScreen(),
            AppRoutes.expressions: (_) => const ExpressionsScreen(),
            AppRoutes.tableTopics: (_) => const TableTopicsSetupScreen(),
            AppRoutes.roleAssistant: (_) => const RoleAssistantScreen(),
          },
        );
      },
    );
  }
}
