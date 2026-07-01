import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_club/features/vote_bests/data/online_count/online_count_qr_share_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('creates voting QR PNG file with club code and language code', () async {
    final Directory tempDirectory =
        await Directory.systemTemp.createTemp('speech_club_qr_test_');
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final File file = await createVotingQrPngFile(
      url:
          'https://speech-club-vote.duduqihong.workers.dev/c/demo-club?lang=en',
      clubCode: 'demo-club',
      languageCode: 'en',
      directory: tempDirectory,
    );

    expect(file.path, endsWith('speech_club_voting_qr_demo-club_en.png'));
    expect(file.path, endsWith('.png'));
    expect(await file.length(), greaterThan(0));
  });

  test('sanitizes voting QR PNG filename parts', () {
    expect(
      buildVotingQrPngFileName(
        clubCode: 'Demo Club / Main',
        languageCode: 'zh',
      ),
      'speech_club_voting_qr_Demo-Club-Main_zh.png',
    );
  });

  test('builds localized voting QR share text', () {
    expect(
      buildVotingQrShareText(clubName: 'Demo Club', languageCode: 'en'),
      contains('Demo Club'),
    );
    expect(
      buildVotingQrShareText(clubName: 'Demo Club', languageCode: 'en'),
      contains('reused for every meeting'),
    );
    expect(
      buildVotingQrShareText(clubName: '示范', languageCode: 'zh'),
      contains('示范'),
    );
    expect(
      buildVotingQrShareText(clubName: '示范', languageCode: 'zh'),
      contains('二维码'),
    );
  });
}
