import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/localization/app_locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('restores saved locale after a new controller is created', () async {
    final AppLocaleController firstController = AppLocaleController();
    await firstController.setLocale(AppLocaleController.simplifiedChinese);

    final AppLocaleController secondController = AppLocaleController();
    await secondController.loadSavedLocale();

    expect(secondController.locale, const Locale('zh'));
  });

  test('falls back to English for unsupported saved language codes', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_locale_language_code': 'fr',
    });

    final AppLocaleController controller = AppLocaleController();
    await controller.loadSavedLocale();

    expect(controller.locale, const Locale('en'));
  });
}
