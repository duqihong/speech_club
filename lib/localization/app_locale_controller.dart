import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController();

  static const String _localeLanguageCodeKey = 'app_locale_language_code';
  static const Locale english = Locale('en');
  static const Locale simplifiedChinese = Locale('zh');
  static const List<Locale> supportedLocales = <Locale>[
    english,
    simplifiedChinese,
  ];

  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> loadSavedLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_localeLanguageCodeKey);

    if (languageCode == null || languageCode.isEmpty) {
      return;
    }

    _locale = _localeFromLanguageCode(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (locale == null) {
      _locale = null;
      await prefs.remove(_localeLanguageCodeKey);
      notifyListeners();
      return;
    }

    _locale = _localeFromLanguageCode(locale.languageCode);
    await prefs.setString(_localeLanguageCodeKey, _locale!.languageCode);
    notifyListeners();
  }

  Locale _localeFromLanguageCode(String languageCode) {
    return supportedLocales.firstWhere(
      (Locale locale) => locale.languageCode == languageCode,
      orElse: () => english,
    );
  }
}
