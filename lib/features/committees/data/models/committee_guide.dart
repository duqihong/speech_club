import 'dart:ui';

class CommitteeGuide {
  const CommitteeGuide({
    required this.id,
    required this.titleEn,
    required this.titleZh,
    required this.icon,
    required this.rolePurposeEn,
    required this.rolePurposeZh,
    required this.responsibilitySectionsEn,
    required this.responsibilitySectionsZh,
    required this.quickTipsEn,
    required this.quickTipsZh,
    this.abbreviation,
  });

  final String id;
  final String titleEn;
  final String titleZh;
  final String? abbreviation;
  final String icon;
  final String rolePurposeEn;
  final String rolePurposeZh;
  final List<CommitteeResponsibilitySection> responsibilitySectionsEn;
  final List<CommitteeResponsibilitySection> responsibilitySectionsZh;
  final List<String> quickTipsEn;
  final List<String> quickTipsZh;

  String titleForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? titleZh : titleEn;
  }

  String? subtitleForLocale(Locale locale) {
    if (locale.languageCode != 'zh') {
      return null;
    }
    return abbreviation;
  }

  String rolePurposeForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? rolePurposeZh : rolePurposeEn;
  }

  List<CommitteeResponsibilitySection> sectionsForLocale(Locale locale) {
    return locale.languageCode == 'zh'
        ? responsibilitySectionsZh
        : responsibilitySectionsEn;
  }

  List<String> quickTipsForLocale(Locale locale) {
    return locale.languageCode == 'zh' ? quickTipsZh : quickTipsEn;
  }
}

class CommitteeResponsibilitySection {
  const CommitteeResponsibilitySection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;
}
