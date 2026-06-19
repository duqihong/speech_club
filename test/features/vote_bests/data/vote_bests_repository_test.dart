import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/data/vote_bests_repository.dart';
import 'package:speech_club/features/vote_bests/data/vote_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late int idCounter;
  late DateTime now;
  late VoteBestsRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    idCounter = 0;
    now = DateTime.utc(2026, 6, 19, 10);
    repository = VoteBestsRepository(
      idFactory: () => 'candidate-${++idCounter}',
      now: () => now.add(Duration(minutes: idCounter)),
    );
  });

  test('loads default award categories when no data exists', () async {
    final VoteBestsState state = await repository.loadState();

    expect(state.categories.length, 3);
    expect(state.categories[0].id, 'best_speaker');
    expect(state.categories[1].id, 'best_table_topics_speaker');
    expect(state.categories[2].id, 'best_evaluator');
    expect(
      state.categories.every(
        (VoteAwardCategory category) => category.candidates.isEmpty,
      ),
      isTrue,
    );
  });

  test('increment vote increases count', () async {
    VoteBestsState state = await repository.addCandidate(
      categoryId: 'best_speaker',
      name: 'Alice',
    );
    final String candidateId =
        state.categoryById('best_speaker').candidates.single.id;

    state = await repository.incrementVote(
      categoryId: 'best_speaker',
      candidateId: candidateId,
    );

    expect(state.categoryById('best_speaker').candidates.single.votes, 1);
  });

  test('decrement vote does not go below zero', () async {
    VoteBestsState state = await repository.addCandidate(
      categoryId: 'best_speaker',
      name: 'Alice',
    );
    final String candidateId =
        state.categoryById('best_speaker').candidates.single.id;

    state = await repository.decrementVote(
      categoryId: 'best_speaker',
      candidateId: candidateId,
    );

    expect(state.categoryById('best_speaker').candidates.single.votes, 0);
  });

  test('reset restores empty default categories', () async {
    await repository.addCandidate(categoryId: 'best_speaker', name: 'Alice');

    final VoteBestsState state = await repository.resetAll();

    expect(state.categories.length, 3);
    expect(
      state.categories.every(
        (VoteAwardCategory category) => category.candidates.isEmpty,
      ),
      isTrue,
    );
  });
}
