import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/stt_controller.dart';

/// STTVoiceInputPopup
///
/// • initState에서 controller.sendVoiceText()를 호출해 스트리밍을 시작하고,
///   서버의 “final” 응답을 기다립니다.
/// • “취소” 버튼 클릭 시: controller.stopStreaming() 후 팝업만 닫기
/// • “완료” 버튼 클릭 시: sendCompleteSignal()로 종료 신호 전송 → 서버로부터 “final”을 받을 때까지 기다린 뒤 팝업 반환
class STTVoiceInputPopup extends StatefulWidget {
  final STTController controller;

  const STTVoiceInputPopup({
    super.key,
    required this.controller,
  });

  @override
  State<STTVoiceInputPopup> createState() => _STTVoiceInputPopupState();
}

class _STTVoiceInputPopupState extends State<STTVoiceInputPopup> {
  bool _isListening = false;
  bool _hasSentEndSignal = false;
  String _recognizedText = "";
  String _errorText = "";

  /// SendVoiceText() 호출 시 반환된 Future<String>
  late Future<String> _resultFuture;

  @override
  void initState() {
    super.initState();
    _startStreamingAndListen();
  }

  /// 1) 팝업이 뜨면 즉시 스트리밍(오디오 캡처 + WebSocket) 시작
  void _startStreamingAndListen() {
    setState(() {
      _isListening = true;
      _recognizedText = "";
      _errorText = "";
      _hasSentEndSignal = false;
    });

    // sendVoiceText 호출: 서버가 "final" 메시지를 보낼 때 complete
    _resultFuture = widget.controller.sendVoiceText();

    // Future 완료 콜백 설정
    _resultFuture.then((finalText) {
      if (!mounted) return;
      setState(() {
        _recognizedText = finalText;
        _isListening = false;
      });
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.toString();
        _isListening = false;
      });
      // 오류 시 팝업을 닫고 null 반환
      Future.microtask(() {
        Navigator.of(context).pop<String?>(null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 처리 오류: $_errorText')),
        );
      });
    });
  }

  /// 2) “취소” 버튼: 스트리밍 중지 → 팝업 닫기 (null 반환)
  void _onCancelPressed() {
    widget.controller.stopStreaming();
    Navigator.of(context).pop<String?>(null);
  }

  /// 3) “완료” 버튼: 종료 신호 전송 → 서버에서 최종 텍스트 받을 때까지 대기 → 팝업 닫기
  void _onDonePressed() {
    if (_hasSentEndSignal || !_isListening) {
      // 이미 종료 신호를 보냈거나, 인식이 완료된 경우
      final resultText = _recognizedText;
      Navigator.of(context).pop<String?>(resultText.isEmpty ? null : resultText);
    } else {
      // 종료 신호를 아직 보내지 않은 상태일 때
      widget.controller.sendCompleteSignal();
      setState(() {
        _hasSentEndSignal = true;
        // 여전히 _isListening은 true 상태이며, 곧 서버가 final을 보낼 것
      });
      // 버튼을 다시 누르면 위 분기로 넘어가 팝업 닫힘
    }
  }

  @override
  void dispose() {
    // 팝업이 사라질 때 스트리밍이 살아 있다면 반드시 중지
    widget.controller.stopStreaming();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("음성인식 검색"),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h),
          if (_isListening) ...[
            const CircularProgressIndicator(),
            SizedBox(height: 12.h),
            Text(
              _hasSentEndSignal
                  ? "처리를 기다리는 중입니다..."
                  : "음성 인식(오디오 스트리밍) 중입니다...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp),
            ),
          ] else if (_recognizedText.isNotEmpty) ...[
            Text(
              "인식 결과:\n'$_recognizedText'",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp),
            ),
          ] else ...[
            Text(
              _errorText.isNotEmpty
                  ? "오류 발생:\n$_errorText"
                  : "음성 인식 결과가 없습니다.\n“취소” 버튼을 눌러 중단하세요.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _onCancelPressed,
          style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
          child: Text(
            "취소",
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
        TextButton(
          onPressed: _onDonePressed,
          style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
          child: Text(
            _hasSentEndSignal ? "완료 (결과 대기 중)" : "완료",
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }
}
