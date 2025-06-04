import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class STTController {
  late final stt.SpeechToText _speech;
  bool isInitialized = false;

  STTController() {
    _speech = stt.SpeechToText();
  }

  /// 음성인식 초기화
  Future<void> initSpeech() async {
    if (!isInitialized) {
      isInitialized = await _speech.initialize(
        onStatus: (status) {
          // 필요하다면 상태 변화에 대응할 수 있습니다.
          // print("Speech status: $status");
        },
        onError: (error) {
          // 필요하다면 오류를 로깅하거나 사용자에게 알릴 수 있습니다.
          print("Speech error: $error");
        },
      );
      if (!isInitialized) {
        throw Exception('음성인식 초기화 실패');
      }
    }
  }

  /// 음성인식 시작 → finalResult가 나오는 시점에 Future가 완료되어 결과를 반환
  Future<String> startListening() async {
    if (!isInitialized) {
      await initSpeech();
    }

    final completer = Completer<String>();
    _speech.listen(
      onResult: (val) {
        if (val.finalResult) {
          completer.complete(val.recognizedWords);
          _speech.stop();
        }
      },
      listenFor: const Duration(seconds: 60), // 최대 60초까지 듣습니다.
    );
    return completer.future;
  }

  /// 음성인식이 진행 중이면 중지
  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }
  /// 음성인식이 현재 실행 중인지 여부
  bool get isListening => _speech.isListening;


  // 백엔드로 음성 인식 텍스트 전송 및 정제된 텍스트 반환
  static const String baseUrl = 'http://192.168.219.183:8000';

  // Future<void> sendVoiceText(String voiceText) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/speech-to-text'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'voice_text': voiceText}),
  //   );
  //   if (response.statusCode != 200) {
  //     throw Exception('서버 전송 실패: ${response.statusCode}');
  //   } else {
  //     final jsonResponse = jsonDecode(response.body);
  //     return jsonResponse['cleanedText'] ?? '';
  //   }
  // }

}
