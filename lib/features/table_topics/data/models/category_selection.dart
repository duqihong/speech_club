class CategorySelection {
  CategorySelection({
    required this.selectedCategories,
    required this.randomAll,
  });

  factory CategorySelection.defaults() {
    return CategorySelection(
      selectedCategories: <String>{},
      randomAll: true,
    );
  }

  final Set<String> selectedCategories;
  final bool randomAll;

  CategorySelection copyWith({
    Set<String>? selectedCategories,
    bool? randomAll,
  }) {
    return CategorySelection(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      randomAll: randomAll ?? this.randomAll,
    );
  }
}
