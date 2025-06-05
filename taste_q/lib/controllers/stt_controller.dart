// lib/controllers/stt_controller.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/base_url.dart';

/// STTController
///
/// • FlutterAudioCapture로 마이크 오디오를 캡처하기 전에 반드시 init()을 호출해야 합니다.
/// • PCM 오디오(16kHz, 16bit)로 변환하여 WebSocket으로 스트리밍 전송하고,
///   서버가 보내주는 "interim"/"final" JSON 메시지를 파싱한 뒤,
///   "final" 텍스트를 반환하는 Future<String>을 제공합니다.
///
/// • 서버가 비 JSON 문자열(예: "ERROR: ...")을 보내는 경우,
///   FormatException 대신 해당 메시지를 오류로 처리하도록 분기합니다.
class STTController {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  late WebSocketChannel _channel;

  bool _isStreaming = false;

  /// ○ 마이크 캡처 초기화 → 오디오 스트리밍 → 서버 전송 → 최종 텍스트 반환
  Future<String> sendVoiceText() async {
    if (_isStreaming) {
      return Future.error('이미 오디오 스트리밍이 진행 중입니다.');
    }

    final completer = Completer<String>();
    _isStreaming = true;

    // ───────────────────────────────────────────────────────────────
    // 1) FlutterAudioCapture 초기화 (반드시 먼저)
    try {
      await _audioCapture.init();
    } catch (e) {
      _isStreaming = false;
      return Future.error('오디오 캡처 초기화 실패: $e');
    }
    // ───────────────────────────────────────────────────────────────

    // 2) WebSocket 연결
    final httpUrl = BaseUrl.baseUrl;    // 예: "http://api.example.com"
    final wsUrl = '${httpUrl.replaceFirst(RegExp(r'^http'), 'ws')}/ws/stt';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // 3) 서버 메시지 수신: interim/final 처리 or 에러 문자열 처리
    _channel.stream.listen(
          (dynamic message) {
        // 3-1) 서버가 보낸 데이터가 String인지 먼저 확인
        if (message is String) {
          // "ERROR: ..." 같이 순수 텍스트라면 JSON 파싱 시도 전 분기
          if (message.startsWith('ERROR')) {
            // 서버가 오류 메시지를 보냈을 때: Future 에러로 완료
            if (!completer.isCompleted) {
              completer.completeError(message);
            }
            _stopInternal();
            return;
          }

          // JSON 파싱 시도
          try {
            final Map<String, dynamic> data = jsonDecode(message);

            // 중간 결과(interim) 처리 (필요 시 UI에 반영)
            if (data['type'] == 'interim') {
              // 예: finalText가 길어질 때 중간에 UI 업데이트할 용도로 사용 가능
              // final String interimText = data['text'] as String? ?? '';
              return;
            }

            // 최종 결과(final)
            if (data['type'] == 'final') {
              final String finalText = data['text'] as String? ?? '';
              if (!completer.isCompleted) {
                completer.complete(finalText);
              }
              _stopInternal();
              return;
            }
          } on FormatException catch (_) {
            // JSON 파싱 실패:
            // server에서 보내는 임의 문자열(혹은 다른 포맷)이므로, 무시하거나
            // 필요 시 로깅만 하고 중단하지 않습니다.
            return;
          } catch (e) {
            // 예기치 않은 오류 시
            if (!completer.isCompleted) {
              completer.completeError('서버 메시지 처리 오류: [$e]');
            }
            _stopInternal();
            return;
          }
        } else {
          // message가 String이 아닌 경우(Uint8List 등 바이너리),
          // 이 구현에서는 아무 작업도 하지 않음
          return;
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

    // 4) 오디오 캡처 시작: Float32List 등을 받아 16-bit PCM으로 변환 → 전송
    _audioCapture
        .start(
      // 4-1) listener(dynamic obj): 캡처된 오디오 버퍼를 받아 처리
          (dynamic obj) {
        if (!_isStreaming) return;

        Uint8List bytesToSend;

        // ① Float32List → Int16List(LINEAR16) 변환
        if (obj is Float32List) {
          final Float32List floatBuffer = obj;
          final int len = floatBuffer.length;
          final Int16List int16Buffer = Int16List(len);

          // float [-1.0,1.0] → PCM Int16 [-32768,32767]
          for (int i = 0; i < len; i++) {
            final value = (floatBuffer[i] * 32767).toInt().clamp(-32768, 32767);
            int16Buffer[i] = value;
          }
          bytesToSend = Uint8List.view(int16Buffer.buffer);
        }
        // ② Int16List(16-bit PCM) → 바로 Uint8List 뷰로 변환
        else if (obj is Int16List) {
          bytesToSend = Uint8List.view(obj.buffer);
        }
        // ③ Uint8List(이미 raw 바이트) → 그대로 사용
        else if (obj is Uint8List) {
          bytesToSend = obj;
        }
        // ④ ByteBuffer → Uint8List로 변환
        else if (obj is ByteBuffer) {
          bytesToSend = Uint8List.view(obj);
        }
        // ⑤ 그 외 타입: 지원하지 않으므로 무시
        else {
          return;
        }

        // 4-2) WebSocket에 PCM 바이너리를 전송
        _channel.sink.add(bytesToSend);
      },

      // 4-3) onError(Object e): 캡처 중 예외 발생 시 Future 에러로 완료 후 정리
          (Object e) {
        if (!_isStreaming) return;
        if (!completer.isCompleted) {
          completer.completeError('오디오 캡처 오류: $e');
        }
        _stopInternal();
      },

      sampleRate: 16000, // 샘플레이트 16kHz
      bufferSize: 3000,  // 버퍼 크기(바이트 단위)
    )
        .catchError((e) {
      // start() 호출 자체 실패 시
      if (!completer.isCompleted) {
        completer.completeError('오디오 캡처 시작 실패: $e');
      }
      _stopInternal();
    });

    return completer.future;
  }

  /// ○ 외부에서 호출: 스트리밍 중단(취소) 요청
  Future<void> stopStreaming() async {
    if (_isStreaming) {
      _stopInternal();
    }
  }

  /// ○ 내부 정리: 오디오 캡처 중지 + WebSocket 연결 종료
  void _stopInternal() {
    if (_isStreaming) {
      _isStreaming = false;
      _audioCapture.stop();
      try {
        _channel.sink.close();
      } catch (_) {
        // 이미 닫혔거나 오류가 발생해도 무시
      }
    }
  }

  /// ○ 현재 스트리밍 중인지 여부 조회
  bool get isStreaming => _isStreaming;
}
