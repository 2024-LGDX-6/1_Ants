import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/base_url.dart';

/// STTController는 FlutterAudioCapture와 WebSocket을 통합하여
/// 마이크에서 실시간 PCM 오디오를 캡처하고 FastAPI 서버로 전송하여
/// 서버에서 최종 텍스트를 받아 반환하는 단일 클래스를 제공합니다.
class STTController {
  /// FlutterAudioCapture 인스턴스: 마이크 캡처 담당
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();

  /// WebSocketChannel 인스턴스: 서버와의 WebSocket 연결 담당
  late WebSocketChannel _channel;

  /// 현재 오디오 스트리밍이 실행 중인지 여부를 나타냅니다.
  bool _isStreaming = false;

  /// 1) sendVoiceText(): 오디오 스트리밍을 시작하고 최종 텍스트를 반환
  /// - WebSocket 연결을 열고 FlutterAudioCapture로부터 받은 PCM 오디오 데이터를
  ///   소켓을 통해 실시간으로 서버에 전송합니다.
  /// - 서버에서 { "type": "final", "text": "..." } 형식의 JSON 메시지를 받으면
  ///   Future를 완료하여 최종 텍스트를 반환하고 내부 스트리밍을 중단합니다.
  Future<String> sendVoiceText() {
    // 이미 스트리밍 중이라면 에러 반환
    if (_isStreaming) {
      return Future.error('이미 스트리밍 중입니다.');
    }

    final completer = Completer<String>();
    _isStreaming = true;

    // 1-1) WebSocketService 초기화 및 콜백 설정
    void onFinalText(String finalText) {
      if (!_isStreaming) return;
      // 서버에서 최종 텍스트를 받으면 Future를 완료
      if (!completer.isCompleted) {
        completer.complete(finalText);
      }
      _stopInternal(); // 오디오 스트리밍과 WebSocket 연결 모두 종료
    }

    // 1-2) WebSocket 연결 시도 (http:// -> ws:// 변환)
    final httpUrl = BaseUrl.baseUrl; // 예: "http://api.example.com"
    final wsUrl = "${httpUrl.replaceFirst(RegExp(r"^http"), "ws")}/ws/stt";
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // 1-3) 서버로부터 수신되는 메시지 처리
    _channel.stream.listen(
          (message) {
        try {
          final Map<String, dynamic> data = jsonDecode(message);
          if (data['type'] == 'final') {
            final String text = data['text'] as String? ?? '';
            onFinalText(text);
          }
          // TODO: 필요 시 interim 처리 가능
        } catch (e) {
          // JSON 파싱 오류 또는 unexpected format
          if (!completer.isCompleted) {
            completer.completeError('서버 응답 처리 오류: \n$e');
          }
          _stopInternal();
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError('WebSocket 에러: \n$error');
        }
        _stopInternal();
      },
      onDone: () {
        // 연결이 종료될 경우 아직 Future가 완료되지 않았다면 에러 발생
        if (!completer.isCompleted) {
          completer.completeError('WebSocket 연결이 종료되었습니다.');
        }
        _stopInternal();
      },
      cancelOnError: true,
    );

    // 1-4) 마이크 오디오 캡처 시작: listener와 onError를 포지셔널 파라미터로 전달
    _audioCapture.start(
      // listener: 캡처된 오디오 데이터를 받은 후 WebSocket 전송
          (dynamic obj) {
        if (!_isStreaming) return;
        late Uint8List audioChunk;
        if (obj is Uint8List) {
          audioChunk = obj;
        } else if (obj is Int16List || obj is Float32List || obj is Float64List) {
          audioChunk = Uint8List.view((obj as TypedData).buffer);
        } else if (obj is ByteBuffer) {
          audioChunk = Uint8List.view(obj);
        } else {
          return; // 지원하지 않는 타입
        }
        _channel.sink.add(audioChunk);
      },
      // onError: 캡처 중 오류 발생 시 처리
          (Object e) {
        if (!_isStreaming) return;
        if (!completer.isCompleted) {
          completer.completeError('오디오 캡처 에러: \n$e');
        }
        _stopInternal();
      },
      sampleRate: 16000,  // 샘플레이트 16kHz
      bufferSize: 3000,   // 버퍼 크기
    );

    return completer.future;
  }

  /// 2) stopStreaming(): 외부에서 호출하여 즉시 스트리밍/소켓 종료
  Future<void> stopStreaming() async {
    if (_isStreaming) {
      _stopInternal();
    }
  }

  /// 3) _stopInternal(): 내부적으로 오디오 캡처와 WebSocket 연결을 정리
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

  /// 스트리밍 상태를 반환
  bool get isStreaming => _isStreaming;
}
