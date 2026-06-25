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

    expect(setup.baseUrl, OnlineCountApi.defaultBaseUrl);
    expect(setup.currentSessionTitle, 'Regular Meeting');
  });
}
