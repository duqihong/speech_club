import 'package:audioplayers/audioplayers.dart';

class DingService {
  DingService._();
  static final DingService instance = DingService._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playDingOnce() async {
    await _player.stop();
    await _player.play(
      AssetSource('sounds/meeting_ding.mp3'),
      volume: 1.0,
    );
  }
}
