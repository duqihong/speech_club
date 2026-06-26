import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_api.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_models.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_storage.dart';
import 'package:speech_club/features/vote_bests/data/vote_results_recipient_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('storage saves and loads local online count setup', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final OnlineCountStorage storage = OnlineCountStorage();

    await storage.saveSetup(
      const OnlineCountSetup(
        ownerToken: 'owner-token-1',
        baseUrl: 'https://example.com',
        clubName: 'Demo Club',
        clubSlug: 'demo-club',
        adminPin: '123456',
        currentSessionId: 'session-1',
        currentSessionTitle: 'Regular Meeting',
        currentSessionDate: '2026-06-25',
        currentSessionStatus: 'open',
      ),
    );

    final OnlineCountSetup setup = await storage.load();

    expect(setup.ownerToken, 'owner-token-1');
    expect(setup.baseUrl, 'https://example.com');
    expect(setup.clubName, 'Demo Club');
    expect(setup.clubSlug, 'demo-club');
    expect(setup.adminPin, '123456');
    expect(setup.currentSessionId, 'session-1');
    expect(setup.currentSessionTitle, 'Regular Meeting');
    expect(setup.currentSessionDate, '2026-06-25');
    expect(setup.currentSessionStatus, 'open');
  });

  test('empty storage uses remote backend default', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final OnlineCountSetup setup = await OnlineCountStorage().load();

    expect(setup.ownerToken, isNotEmpty);
    expect(setup.baseUrl, OnlineCountApi.defaultBaseUrl);
    expect(setup.currentSessionTitle, 'Regular Meeting');
    expect(setup.currentSessionStatus, OnlineRoundStatus.draft.value);
  });

  test('owner token is generated once and persisted', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final OnlineCountStorage storage = OnlineCountStorage();

    final OnlineCountSetup first = await storage.load();
    final OnlineCountSetup second = await storage.load();

    expect(first.ownerToken, isNotEmpty);
    expect(second.ownerToken, first.ownerToken);
  });

  test('reset local setup keeps owner token and clears online state', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final OnlineCountStorage storage = OnlineCountStorage();
    final OnlineCountSetup initial = await storage.load();

    await storage.saveSetup(
      initial.copyWith(
        baseUrl: 'https://example.com',
        clubName: 'Demo Club',
        clubSlug: 'demo-club',
        adminPin: '123456',
        currentSessionId: 'session-1',
        currentSessionTitle: 'Regular Meeting',
        currentSessionDate: '2026-06-25',
        currentSessionStatus: OnlineRoundStatus.open.value,
      ),
    );

    await storage.resetOnlineCountOnThisDevice();
    final OnlineCountSetup reset = await storage.load();

    expect(reset.ownerToken, initial.ownerToken);
    expect(reset.baseUrl, OnlineCountApi.defaultBaseUrl);
    expect(reset.clubName, isEmpty);
    expect(reset.clubSlug, isEmpty);
    expect(reset.adminPin, isEmpty);
    expect(reset.currentSessionId, isEmpty);
    expect(reset.currentSessionTitle, 'Regular Meeting');
    expect(reset.currentSessionDate, isEmpty);
    expect(reset.currentSessionStatus, OnlineRoundStatus.draft.value);
  });

  test('candidate draft is saved and loaded by session and award', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final OnlineCountStorage storage = OnlineCountStorage();

    await storage.saveCandidateDraft(
      sessionId: 'session-1',
      awardType: OnlineAwardType.bestSpeaker.value,
      text: 'Alice\nBen',
    );
    await storage.saveCandidateDraft(
      sessionId: 'session-2',
      awardType: OnlineAwardType.bestSpeaker.value,
      text: 'Cara',
    );

    expect(
      await storage.loadCandidateDraft(
        sessionId: 'session-1',
        awardType: OnlineAwardType.bestSpeaker.value,
      ),
      'Alice\nBen',
    );
    expect(
      await storage.loadCandidateDraft(
        sessionId: 'session-2',
        awardType: OnlineAwardType.bestSpeaker.value,
      ),
      'Cara',
    );
  });

  test('candidate drafts are cleared by session only', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final OnlineCountStorage storage = OnlineCountStorage();

    await storage.saveCandidateDraft(
      sessionId: 'session-1',
      awardType: OnlineAwardType.bestSpeaker.value,
      text: 'Alice',
    );
    await storage.saveCandidateDraft(
      sessionId: 'session-2',
      awardType: OnlineAwardType.bestSpeaker.value,
      text: 'Ben',
    );

    await storage.clearCandidateDraftsForSession('session-1');

    expect(
      await storage.loadCandidateDraft(
        sessionId: 'session-1',
        awardType: OnlineAwardType.bestSpeaker.value,
      ),
      isNull,
    );
    expect(
      await storage.loadCandidateDraft(
        sessionId: 'session-2',
        awardType: OnlineAwardType.bestSpeaker.value,
      ),
      'Ben',
    );
  });

  test('start fresh replaces owner token and clears only online state',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final OnlineCountStorage storage = OnlineCountStorage();
    final OnlineCountSetup initial = await storage.load();
    final VoteResultsRecipientRepository recipientRepository =
        VoteResultsRecipientRepository();
    await recipientRepository.save(
      name: 'Ada President',
      phoneNumber: '+65 9664 5650',
    );

    await storage.saveSetup(
      initial.copyWith(
        baseUrl: 'https://example.com',
        clubName: 'Demo Club',
        clubSlug: 'demo-club',
        adminPin: '123456',
        currentSessionId: 'session-1',
        currentSessionTitle: 'Regular Meeting',
        currentSessionDate: '2026-06-25',
        currentSessionStatus: OnlineRoundStatus.closed.value,
      ),
    );
    await storage.saveCandidateDraft(
      sessionId: 'session-1',
      awardType: OnlineAwardType.bestSpeaker.value,
      text: 'Alice',
    );

    await storage.startFreshOnThisDevice();
    final OnlineCountSetup fresh = await storage.load();
    final recipient = await recipientRepository.load();

    expect(fresh.ownerToken, isNotEmpty);
    expect(fresh.ownerToken, isNot(initial.ownerToken));
    expect(fresh.baseUrl, OnlineCountApi.defaultBaseUrl);
    expect(fresh.clubName, isEmpty);
    expect(fresh.clubSlug, isEmpty);
    expect(fresh.adminPin, isEmpty);
    expect(fresh.currentSessionId, isEmpty);
    expect(fresh.currentSessionTitle, 'Regular Meeting');
    expect(fresh.currentSessionDate, isEmpty);
    expect(fresh.currentSessionStatus, OnlineRoundStatus.draft.value);
    expect(
      await storage.loadCandidateDraft(
        sessionId: 'session-1',
        awardType: OnlineAwardType.bestSpeaker.value,
      ),
      isNull,
    );
    expect(recipient?.name, 'Ada President');
    expect(recipient?.phoneNumber, '+65 9664 5650');
  });

  test('reset clears candidate drafts but keeps president contact', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final OnlineCountStorage storage = OnlineCountStorage();
    final VoteResultsRecipientRepository recipientRepository =
        VoteResultsRecipientRepository();
    await recipientRepository.save(
      name: 'Ada President',
      phoneNumber: '+65 9664 5650',
    );
    await storage.saveCandidateDraft(
      sessionId: 'session-1',
      awardType: OnlineAwardType.bestEvaluator.value,
      text: 'Eva',
    );

    await storage.resetOnlineCountOnThisDevice();
    final recipient = await recipientRepository.load();

    expect(
      await storage.loadCandidateDraft(
        sessionId: 'session-1',
        awardType: OnlineAwardType.bestEvaluator.value,
      ),
      isNull,
    );
    expect(recipient?.name, 'Ada President');
    expect(recipient?.phoneNumber, '+65 9664 5650');
  });
}
