import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../data/models/category_selection.dart';
import '../data/models/table_topic_session_item.dart';
import '../data/models/table_topics_session.dart';
import '../data/models/topic_library.dart';
import '../data/models/topic_set.dart';
import '../data/table_topics_repository.dart';

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
  Locale _currentLocale = const Locale('en');

  Future<void> init({Locale? locale}) async {
    _currentLocale = locale ?? _currentLocale;
    loading = true;
    error = null;
    notifyListeners();

    try {
      final TopicLibrary loadedLibrary =
          await _repository.getLibrary(locale: _currentLocale);
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

        if (session.items.length == 10 && session.used.length == 10) {
          final List<String> resolvedTopics =
              await _repository.resolveSessionItemTexts(
            items: session.items,
            locale: _currentLocale,
          );
          topicSet = TopicSet.fromItems(
            items: List<TableTopicSessionItem>.from(session.items),
            topics: resolvedTopics,
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

  Future<void> generate10() async {
    await generateBuiltInTopics(
      selectedCategories: selection.selectedCategories,
      locale: _currentLocale,
    );
  }

  Future<void> generateBuiltInTopics({
    required Set<String> selectedCategories,
    Locale? locale,
  }) async {
    _currentLocale = locale ?? _currentLocale;
    final CategorySelection nextSelection = CategorySelection(
      selectedCategories: Set<String>.from(selectedCategories),
      randomAll: selectedCategories.isEmpty,
    );

    final TopicSet generated = await _repository.generateBuiltInTopicSet(
      selection: nextSelection,
      locale: _currentLocale,
    );

    selection = nextSelection;
    topicSet = generated;
    isCustomMode = false;
    await persistSession();
    notifyListeners();
  }

  Future<void> setGeneratedTopics(
    List<String> topics, {
    Locale? locale,
  }) async {
    if (topics.length != 10) {
      return;
    }

    _currentLocale = locale ?? _currentLocale;
    final List<TableTopicSessionItem> items =
        await _repository.buildSessionItemsFromTexts(
      topics: topics,
      locale: _currentLocale,
    );

    topicSet = TopicSet.fromItems(
      items: items,
      topics: List<String>.from(topics),
    );
    isCustomMode = false;
    await persistSession();
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

    topicSet = TopicSet.fromItems(
      items: padded.map(TableTopicSessionItem.custom).toList(growable: false),
      topics: padded,
    );
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
      version: TableTopicsSession.currentVersion,
      randomAll: selection.randomAll,
      selectedCategories: selection.selectedCategories.toList(growable: false),
      items: topicSet?.items ?? <TableTopicSessionItem>[],
      used: topicSet?.used ?? <bool>[],
      isCustomMode: isCustomMode,
    );
  }
}
