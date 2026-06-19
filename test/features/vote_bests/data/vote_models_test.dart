import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/features/vote_bests/data/vote_models.dart';

void main() {
  test('VoteCandidate serializes and deserializes correctly', () {
    final DateTime createdAt = DateTime.utc(2026, 6, 19, 10, 30);
    final VoteCandidate candidate = VoteCandidate(
      id: 'candidate-1',
      name: 'Alice',
      votes: 5,
      createdAt: createdAt,
    );

    final Map<String, dynamic> json = candidate.toJson();
    final VoteCandidate restored = VoteCandidate.fromJson(json);

    expect(json['id'], 'candidate-1');
    expect(json['name'], 'Alice');
    expect(json['votes'], 5);
    expect(restored.id, 'candidate-1');
    expect(restored.name, 'Alice');
    expect(restored.votes, 5);
    expect(restored.createdAt, createdAt);
  });
}
