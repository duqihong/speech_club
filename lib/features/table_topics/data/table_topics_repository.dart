import 'models/table_topics_session.dart';
import 'models/topic_library.dart';
import 'table_topics_storage.dart';
import 'topic_library_loader.dart';

class TableTopicsRepository {
  TableTopicsRepository({
    TopicLibraryLoader? loader,
    TableTopicsStorage? storage,
  })  : _loader = loader ?? TopicLibraryLoader(),
        _storage = storage ?? TableTopicsStorage();

  final TopicLibraryLoader _loader;
  final TableTopicsStorage _storage;

  TopicLibrary? _cachedLibrary;

  Future<TopicLibrary> getLibrary() async {
    if (_cachedLibrary != null) {
      return _cachedLibrary!;
    }
    final TopicLibrary loaded = await _loader.load();
    _cachedLibrary = loaded;
    return loaded;
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
}
