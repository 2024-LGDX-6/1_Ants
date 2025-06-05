import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/base_url.dart';

/// STTController
///
/// • FlutterAudioCapture를 통해 마이크에서 실시간 오디오를 캡처할 때,
///   기본적으로 Float32List 포맷으로 전달됩니다. 이를 16-bit PCM LINEAR16(Int16)으로
///   변환하여 WebSocket으로 FastAPI 서버에 전송합니다.
/// • sendVoiceText()가 호출되면:
///   1) 마이크 권한 요청
///   2) FlutterAudioCapture.init() → start(listener, onError, sampleRate, bufferSize)
///   3) 서버로 PCM 바이너리 전송
///   4) 서버에서 "type":"final" 메시지를 받을 때 Future<String>을 완료
///
/// • sendCompleteSignal(): “##END##” 신호를 서버에 보내어
///   최종 음성 스트리밍 종료를 알립니다.
/// • stopStreaming(): 즉시 오디오 캡처와 WebSocket 연결을 종료합니다.
class STTController {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  late WebSocketChannel _channel;

  bool _isStreaming = false;
  Completer<String>? _resultCompleter;

  /// ◉ 마이크 권한 요청 (비동기)
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  /// ○ 오디오 스트리밍 → 서버 전송 → 최종 텍스트 반환
  ///
  /// • start() 전에 반드시 _audioCapture.init() 호출
  /// • sampleRate와 bufferSize를 STT와 일치시킵니다.
  Future<String> sendVoiceText() async {
    if (_isStreaming) {
      return Future.error('이미 오디오 스트리밍이 진행 중입니다.');
    }

    // 1) 마이크 권한 확인
    bool micGranted = await _requestMicrophonePermission();
    if (!micGranted) {
      return Future.error('마이크 권한이 없습니다.');
    }

    _resultCompleter = Completer<String>();
    _isStreaming = true;

    // ────────────────────────────────────────────────────────────────────
    // 2) FlutterAudioCapture 초기화
    try {
      await _audioCapture.init();
      print('[STTController] AudioCapture initialized successfully.');
    } catch (e) {
      _isStreaming = false;
      return Future.error('오디오 캡처 초기화 실패: $e');
    }
    // ────────────────────────────────────────────────────────────────────

    // ────────────────────────────────────────────────────────────────────
    // 3) WebSocket 연결
    final httpUrl = BaseUrl.baseUrl; // 예: "http://api.example.com"
    final wsUrl = httpUrl.replaceFirst(RegExp(r'^http'), 'ws') + '/ws/stt';
    print('[STTController] Connecting to WebSocket at $wsUrl');
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    // ────────────────────────────────────────────────────────────────────

    // ────────────────────────────────────────────────────────────────────
    // 4) 서버 메시지 수신: interim/final or 비 JSON 문자열 처리
    _channel.stream.listen(
          (dynamic message) {
        if (message is String) {
          // 서버가 “ERROR: …” 문자열만 전송한 경우
          if (message.startsWith('ERROR')) {
            print('[STTController][WebSocket] Received error string: $message');
            if (!_resultCompleter!.isCompleted) {
              _resultCompleter!.completeError(message);
            }
            _stopInternal();
            return;
          }

          // JSON 파싱 시도
          try {
            final Map<String, dynamic> data = jsonDecode(message);
            final String type = data['type'] as String? ?? '';

            if (type == 'interim') {
              // 중간 결과
              final String interimText = data['text'] as String? ?? '';
              print('[STTController][WebSocket][interim] $interimText');
              return;
            }

            if (type == 'final') {
              // 최종 결과
              final String finalText = data['text'] as String? ?? '';
              print('[STTController][WebSocket][final] $finalText');
              if (!_resultCompleter!.isCompleted) {
                _resultCompleter!.complete(finalText);
              }
              _stopInternal();
              return;
            }
          } on FormatException {
            // JSON 파싱 실패(비 JSON 메시지) → 그냥 무시
            print('[STTController][WebSocket] Received non-JSON text: $message');
            return;
          } catch (e) {
            print('[STTController][WebSocket] JSON 처리 오류: $e');
            if (!_resultCompleter!.isCompleted) {
              _resultCompleter!.completeError('서버 메시지 처리 오류: $e');
            }
            _stopInternal();
            return;
          }
        }
      },
      onError: (error) {
        print('[STTController][WebSocket] Error: $error');
        if (!_resultCompleter!.isCompleted) {
          _resultCompleter!.completeError('WebSocket 에러: $error');
        }
        _stopInternal();
      },
      onDone: () {
        print('[STTController][WebSocket] Connection closed');
        if (!_resultCompleter!.isCompleted) {
          _resultCompleter!.completeError('WebSocket 연결이 종료되었습니다.');
        }
        _stopInternal();
      },
      cancelOnError: true,
    );
    // ────────────────────────────────────────────────────────────────────

    // ────────────────────────────────────────────────────────────────────
    // 5) 오디오 캡처 시작: 기본 포맷(Float32List 등)을 Int16List(LINEAR16)으로 변환 후 전송
    //
    //    • sampleRate:16000, bufferSize:2048~4096 권장
    //
    _audioCapture
        .start(
      // listener(dynamic obj): 캡처된 오디오 버퍼 처리
          (dynamic obj) {
        if (!_isStreaming) return;

        Uint8List bytesToSend;
        int incomingLength = 0;

        // Float32List → Int16List(Line ar16) 변환
        if (obj is Float32List) {
          final Float32List floatBuffer = obj;
          final int len = floatBuffer.length;
          final Int16List int16Buffer = Int16List(len);

          for (int i = 0; i < len; i++) {
            int16Buffer[i] =
                (floatBuffer[i] * 32767).clamp(-32768, 32767).toInt();
          }
          bytesToSend = Uint8List.view(int16Buffer.buffer);
          incomingLength = bytesToSend.length;
          print('[STTController][AudioListener] Float32List → Int16List, length=$incomingLength');
        }
        // Int16List → Uint8List 뷰
        else if (obj is Int16List) {
          bytesToSend = Uint8List.view(obj.buffer);
          incomingLength = bytesToSend.length;
          print('[STTController][AudioListener] Received Int16List, length=$incomingLength');
        }
        // Uint8List (이미 PCM 바이트)
        else if (obj is Uint8List) {
          bytesToSend = obj;
          incomingLength = bytesToSend.length;
          print('[STTController][AudioListener] Received Uint8List, length=$incomingLength');
        }
        // ByteBuffer → Uint8List
        else if (obj is ByteBuffer) {
          bytesToSend = Uint8List.view(obj);
          incomingLength = bytesToSend.length;
          print('[STTController][AudioListener] Received ByteBuffer, length=$incomingLength');
        }
        // 그 외 타입은 무시
        else {
          print('[STTController][AudioListener] Unsupported buffer type: ${obj.runtimeType}');
          return;
        }

        // 버퍼 크기가 640 byte 미만이면 경고
        if (incomingLength < 640) {
          print(
              '[STTController][WARN] Received too-small buffer: $incomingLength bytes. '
                  '정상적인 16kHz PCM은 640~1280 byte 이상이어야 합니다.'
          );
        }

        // WebSocket으로 바이너리 전송
        _channel.sink.add(bytesToSend);
      },

      // onError(Object e): 캡처 중 예외 발생 시 처리
          (Object e) {
        if (!_isStreaming) return;
        print('[STTController][AudioListener] Error: $e');
        if (!_resultCompleter!.isCompleted) {
          _resultCompleter!.completeError('오디오 캡처 오류: $e');
        }
        _stopInternal();
      },

      // sampleRate:16kHz, bufferSize:2048 (권장: 2048~4096)
      sampleRate: 16000,
      bufferSize: 2048,
    )
        .then((_) {
      print('[STTController][AudioListener] start() succeeded.');
    })
        .catchError((e) {
      if (!_resultCompleter!.isCompleted) {
        _resultCompleter!.completeError('오디오 캡처 시작 실패: $e');
      }
      _stopInternal();
    });
    // ────────────────────────────────────────────────────────────────────

    return _resultCompleter!.future;
  }

  /// ○ “##END##” 종료 신호를 서버로 전송
  void sendCompleteSignal() {
    if (_isStreaming) {
      print('[STTController] Sending END signal to server.');
      _channel.sink.add("##END##");
    }
  }

  /// ○ 외부에서 스트리밍 중단(취소) 요청
  Future<void> stopStreaming() async {
    if (_isStreaming) {
      print('[STTController] stopStreaming() called.');
      _stopInternal();
    }
  }

  /// ○ 내부 정리: 스트리밍 플래그 해제, 오디오 캡처 중지, WebSocket 종료
  void _stopInternal() {
    if (_isStreaming) {
      _isStreaming = false;
      _audioCapture.stop();
      try {
        _channel.sink.close();
      } catch (_) {
        // 이미 닫혔거나 예외 발생 시 무시
      }
      print('[STTController] Streaming stopped and resources released.');
    }
  }

  /// ○ 현재 스트리밍 중인지 여부
  bool get isStreaming => _isStreaming;
}
