import 'dart:math';
import 'dart:ui';

import '../../expressions/data/expression_content_repository.dart';
import 'bilingual_table_topics_repository.dart';
import 'models/category_selection.dart';
import 'models/bilingual_table_topic_content.dart';
import 'models/table_topic_session_item.dart';
import 'models/table_topics_session.dart';
import 'models/topic_library.dart';
import 'models/topic_set.dart';
import 'table_topics_storage.dart';
import 'topic_library_loader.dart';

class TableTopicsRepository {
  static const String englishSourceExpressionsCategory =
      'english_source_expressions';
  static const String chineseSourceExpressionsCategory =
      'chinese_source_expressions';

  TableTopicsRepository({
    BilingualTableTopicsRepository? bilingualRepository,
    ExpressionContentRepository? expressionRepository,
    TopicLibraryLoader? loader,
    TableTopicsStorage? storage,
  })  : _bilingualRepository =
            bilingualRepository ?? BilingualTableTopicsRepository(),
        _expressionRepository =
            expressionRepository ?? ExpressionContentRepository(),
        _loader = loader ?? TopicLibraryLoader(),
        _storage = storage ?? TableTopicsStorage();

  final BilingualTableTopicsRepository _bilingualRepository;
  final ExpressionContentRepository _expressionRepository;
  final TopicLibraryLoader _loader;
  final TableTopicsStorage _storage;

  final Map<String, TopicLibrary> _cachedLibrariesByLanguageCode =
      <String, TopicLibrary>{};
  Map<String, BilingualTableTopicContent>? _cachedBuiltInTopicsById;
  final Map<String, Map<String, String>> _cachedTopicIdsByTextByLanguageCode =
      <String, Map<String, String>>{};

  Future<TopicLibrary> getLibrary({required Locale locale}) async {
    final String languageCode = locale.languageCode;
    final TopicLibrary? cached = _cachedLibrariesByLanguageCode[languageCode];
    if (cached != null) {
      return cached;
    }

    TopicLibrary loaded;
    try {
      final Map<String, BilingualTableTopicContent> topicsById =
          await _getBuiltInTopicsById();
      loaded = _buildTopicLibrary(
        items: topicsById.values,
        locale: locale,
      );
    } catch (_) {
      loaded = await _loader.load();
    }

    _cachedLibrariesByLanguageCode[languageCode] = loaded;
    return loaded;
  }

  Future<List<TableTopicSessionItem>> buildSessionItemsFromTexts({
    required List<String> topics,
    required Locale locale,
  }) async {
    final Map<String, String> idsByText =
        await _getBuiltInTopicIdsByText(locale.languageCode);

    return topics.map((String topic) {
      final String trimmed = topic.trim();
      if (trimmed.isEmpty) {
        return TableTopicSessionItem.custom('');
      }

      final String? topicId = idsByText[trimmed];
      if (topicId != null) {
        return TableTopicSessionItem.builtIn(topicId);
      }

      return TableTopicSessionItem.custom(trimmed);
    }).toList(growable: false);
  }

  Future<TopicSet> generateBuiltInTopicSet({
    required CategorySelection selection,
    required Locale locale,
    Random? random,
  }) async {
    final List<BilingualTableTopicContent> pool = await _buildBuiltInTopicPool(
      selection: selection,
    );
    if (pool.isEmpty) {
      throw ArgumentError('Built-in topic pool cannot be empty.');
    }

    final Random rng = random ?? Random();
    final List<BilingualTableTopicContent> uniquePool =
        _dedupeBuiltInTopicsById(pool);
    if (uniquePool.isEmpty) {
      throw ArgumentError(
          'Built-in topic pool cannot contain only empty topics.');
    }

    final List<BilingualTableTopicContent> shuffledUnique =
        List<BilingualTableTopicContent>.from(uniquePool)..shuffle(rng);
    final List<BilingualTableTopicContent> selected =
        shuffledUnique.take(10).toList(growable: true);

    while (selected.length < 10) {
      selected.add(uniquePool[rng.nextInt(uniquePool.length)]);
    }

    return TopicSet.fromItems(
      items: selected
          .map((BilingualTableTopicContent item) =>
              TableTopicSessionItem.builtIn(item.id))
          .toList(growable: false),
      topics: selected
          .map((BilingualTableTopicContent item) => _displayText(item, locale))
          .toList(growable: false),
    );
  }

  Future<List<String>> resolveSessionItemTexts({
    required List<TableTopicSessionItem> items,
    required Locale locale,
  }) async {
    final Map<String, BilingualTableTopicContent> topicsById =
        await _getBuiltInTopicsById();

    return items.map((TableTopicSessionItem item) {
      if (item.isBuiltIn) {
        final BilingualTableTopicContent? topic = topicsById[item.topicId];
        return topic == null ? '' : _displayText(topic, locale);
      }

      return item.customText ?? '';
    }).toList(growable: false);
  }

  Future<TableTopicsSession?> loadSession() {
    return _storage.loadSession();
  }

  Future<void> saveSession(TableTopicsSession session) {
    return _storage.saveSession(session);
  }

  Future<void> clearSession() {
    return _storage.clearSession();
  }

  Future<List<String>> loadCustomTopics() {
    return _storage.loadCustomTopics();
  }

  Future<void> saveCustomTopics(List<String> topics) {
    return _storage.saveCustomTopics(topics);
  }

  Future<List<BilingualTableTopicContent>> _buildBuiltInTopicPool({
    required CategorySelection selection,
  }) async {
    final Map<String, BilingualTableTopicContent> topicsById =
        await _getBuiltInTopicsById();
    final List<BilingualTableTopicContent> allTopics =
        topicsById.values.toList(growable: false);
    final List<BilingualTableTopicContent> defaultPool =
        _buildDefaultTopicPool(allTopics, selection);

    if (selection.randomAll) {
      return defaultPool;
    }

    final List<BilingualTableTopicContent> selectedPool = allTopics
        .where((BilingualTableTopicContent item) =>
            selection.selectedCategories.contains(item.category))
        .toList(growable: false);

    if (selectedPool.length < 10) {
      return defaultPool;
    }

    return selectedPool;
  }

  List<BilingualTableTopicContent> _buildDefaultTopicPool(
    List<BilingualTableTopicContent> allTopics,
    CategorySelection selection,
  ) {
    return allTopics.where((BilingualTableTopicContent item) {
      if (!_isExpressionCategory(item.category)) {
        return true;
      }

      return selection.selectedCategories.contains(item.category);
    }).toList(growable: false);
  }

  List<BilingualTableTopicContent> _dedupeBuiltInTopicsById(
    List<BilingualTableTopicContent> topics,
  ) {
    final Set<String> seen = <String>{};
    final List<BilingualTableTopicContent> out = <BilingualTableTopicContent>[];

    for (final BilingualTableTopicContent topic in topics) {
      if (topic.id.isEmpty) {
        continue;
      }
      if (seen.add(topic.id)) {
        out.add(topic);
      }
    }

    return out;
  }

  Future<Map<String, BilingualTableTopicContent>>
      _getBuiltInTopicsById() async {
    final Map<String, BilingualTableTopicContent>? cached =
        _cachedBuiltInTopicsById;
    if (cached != null) {
      return cached;
    }

    try {
      final tableTopicsBundle = await _bilingualRepository.load();
      final List<BilingualTableTopicContent> expressionItems =
          await _loadExpressionTopics();
      final List<BilingualTableTopicContent> items =
          <BilingualTableTopicContent>[
        ...tableTopicsBundle.items,
        ...expressionItems,
      ];
      final Map<String, BilingualTableTopicContent> byId =
          <String, BilingualTableTopicContent>{
        for (final BilingualTableTopicContent item in items) item.id: item,
      };
      _cachedBuiltInTopicsById = byId;
      return byId;
    } catch (_) {
      _cachedBuiltInTopicsById = <String, BilingualTableTopicContent>{};
      return _cachedBuiltInTopicsById!;
    }
  }

  Future<Map<String, String>> _getBuiltInTopicIdsByText(
      String languageCode) async {
    final Map<String, String>? cached =
        _cachedTopicIdsByTextByLanguageCode[languageCode];
    if (cached != null) {
      return cached;
    }

    final Locale locale = Locale(languageCode);
    final Map<String, BilingualTableTopicContent> topicsById =
        await _getBuiltInTopicsById();
    final Map<String, String> idsByText = <String, String>{};

    for (final BilingualTableTopicContent item in topicsById.values) {
      final String text = _displayText(item, locale).trim();
      if (text.isNotEmpty) {
        idsByText[text] = item.id;
      }
    }

    _cachedTopicIdsByTextByLanguageCode[languageCode] = idsByText;
    return idsByText;
  }

  Future<List<BilingualTableTopicContent>> _loadExpressionTopics() async {
    final englishBundle = await _expressionRepository.loadEnglishSource();
    final chineseBundle = await _expressionRepository.loadChineseSource();

    return <BilingualTableTopicContent>[
      ...englishBundle.items.map(
        (item) => BilingualTableTopicContent(
          id: item.id,
          category: englishSourceExpressionsCategory,
          text: item.text,
        ),
      ),
      ...chineseBundle.items.map(
        (item) => BilingualTableTopicContent(
          id: item.id,
          category: chineseSourceExpressionsCategory,
          text: item.text,
        ),
      ),
    ];
  }

  TopicLibrary _buildTopicLibrary({
    required Iterable<BilingualTableTopicContent> items,
    required Locale locale,
  }) {
    final Map<String, List<String>> categories = <String, List<String>>{};

    for (final BilingualTableTopicContent item in items) {
      final String text = _displayText(item, locale).trim();
      if (text.isEmpty) {
        continue;
      }

      categories.putIfAbsent(item.category, () => <String>[]).add(text);
    }

    return TopicLibrary(categories: categories);
  }

  String _displayText(BilingualTableTopicContent item, Locale locale) {
    switch (item.category) {
      case englishSourceExpressionsCategory:
        return _formatPairedText(
          source: item.text.en,
          translation: item.text.zh,
        );
      case chineseSourceExpressionsCategory:
        return _formatPairedText(
          source: item.text.zh,
          translation: item.text.en,
        );
      default:
        return item.text.forLocale(locale);
    }
  }

  bool _isExpressionCategory(String category) {
    return category == englishSourceExpressionsCategory ||
        category == chineseSourceExpressionsCategory;
  }

  String _formatPairedText({
    required String source,
    required String translation,
  }) {
    final String trimmedSource = source.trim();
    final String trimmedTranslation = translation.trim();
    if (trimmedSource.isEmpty) {
      return trimmedTranslation;
    }
    if (trimmedTranslation.isEmpty) {
      return trimmedSource;
    }

    return '$trimmedSource\n$trimmedTranslation';
  }
}
