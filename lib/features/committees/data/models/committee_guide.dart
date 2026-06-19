class CommitteeGuide {
  const CommitteeGuide({
    required this.id,
    required this.title,
    required this.icon,
    required this.rolePurpose,
    required this.responsibilitySections,
    required this.quickTips,
  });

  final String id;
  final String title;
  final String icon;
  final String rolePurpose;
  final List<CommitteeResponsibilitySection> responsibilitySections;
  final List<String> quickTips;
}

class CommitteeResponsibilitySection {
  const CommitteeResponsibilitySection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;
}
