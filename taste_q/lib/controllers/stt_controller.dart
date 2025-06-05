import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/base_url.dart';

/// STTController
///
/// • FlutterAudioCapture.init() → _audioCapture.start() 로 오디오 캡처를 시작하고,
///   PCM(16kHz, 16bit) 형식으로 변환하여 WebSocket으로 FastAPI 서버에 전송합니다.
/// • 서버가 보내오는 JSON 메시지 "type":"interim"/"type":"final" 을 수신하며,
///   "final" 텍스트가 오면 Future를 완료합니다.
///
/// • sendCompleteSignal(): “##END##” 신호를 서버에 보내 최종 스트리밍을 알립니다.
/// • stopStreaming(): 스트리밍을 즉시 중단하고 WebSocket을 닫습니다.
class STTController {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  late WebSocketChannel _channel;

  bool _isStreaming = false;

  /// 최종 텍스트가 도착하면 완료되는 Completer
  Completer<String>? _resultCompleter;

  /// ❶ 마이크 캡처 초기화 → 오디오 스트리밍 → 서버 전송 → 최종 텍스트 반환
  ///
  /// 서버로부터 "type":"final" 메시지를 받으면 Future<String> 을 완료하고,
  /// 내부적으로 오디오 캡처와 WebSocket을 정리합니다.
  Future<String> sendVoiceText() async {
    if (_isStreaming) {
      return Future.error('이미 오디오 스트리밍이 진행 중입니다.');
    }

    _resultCompleter = Completer<String>();
    _isStreaming = true;

    // ───────────────────────────────────────────────────────────────
    // 1) FlutterAudioCapture 초기화
    try {
      await _audioCapture.init();
    } catch (e) {
      _isStreaming = false;
      return Future.error('오디오 캡처 초기화 실패: $e');
    }
    // ───────────────────────────────────────────────────────────────

    // 2) WebSocket 연결
    final httpUrl = BaseUrl.baseUrl; // 예: "http://api.example.com"
    final wsUrl = httpUrl.replaceFirst(RegExp(r'^http'), 'ws') + '/ws/stt';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // 3) 서버 메시지 수신: interim/final 처리 또는 에러 문자열 처리
    _channel.stream.listen(
          (dynamic message) {
        // 서버가 보낸 메시지가 String인 경우만 처리
        if (message is String) {
          // “ERROR: …” 로 시작하는 문자열이면 예외 처리
          if (message.startsWith('ERROR')) {
            if (!_resultCompleter!.isCompleted) {
              _resultCompleter!.completeError(message);
            }
            _stopInternal();
            return;
          }

          // JSON 파싱 시도
          try {
            final Map<String, dynamic> data = jsonDecode(message);

            // 중간 결과(interim) 처리 (필요하다면 UI 반영)
            if (data['type'] == 'interim') {
              // finalText가 길어지는 중간 단계, 무시하거나 로깅만 함
              return;
            }

            // 최종 결과(final)
            if (data['type'] == 'final') {
              final String finalText = data['text'] as String? ?? '';
              if (!_resultCompleter!.isCompleted) {
                _resultCompleter!.complete(finalText);
              }
              _stopInternal();
              return;
            }
          } on FormatException {
            // JSON 파싱 실패: 서버가 보낸 데이터가 JSON이 아닐 수 있음. 무시.
            return;
          } catch (e) {
            // 예기치 않은 오류
            if (!_resultCompleter!.isCompleted) {
              _resultCompleter!.completeError('서버 메시지 처리 오류: $e');
            }
            _stopInternal();
            return;
          }
        }
      },
      onError: (error) {
        if (!_resultCompleter!.isCompleted) {
          _resultCompleter!.completeError('WebSocket 에러: $error');
        }
        _stopInternal();
      },
      onDone: () {
        if (!_resultCompleter!.isCompleted) {
          _resultCompleter!.completeError('WebSocket 연결이 종료되었습니다.');
        }
        _stopInternal();
      },
      cancelOnError: true,
    );

    // 4) 오디오 캡처 시작: Float32List 등을 받아 16-bit PCM으로 변환 → WebSocket 전송
    _audioCapture
        .start(
      // 4-1) listener(dynamic obj): 캡처된 오디오 버퍼 처리
          (dynamic obj) {
        if (!_isStreaming) return;

        Uint8List bytesToSend;

        // (1) Float32List → Int16List(LINEAR16) 변환
        if (obj is Float32List) {
          final Float32List floatBuffer = obj;
          final int len = floatBuffer.length;
          final Int16List int16Buffer = Int16List(len);

          for (int i = 0; i < len; i++) {
            int16Buffer[i] =
                (floatBuffer[i] * 32767).clamp(-32768, 32767).toInt();
          }
          bytesToSend = Uint8List.view(int16Buffer.buffer);
        }
        // (2) Int16List → Uint8List 뷰
        else if (obj is Int16List) {
          bytesToSend = Uint8List.view(obj.buffer);
        }
        // (3) Uint8List 그대로 사용
        else if (obj is Uint8List) {
          bytesToSend = obj;
        }
        // (4) ByteBuffer → Uint8List
        else if (obj is ByteBuffer) {
          bytesToSend = Uint8List.view(obj);
        } else {
          // 지원하지 않는 타입은 무시
          return;
        }

        // 4-2) WebSocket에 바이너리(PCM) 전송
        _channel.sink.add(bytesToSend);
      },

      // 4-3) onError: 캡처 중 오류 발생 시
          (Object e) {
        if (!_isStreaming) return;
        if (!_resultCompleter!.isCompleted) {
          _resultCompleter!.completeError('오디오 캡처 오류: $e');
        }
        _stopInternal();
      },

      // 샘플레이트 / 버퍼 크기
      sampleRate: 16000,
      bufferSize: 3000,
    )
        .catchError((e) {
      // start() 자체 실패 시
      if (!_resultCompleter!.isCompleted) {
        _resultCompleter!.completeError('오디오 캡처 시작 실패: $e');
      }
      _stopInternal();
    });

    // 최종 텍스트가 오면 complete되므로 이 Future를 반환
    return _resultCompleter!.future;
  }

  /// ❷ “##END##” 종료 신호를 서버로 전송
  ///
  /// 백엔드가 이 신호를 받으면, 지금까지 수신된 오디오를 처리해 최종 텍스트를 보냅니다.
  void sendCompleteSignal() {
    if (_isStreaming) {
      _channel.sink.add("##END##");
    }
  }

  /// ❸ 외부에서 스트리밍을 중단(취소)하고 싶을 때 호출
  Future<void> stopStreaming() async {
    if (_isStreaming) {
      // 간단히 내부 정리 로직만 실행
      _stopInternal();
    }
  }

  /// ❹ 내부 정리: 스트리밍 플래그 해제, 오디오 캡처 중지, WebSocket 종료
  void _stopInternal() {
    if (_isStreaming) {
      _isStreaming = false;
      _audioCapture.stop();
      try {
        _channel.sink.close();
      } catch (_) {
        // 이미 닫혔거나 예외가 발생해도 무시
      }
    }
  }

  /// ◉ 현재 스트리밍 중인지 여부 확인
  bool get isStreaming => _isStreaming;
}
