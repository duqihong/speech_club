import 'dart:collection';
import 'dart:math';

List<String> generateTenTopics(List<String> pool, {Random? random}) {
  if (pool.isEmpty) {
    throw ArgumentError('Topic pool cannot be empty.');
  }

  final Random rng = random ?? Random();
  final List<String> uniquePool = LinkedHashSet<String>.from(pool)
      .where((String topic) => topic.trim().isNotEmpty)
      .toList(growable: false);

  if (uniquePool.isEmpty) {
    throw ArgumentError('Topic pool cannot contain only empty topics.');
  }

  final List<String> shuffledUnique = List<String>.from(uniquePool)
    ..shuffle(rng);

  final List<String> result = <String>[];
  for (final String topic in shuffledUnique) {
    result.add(topic);
    if (result.length == 10) {
      return result;
    }
  }

  while (result.length < 10) {
    result.add(uniquePool[rng.nextInt(uniquePool.length)]);
  }

  return result;
}
