import 'dart:ui';

class SpeechTopic {
  const SpeechTopic({
    required this.id,
    required this.titleEn,
    required this.titleZh,
    required this.categoryEn,
    required this.categoryZh,
    required this.promptEn,
    required this.promptZh,
    required this.styleEn,
    required this.styleZh,
    required this.whyItWorksEn,
    required this.whyItWorksZh,
    required this.structureEn,
    required this.structureZh,
    required this.starterQuestionsEn,
    required this.starterQuestionsZh,
    required this.openingLineEn,
    required this.openingLineZh,
  });

  final String id;
  final String titleEn;
  final String titleZh;
  final String categoryEn;
  final String categoryZh;
  final String promptEn;
  final String promptZh;
  final String styleEn;
  final String styleZh;
  final String whyItWorksEn;
  final String whyItWorksZh;
  final List<String> structureEn;
  final List<String> structureZh;
  final List<String> starterQuestionsEn;
  final List<String> starterQuestionsZh;
  final String openingLineEn;
  final String openingLineZh;

  bool get isPersonalGrowth => categoryEn == 'Personal Growth';

  String titleForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? titleZh : titleEn;
  }

  String categoryForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? categoryZh : categoryEn;
  }

  String promptForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? promptZh : promptEn;
  }

  String styleForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? styleZh : styleEn;
  }

  String whyItWorksForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? whyItWorksZh : whyItWorksEn;
  }

  List<String> structureForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? structureZh : structureEn;
  }

  List<String> starterQuestionsForLocale(Locale locale) {
    return locale.languageCode == 'zh'
        ? starterQuestionsZh
        : starterQuestionsEn;
  }

  String openingLineForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? openingLineZh : openingLineEn;
  }
}
