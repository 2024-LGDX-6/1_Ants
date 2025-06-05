import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/base_url.dart';

/// FlutterAudioCapture 마이크 오디오를 캡처하기 전에 반드시 init()을 호출,
/// PCM 오디오(16kHz, 16bit)로 변환하여 WebSocket으로 스트리밍 전송하고,
/// 서버가 보내주는 "final" 텍스트를 반환하는 Future<String> 기능을 제공합니다.
class STTController {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  late WebSocketChannel _channel;

  bool _isStreaming = false;

  /// 1) 마이크 캡처 초기화 → 오디오 스트리밍 → 서버 전송 → 최종 텍스트 반환
  Future<String> sendVoiceText() async {
    if (_isStreaming) {
      return Future.error('이미 오디오 스트리밍이 진행 중입니다.');
    }

    final completer = Completer<String>();
    _isStreaming = true;

    // FlutterAudioCapture 초기화
    try {
      await _audioCapture.init();
    } catch (e) {
      _isStreaming = false;
      return Future.error('오디오 캡처 초기화 실패: $e');
    }

    // 2) WebSocket 연결
    final httpUrl = BaseUrl.baseUrl; // 예: "http://api.example.com"
    final wsUrl = '${httpUrl.replaceFirst(RegExp(r'^http'), 'ws')}/ws/stt';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // 3) 서버 메시지 수신: interim/final 처리
    _channel.stream.listen(
          (dynamic message) {
        try {
          final Map<String, dynamic> data = jsonDecode(message as String);

          if (data['type'] == 'interim') {
            // 중간 결과(interim)는 여기서 로깅만 가능
            return;
          }
          if (data['type'] == 'final') {
            final String finalText = data['text'] as String? ?? '';
            if (!completer.isCompleted) {
              completer.complete(finalText);
            }
            _stopInternal(); // 최종 결과 수신 시 오디오 캡처 및 소켓 정리
            return;
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError('서버 메시지 처리 오류: $e');
          }
          _stopInternal();
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError('WebSocket 에러: $error');
        }
        _stopInternal();
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError('WebSocket 연결이 종료되었습니다.');
        }
        _stopInternal();
      },
      cancelOnError: true,
    );

    // 4) 오디오 캡처 시작: Float32List를 Int16List 로 변환 → WebSocket으로 전송
    _audioCapture
        .start(
      // listener: 캡처된 audio 버퍼(dynamic obj) 처리
          (dynamic obj) {
        if (!_isStreaming) return;

        Uint8List bytesToSend;

        // (1) Float32List → Int16List (LINEAR16) 변환
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
        // (2) Int16List (이미 16bit PCM)
        else if (obj is Int16List) {
          bytesToSend = Uint8List.view(obj.buffer);
        }
        // (3) Uint8List (raw bytes)
        else if (obj is Uint8List) {
          bytesToSend = obj;
        }
        // (4) ByteBuffer → Uint8List
        else if (obj is ByteBuffer) {
          bytesToSend = Uint8List.view(obj);
        }
        // 지원하지 않는 타입은 무시
        else {
          return;
        }

        // WebSocket으로 바이너리 전송
        _channel.sink.add(bytesToSend);
      },

      // onError: 오디오 캡처 중 예외 처리
          (Object e) {
        if (!_isStreaming) return;
        if (!completer.isCompleted) {
          completer.completeError('오디오 캡처 오류: $e');
        }
        _stopInternal();
      },

      // sampleRate: 16kHz, bufferSize: 3000 바이트
      sampleRate: 16000,
      bufferSize: 3000,
    )
        .catchError((e) {
      if (!completer.isCompleted) {
        completer.completeError('오디오 캡처 시작 실패: $e');
      }
      _stopInternal();
    });

    return completer.future;
  }

  /// 5) 외부에서 스트리밍을 중단하고 싶을 때 호출
  Future<void> stopStreaming() async {
    if (_isStreaming) {
      _stopInternal();
    }
  }

  /// 6) 내부 정리: 스트리밍 플래그 해제, 오디오 캡처 중지, WebSocket 종료
  void _stopInternal() {
    if (_isStreaming) {
      _isStreaming = false;
      _audioCapture.stop();
      try {
        _channel.sink.close();
      } catch (_) {
        // 이미 닫혔거나 예외 발생 시 무시
      }
    }
  }

  /// 7) 현재 스트리밍 중인지 여부 조회
  bool get isStreaming => _isStreaming;
}
