import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_api.dart';

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
  });
}
