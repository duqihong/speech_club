String normalizeTopic(String s) {
  return s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r"""[“”"'’]"""), '')
      .replaceAll(RegExp(r'[^\w\s]'), '');
}

List<String> dedupeTopics(Iterable<String> topics) {
  final Set<String> seen = <String>{};
  final List<String> out = <String>[];
  for (final String t in topics) {
    final String trimmed = t.trim();
    final String key = normalizeTopic(trimmed);
    if (key.isEmpty) {
      continue;
    }
    if (seen.add(key)) {
      out.add(trimmed);
    }
  }
  return out;
}
