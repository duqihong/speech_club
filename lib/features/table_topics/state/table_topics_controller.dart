import 'package:flutter/foundation.dart';

import '../data/models/category_selection.dart';
import '../data/models/table_topics_session.dart';
import '../data/models/topic_library.dart';
import '../data/models/topic_set.dart';
import '../data/table_topics_repository.dart';
import '../domain/topic_service.dart';

class TableTopicsController extends ChangeNotifier {
  TableTopicsController({TableTopicsRepository? repository})
      : _repository = repository ?? TableTopicsRepository();

  final TableTopicsRepository _repository;

  bool loading = false;
  String? error;
  TopicLibrary? library;
  CategorySelection selection = CategorySelection.defaults();
  TopicSet? topicSet;
  bool isCustomMode = false;
  List<String> customTopics = <String>[];

  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final TopicLibrary loadedLibrary = await _repository.getLibrary();
      final List<String> loadedCustomTopics =
          await _repository.loadCustomTopics();
      final TableTopicsSession? session = await _repository.loadSession();

      library = loadedLibrary;
      customTopics = loadedCustomTopics;

      if (session != null) {
        selection = CategorySelection(
          selectedCategories: session.selectedCategories.toSet(),
          randomAll: session.randomAll,
        );
        isCustomMode = session.isCustomMode;

        if (session.topics.length == 10 && session.used.length == 10) {
          topicSet = TopicSet(
            topics: List<String>.from(session.topics),
            used: List<bool>.from(session.used),
          );
        } else {
          topicSet = null;
        }
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void toggleRandomAll(bool value) {
    selection = selection.copyWith(
      randomAll: value,
      selectedCategories:
          value ? <String>{} : Set<String>.from(selection.selectedCategories),
    );
    persistSession();
    notifyListeners();
  }

  void toggleCategory(String category) {
    final Set<String> next = Set<String>.from(selection.selectedCategories);
    if (next.contains(category)) {
      next.remove(category);
    } else {
      next.add(category);
    }

    selection = selection.copyWith(
      selectedCategories: next,
      randomAll: false,
    );
    persistSession();
    notifyListeners();
  }

  void generate10() {
    final TopicLibrary? currentLibrary = library;
    if (currentLibrary == null) {
      return;
    }

    topicSet = generateTopicSet(
      library: currentLibrary,
      selection: selection,
    );
    isCustomMode = false;
    persistSession();
    notifyListeners();
  }

  Future<void> saveCustomTopics(List<String> topics) async {
    final List<String> cleaned = topics
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList(growable: false);

    customTopics = cleaned;
    await _repository.saveCustomTopics(cleaned);
    notifyListeners();
  }

  void useCustomTopics(List<String> topics) {
    final List<String> cleaned = topics
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList(growable: false);
    if (cleaned.isEmpty) {
      return;
    }

    final List<String> padded = List<String>.from(cleaned);
    if (padded.length > 10) {
      padded.removeRange(10, padded.length);
    }
    while (padded.length < 10) {
      padded.add('');
    }

    topicSet = TopicSet.fresh(padded);
    isCustomMode = true;
    selection = CategorySelection.defaults();
    persistSession();
    notifyListeners();
  }

  void markUsed(int index, bool value) {
    final TopicSet? current = topicSet;
    if (current == null || index < 0 || index >= current.used.length) {
      return;
    }

    final List<bool> used = List<bool>.from(current.used);
    used[index] = value;
    topicSet = current.copyWith(used: used);

    persistSession();
    notifyListeners();
  }

  void resetSession() {
    topicSet = null;
    persistSession();
    notifyListeners();
  }

  void setCustomMode(bool value) {
    isCustomMode = value;
    persistSession();
    notifyListeners();
  }

  Future<void> persistSession() {
    return _repository.saveSession(_buildSession());
  }

  TableTopicsSession _buildSession() {
    return TableTopicsSession(
      version: 1,
      randomAll: selection.randomAll,
      selectedCategories: selection.selectedCategories.toList(growable: false),
      topics: topicSet?.topics ?? <String>[],
      used: topicSet?.used ?? <bool>[],
      isCustomMode: isCustomMode,
    );
  }
}
