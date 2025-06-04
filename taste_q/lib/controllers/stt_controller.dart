import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class STTController {
  late stt.SpeechToText _speech;
  bool isInitialized = false;

  STTController() {
    _speech = stt.SpeechToText();
  }

  // 음성인식 초기화
  Future<void> initSpeech() async {
    isInitialized = await _speech.initialize();
    if (!isInitialized) {
      throw Exception('음성인식 초기화 실패');
    }
  }

  // 음성인식 텍스트 전송 및 결과 반환
  Future<String> startListening() async {
    if (!isInitialized) await initSpeech();

    Completer<String> completer = Completer();
    _speech.listen(
      onResult: (val) {
        if (val.finalResult) {
          completer.complete(val.recognizedWords);
          _speech.stop();
        }
      },
      listenFor: const Duration(seconds: 5),
    );
    return completer.future;
  }

  static const String baseUrl = 'http://192.168.219.183:8000';

  // 백엔드로 음성 인식 텍스트 전송 및 정제된 텍스트 반환
  Future<void> sendVoiceText(String voiceText) async {
    final response = await http.post(
      Uri.parse('$baseUrl/speech-to-text'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'voice_text': voiceText}),
    );
    if (response.statusCode != 200) {
      throw Exception('서버 전송 실패: ${response.statusCode}');
    } else {
      // final jsonResponse = jsonDecode(response.body);
      // return jsonResponse['cleanedText'] ?? '';
    }
  }
}
