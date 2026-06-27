import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'vote_models.dart';

class VoteBestsRepository {
  VoteBestsRepository({
    String Function()? idFactory,
    DateTime Function()? now,
  })  : _idFactory = idFactory ?? const Uuid().v4,
        _now = now ?? DateTime.now;

  static const String storageKey = 'speech_club_vote_bests_state_v1';

  static const List<VoteAwardCategory> defaultCategories = <VoteAwardCategory>[
    VoteAwardCategory(
      id: 'best_speaker',
      icon: '🗣️',
      titleEn: 'Best Speaker',
      titleZh: '最佳演讲者',
      candidates: <VoteCandidate>[],
    ),
    VoteAwardCategory(
      id: 'best_table_topics_speaker',
      icon: '💬',
      titleEn: 'Best Table Topics Speaker',
      titleZh: '最佳即席演讲者',
      candidates: <VoteCandidate>[],
    ),
    VoteAwardCategory(
      id: 'best_evaluator',
      icon: '📝',
      titleEn: 'Best Evaluator',
      titleZh: '最佳评论员',
      candidates: <VoteCandidate>[],
    ),
  ];

  final String Function() _idFactory;
  final DateTime Function() _now;

  Future<VoteBestsState> loadState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      final VoteBestsState state = _defaultState();
      await _saveState(state);
      return state;
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return _defaultState();
      }
      return _withDefaultCategories(VoteBestsState.fromJson(decoded));
    } catch (_) {
      return _defaultState();
    }
  }

  Future<VoteBestsState> addCandidate({
    required String categoryId,
    required String name,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Candidate name is required.');
    }

    final VoteBestsState state = await loadState();
    final VoteBestsState updated = _updateCategory(
      state,
      categoryId,
      (VoteAwardCategory category) {
        final List<VoteCandidate> candidates =
            List<VoteCandidate>.of(category.candidates);
        candidates.add(
          VoteCandidate(
            id: _idFactory(),
            name: trimmedName,
            votes: 0,
            createdAt: _now(),
          ),
        );
        return category.copyWith(candidates: candidates);
      },
    );
    await _saveState(updated);
    return updated;
  }

  Future<VoteBestsState> deleteCandidate({
    required String categoryId,
    required String candidateId,
  }) async {
    final VoteBestsState state = await loadState();
    final VoteBestsState updated = _updateCategory(
      state,
      categoryId,
      (VoteAwardCategory category) => category.copyWith(
        candidates: category.candidates
            .where((VoteCandidate candidate) => candidate.id != candidateId)
            .toList(growable: false),
      ),
    );
    await _saveState(updated);
    return updated;
  }

  Future<VoteBestsState> incrementVote({
    required String categoryId,
    required String candidateId,
  }) async {
    return _changeVote(
      categoryId: categoryId,
      candidateId: candidateId,
      delta: 1,
    );
  }

  Future<VoteBestsState> decrementVote({
    required String categoryId,
    required String candidateId,
  }) async {
    return _changeVote(
      categoryId: categoryId,
      candidateId: candidateId,
      delta: -1,
    );
  }

  Future<VoteBestsState> resetAll() async {
    final VoteBestsState state = _defaultState();
    await _saveState(state);
    return state;
  }

  Future<VoteBestsState> _changeVote({
    required String categoryId,
    required String candidateId,
    required int delta,
  }) async {
    final VoteBestsState state = await loadState();
    final VoteBestsState updated = _updateCategory(
      state,
      categoryId,
      (VoteAwardCategory category) {
        return category.copyWith(
          candidates: category.candidates.map((VoteCandidate candidate) {
            if (candidate.id != candidateId) {
              return candidate;
            }
            final int nextVotes = candidate.votes + delta;
            return candidate.copyWith(votes: nextVotes < 0 ? 0 : nextVotes);
          }).toList(growable: false),
        );
      },
    );
    await _saveState(updated);
    return updated;
  }

  VoteBestsState _updateCategory(
    VoteBestsState state,
    String categoryId,
    VoteAwardCategory Function(VoteAwardCategory category) update,
  ) {
    return state.copyWith(
      categories: state.categories.map((VoteAwardCategory category) {
        return category.id == categoryId ? update(category) : category;
      }).toList(growable: false),
    );
  }

  Future<void> _saveState(VoteBestsState state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(state.toJson()));
  }

  VoteBestsState _defaultState() {
    return VoteBestsState(
      categories: defaultCategories
          .map(
            (VoteAwardCategory category) =>
                category.copyWith(candidates: <VoteCandidate>[]),
          )
          .toList(growable: false),
    );
  }

  VoteBestsState _withDefaultCategories(VoteBestsState savedState) {
    return VoteBestsState(
      categories: defaultCategories.map((VoteAwardCategory defaultCategory) {
        final VoteAwardCategory? savedCategory =
            savedState.categories.cast<VoteAwardCategory?>().firstWhere(
                  (VoteAwardCategory? category) =>
                      category?.id == defaultCategory.id,
                  orElse: () => null,
                );
        return defaultCategory.copyWith(
          candidates: savedCategory?.candidates ?? <VoteCandidate>[],
        );
      }).toList(growable: false),
    );
  }
}
