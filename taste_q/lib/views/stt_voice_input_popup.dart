import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/stt_controller.dart';


/// 1) initState에서 `controller.sendVoiceText()`를 호출하여
///    - 마이크 오디오 스트리밍 시작 → 서버로 PCM 전송
///    - 서버가 보내주는 JSON을 수신하며, "type":"final" 텍스트를 받아 `Future<String>` 완성
/// 2) 중간(interim)은 표시하지 않고, 로딩 인디케이터로만 대체
/// 3) "취소" 버튼 → `controller.stopStreaming()`만 호출, 팝업 닫으며 null 반환
/// 4) 서버에서 "final"을 보내면 `_recognizedText`에 저장 → 인디케이터 종료
/// 5) “완료” 버튼 → 이미 `_recognizedText`가 있다면 팝업 닫으며 그 값을 반환
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
  String _recognizedText = "";
  String _errorText = "";

  @override
  void initState() {
    super.initState();
    _startStreamingAndListen();
  }

  /// 1) initState에서 호출: sendVoiceText() 실행 → 서버 final 텍스트 대기
  void _startStreamingAndListen() {
    setState(() {
      _isListening = true;
      _recognizedText = "";
      _errorText = "";
    });

    // sendVoiceText()가 실행되는 순간부터:
    // • 오디오 캡처 → PCM 전송 → 서버에서 interim/final 메시지 수신
    widget.controller.sendVoiceText().then((finalText) {
      // 서버에서 “type":"final"”을 보낼 때
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
      // 오류 발생 시 잠시 뒤에 팝업 닫고 알림 표시
      Future.microtask(() {
        Navigator.of(context).pop<String?>(null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 처리 오류: $_errorText')),
        );
        print('서버 처리 오류: $_errorText');
      });
    });
  }

  /// “취소” 버튼: 중간에 스트리밍 중지 + 팝업 닫기 (null 반환)
  void _onCancelPressed() {
    widget.controller.stopStreaming();
    Navigator.of(context).pop<String?>(null);
  }

  /// “완료” 버튼: 서버에서 받은 최종 텍스트가 있다면 반환, 없으면 null 반환
  void _onDonePressed() {
    widget.controller.stopStreaming();
    if (_recognizedText.isNotEmpty) {
      Navigator.of(context).pop<String?>(_recognizedText);
    } else {
      Navigator.of(context).pop<String?>(null);
    }
  }

  @override
  void dispose() {
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
              "음성 인식(오디오 스트리밍) 중입니다...",
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
                  : "음성 인식 결과가 없습니다.\n취소 버튼을 눌러 중단하세요.",
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
          child: const Text(
            "완료",
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }
}
