import 'dart:ui';

class TopicCategoryGuide {
  const TopicCategoryGuide({
    required this.id,
    required this.icon,
    required this.titleEn,
    required this.titleZh,
    required this.hintEn,
    required this.hintZh,
    required this.purposeEn,
    required this.purposeZh,
    required this.topicIdeasEn,
    required this.topicIdeasZh,
    required this.choosingTipsEn,
    required this.choosingTipsZh,
    required this.structureEn,
    required this.structureZh,
    required this.openingLinesEn,
    required this.openingLinesZh,
  });

  final String id;
  final String icon;
  final String titleEn;
  final String titleZh;
  final String hintEn;
  final String hintZh;
  final String purposeEn;
  final String purposeZh;
  final List<String> topicIdeasEn;
  final List<String> topicIdeasZh;
  final List<String> choosingTipsEn;
  final List<String> choosingTipsZh;
  final List<String> structureEn;
  final List<String> structureZh;
  final List<String> openingLinesEn;
  final List<String> openingLinesZh;

  String titleForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? titleZh : titleEn;
  }

  String hintForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? hintZh : hintEn;
  }

  String purposeForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? purposeZh : purposeEn;
  }

  List<String> topicIdeasForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? topicIdeasZh : topicIdeasEn;
  }

  List<String> choosingTipsForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? choosingTipsZh : choosingTipsEn;
  }

  List<String> structureForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? structureZh : structureEn;
  }

  List<String> openingLinesForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? openingLinesZh : openingLinesEn;
  }
}
