import 'dart:ui';

class PathwayGuide {
  const PathwayGuide({
    required this.id,
    required this.icon,
    required this.titleEn,
    required this.titleZh,
    required this.hintEn,
    required this.hintZh,
    required this.buildsEn,
    required this.buildsZh,
    required this.goodForEn,
    required this.goodForZh,
    required this.speechFocusEn,
    required this.speechFocusZh,
    required this.howToStartEn,
    required this.howToStartZh,
    required this.mentorTipsEn,
    required this.mentorTipsZh,
  });

  final String id;
  final String icon;
  final String titleEn;
  final String titleZh;
  final String hintEn;
  final String hintZh;
  final String buildsEn;
  final String buildsZh;
  final List<String> goodForEn;
  final List<String> goodForZh;
  final List<String> speechFocusEn;
  final List<String> speechFocusZh;
  final List<String> howToStartEn;
  final List<String> howToStartZh;
  final List<String> mentorTipsEn;
  final List<String> mentorTipsZh;

  String titleForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? titleZh : titleEn;
  }

  String hintForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? hintZh : hintEn;
  }

  String buildsForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? buildsZh : buildsEn;
  }

  List<String> goodForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? goodForZh : goodForEn;
  }

  List<String> speechFocusForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? speechFocusZh : speechFocusEn;
  }

  List<String> howToStartForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? howToStartZh : howToStartEn;
  }

  List<String> mentorTipsForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? mentorTipsZh : mentorTipsEn;
  }
}
