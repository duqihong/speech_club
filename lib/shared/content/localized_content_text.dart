import 'dart:ui';

class LocalizedContentText {
  const LocalizedContentText({
    required this.en,
    required this.zh,
  });

  final String en;
  final String zh;

  factory LocalizedContentText.fromJson(Map<String, dynamic> json) {
    return LocalizedContentText(
      en: json['en']?.toString().trim() ?? '',
      zh: json['zh']?.toString().trim() ?? '',
    );
  }

  String forLocale(Locale locale) {
    if (locale.languageCode == 'zh') {
      return zh;
    }

    return en;
  }
}
