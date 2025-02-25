import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class TTSPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAudio(Uint8List audioBytes) async {
    try {
      print("🎵 오디오 재생 시작...");
      await _audioPlayer.play(BytesSource(audioBytes));
      print("✅ 오디오 재생 성공!");
    } catch (e) {
      print("⚠️ 오디오 재생 오류: $e");
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // setVolume 메서드: AudioPlayer의 볼륨을 설정합니다.
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }
}
