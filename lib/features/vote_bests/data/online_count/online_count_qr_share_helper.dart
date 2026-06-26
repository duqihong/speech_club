import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

const double _qrImageSize = 1024;
const double _qrQuietZone = 64;

String buildVotingQrPngFileName({
  required String clubCode,
  required String languageCode,
}) {
  final String safeClubCode = _sanitizeFilePart(clubCode, fallback: 'club');
  final String safeLanguageCode =
      _sanitizeFilePart(languageCode, fallback: 'auto');
  return 'speech_club_voting_qr_${safeClubCode}_$safeLanguageCode.png';
}

String buildVotingQrShareText({
  required String clubName,
  required String languageCode,
}) {
  if (languageCode == 'zh') {
    return '$clubName 演讲俱乐部投票二维码。\n此二维码可重复用于每次会议。';
  }
  return 'Speech Club voting QR code for $clubName.\n'
      'This QR code can be reused for every meeting.';
}

Future<File> createVotingQrPngFile({
  required String url,
  required String clubCode,
  required String languageCode,
  Directory? directory,
}) async {
  final String fileName = buildVotingQrPngFileName(
    clubCode: clubCode,
    languageCode: languageCode,
  );
  final Directory targetDirectory = directory ?? Directory.systemTemp;
  if (!targetDirectory.existsSync()) {
    await targetDirectory.create(recursive: true);
  }

  final File file = File(
    '${targetDirectory.path}${Platform.pathSeparator}$fileName',
  );
  final Uint8List pngBytes = await _buildQrPngBytes(url);
  return file.writeAsBytes(pngBytes, flush: true);
}

Future<void> shareVotingQrCode({
  required String url,
  required String clubName,
  required String clubCode,
  required String languageCode,
  required String shareText,
}) async {
  final File file = await createVotingQrPngFile(
    url: url,
    clubCode: clubCode,
    languageCode: languageCode,
  );
  final String fileName = file.uri.pathSegments.last;
  await SharePlus.instance.share(
    ShareParams(
      files: <XFile>[
        XFile(
          file.path,
          mimeType: 'image/png',
          name: fileName,
        ),
      ],
      fileNameOverrides: <String>[fileName],
      subject: 'Speech Club voting QR code for $clubName',
      text: shareText,
    ),
  );
}

Future<Uint8List> _buildQrPngBytes(String url) async {
  final QrPainter painter = QrPainter(
    data: url,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.H,
    gapless: true,
  );
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);
  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, _qrImageSize, _qrImageSize),
    ui.Paint()..color = const ui.Color(0xFFFFFFFF),
  );
  canvas.save();
  canvas.translate(_qrQuietZone, _qrQuietZone);
  painter.paint(
    canvas,
    const ui.Size(
      _qrImageSize - (_qrQuietZone * 2),
      _qrImageSize - (_qrQuietZone * 2),
    ),
  );
  canvas.restore();

  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(
    _qrImageSize.toInt(),
    _qrImageSize.toInt(),
  );
  final ByteData? byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  image.dispose();
  picture.dispose();
  if (byteData == null) {
    throw StateError('Could not render QR PNG.');
  }
  return byteData.buffer.asUint8List();
}

String _sanitizeFilePart(String value, {required String fallback}) {
  final String sanitized = value
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return sanitized.isEmpty ? fallback : sanitized;
}
