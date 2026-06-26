import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_api.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_storage.dart';

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
  });

  test('empty storage uses remote backend default', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final OnlineCountSetup setup = await OnlineCountStorage().load();

    expect(setup.ownerToken, isNotEmpty);
    expect(setup.baseUrl, OnlineCountApi.defaultBaseUrl);
    expect(setup.currentSessionTitle, 'Regular Meeting');
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
  });
}
