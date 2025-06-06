import 'dart:async';
import 'dart:convert';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../models/base_url.dart';

/// STTController
/// • recognizeSpeech(): 로컬 음성 인식을 수행하여 최종 결과(finalResult) 문자열 반환
/// • sendTextToServer(rawText): HTTP POST(JSON)로 백엔드에 "{ "text": rawText }" 전송
///   → 서버가 반환한 { "cleaned": "정제된 텍스트" } 를 파싱해 반환
/// • stopListening(): 음성 인식 중지
class STTController {
  late final stt.SpeechToText _speech;
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognized = "";

  Completer<String>? _completer;
  Timer? _timeoutTimer;

  STTController() {
    _speech = stt.SpeechToText();
  }

  /// 마이크 권한 요청
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  /// speech_to_text 초기화
  Future<void> _initSpeech() async {
    if (_isInitialized) return;

    bool micGranted = await _requestMicrophonePermission();
    if (!micGranted) {
      throw Exception('마이크 권한이 없습니다.');
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        // 필요 시 디버깅
        // print('Speech status: $status');
      },
      onError: (error) {
        // 필요 시 디버깅
        print('Speech error: ${error.errorMsg}');
      },
    );

    if (!available) {
      throw Exception('음성 인식 기능을 사용할 수 없습니다.');
    }

    _isInitialized = true;
  }

  /// 음성 인식 시작 → 최종 텍스트(finalResult) 반환
  /// • timeout 동안 finalResult가 안 나오면, interim(마지막 partial) 결과를 반환
  Future<String> recognizeSpeech({Duration timeout = const Duration(seconds: 60)}) async {
    await _initSpeech();

    if (_speech.isListening) {
      _speech.stop();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    _completer = Completer<String>();
    _isListening = true;
    _lastRecognized = "";

    _timeoutTimer = Timer(timeout, () {
      if (_speech.isListening) _speech.stop();
      if (_lastRecognized.isNotEmpty) {
        _completer?.complete(_lastRecognized);
      } else {
        _completer?.completeError('음성 인식 타임아웃: 인식된 단어가 없습니다.');
      }
    });

    _speech.listen(
      localeId: 'ko_KR',
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
      onResult: (stt.SpeechRecognitionResult result) {
        _lastRecognized = result.recognizedWords.trim();
        if (result.finalResult && _isListening) {
          _isListening = false;
          _timeoutTimer?.cancel();
          _speech.stop();
          _completer?.complete(_lastRecognized);
        }
      },
      listenFor: timeout,
    );

    return _completer!.future;
  }

  /// 음성 인식 중단
  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
    _timeoutTimer?.cancel();

    if (!_completer!.isCompleted) {
      if (_lastRecognized.isNotEmpty) {
        _completer?.complete(_lastRecognized);
      } else {
        _completer?.completeError('사용자에 의해 음성 인식이 취소되었습니다.');
      }
    }

    _isListening = false;
  }

  String baseUrl = BaseUrl.baseUrl;

  /// 백엔드에 rawText 전송 → "{ "cleaned": "정제된 텍스트" }" 반환
  Future<String> sendTextToServer(String rawText) async {
    final uri = Uri.parse("$baseUrl/text/nouns");
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': rawText}),
    );

    if (response.statusCode != 200) {
      throw Exception('서버 오류: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final String cleaned = data['cleaned'] as String? ?? "";
    return cleaned.isNotEmpty ? cleaned : rawText;
  }
}
