import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_api.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_models.dart';

void main() {
  group('OnlineCountApi', () {
    test('votingLinkForClub builds base, Chinese, and English links', () {
      final OnlineCountApi api = OnlineCountApi(
        baseUrl: 'https://example.com/',
        client: MockClient((http.Request request) async {
          return http.Response('{}', 200);
        }),
      );

      expect(
        api.votingLinkForClub('demo-club'),
        'https://example.com/c/demo-club',
      );
      expect(
        api.votingLinkForClub('demo-club', lang: 'zh'),
        'https://example.com/c/demo-club?lang=zh',
      );
      expect(
        api.votingLinkForClub('demo-club', lang: 'en'),
        'https://example.com/c/demo-club?lang=en',
      );
    });

    test('throws friendly exception from backend error response', () async {
      final OnlineCountApi api = OnlineCountApi(
        baseUrl: 'https://example.com',
        client: MockClient((http.Request request) async {
          return http.Response(
            '{"ok":false,"code":"DUPLICATE_CLUB",'
            '"message":"A club with this slug already exists."}',
            409,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }),
      );

      expect(
        () => api.createClub(
          clubName: 'Demo Club',
          clubSlug: 'demo-club',
          adminPin: '123456',
        ),
        throwsA(
          isA<OnlineCountApiException>()
              .having(
                (OnlineCountApiException error) => error.code,
                'code',
                'DUPLICATE_CLUB',
              )
              .having(
                (OnlineCountApiException error) => error.message,
                'message',
                'A club with this slug already exists.',
              ),
        ),
      );
    });

    test('createOwnerClub sends owner token header', () async {
      late http.Request captured;
      final OnlineCountApi api = OnlineCountApi(
        baseUrl: 'https://example.com',
        client: MockClient((http.Request request) async {
          captured = request;
          return http.Response(
            '{"ok":true,"club":{"clubId":"club-1","clubName":"Demo",'
            '"clubSlug":"demo","status":"active"}}',
            200,
          );
        }),
      );

      final OnlineClub club = await api.createOwnerClub(
        ownerToken: 'owner-token',
        clubName: 'Demo',
        clubSlug: 'demo',
        adminPin: '123456',
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/api/owner/club');
      expect(captured.headers['X-Owner-Token'], 'owner-token');
      expect(club.slug, 'demo');
    });

    test('owner status parses nullable session and award', () async {
      final OnlineCountApi api = OnlineCountApi(
        baseUrl: 'https://example.com',
        client: MockClient((http.Request request) async {
          expect(request.headers['X-Owner-Token'], 'owner-token');
          expect(request.headers['X-Admin-Pin'], '123456');
          return http.Response(
            '{"ok":true,"club":{"clubId":"club-1","clubName":"Demo",'
            '"clubSlug":"demo"},"currentSession":null,"activeAward":null,'
            '"summary":{"hasCurrentSession":false,"hasActiveAward":false,'
            '"canCreateMeeting":true,"canCreateClub":false,'
            '"legacyMultipleSessions":false}}',
            200,
          );
        }),
      );

      final OnlineClubStatus status = await api.getOwnerClubStatus(
        ownerToken: 'owner-token',
        clubSlug: 'demo',
        adminPin: '123456',
      );

      expect(status.currentSession, isNull);
      expect(status.activeAward, isNull);
      expect(status.summary.canCreateMeeting, isTrue);
    });

    test('delete owner endpoints use DELETE with owner and admin headers',
        () async {
      final List<http.Request> requests = <http.Request>[];
      final OnlineCountApi api = OnlineCountApi(
        baseUrl: 'https://example.com',
        client: MockClient((http.Request request) async {
          requests.add(request);
          return http.Response('{"ok":true}', 200);
        }),
      );

      await api.deleteCurrentMeeting(
        ownerToken: 'owner-token',
        sessionId: 'session-1',
        adminPin: '123456',
      );
      await api.deleteOnlineClub(
        ownerToken: 'owner-token',
        clubSlug: 'demo',
        adminPin: '123456',
      );

      expect(requests[0].method, 'DELETE');
      expect(requests[0].url.path, '/api/owner/session/session-1');
      expect(requests[0].headers['X-Owner-Token'], 'owner-token');
      expect(requests[0].headers['X-Admin-Pin'], '123456');
      expect(requests[1].method, 'DELETE');
      expect(requests[1].url.path, '/api/owner/club/demo');
    });

    test('admin session actions include owner token when provided', () async {
      final OnlineCountApi api = OnlineCountApi(
        baseUrl: 'https://example.com',
        client: MockClient((http.Request request) async {
          expect(request.headers['X-Owner-Token'], 'owner-token');
          expect(request.headers['X-Admin-Pin'], '123456');
          return http.Response(
            '{"ok":true,"candidates":[]}',
            200,
          );
        }),
      );

      await api.replaceCandidates(
        sessionId: 'session-1',
        adminPin: '123456',
        ownerToken: 'owner-token',
        awardType: 'best_speaker',
        candidates: <String>['Alice'],
      );
    });
  });
}
