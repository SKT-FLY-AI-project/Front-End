import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize();
    }
    return _isInitialized;
  }

  Future<String?> startListening() async {
    if (!await initialize()) {
      throw Exception('Failed to initialize speech recognition');
    }

    String recognizedText = '';
    await _speech.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
      },
      localeId: 'ko-KR', // Korean language support
    );
    print(recognizedText);
    // Wait for speech recognition to complete
    await Future.delayed(const Duration(seconds: 5));
    await _speech.stop();

    return recognizedText.isNotEmpty ? recognizedText : null;
  }

  // 음성 인식 중지 메서드
  Future<void> stopListening() async {
    // 실제 구현에서는 사용 중인 음성 인식 서비스를 중지
    // 이 예제에서는 간단히 지연만 추가
    await Future.delayed(const Duration(milliseconds: 300));

    // 추가적인 정리 작업이 필요하면 여기서 수행
    print('음성 인식이 중지되었습니다.');
  }
}