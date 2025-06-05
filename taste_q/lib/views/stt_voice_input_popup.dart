import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/stt_controller.dart';

/// 음성인식 팝업을 별도 위젯으로 분리
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

  /// 1) 팝업이 떠오르면 즉시 오디오 스트리밍을 시작하고, 서버의 최종 메시지를 기다림
  void _startStreamingAndListen() {
    setState(() {
      _isListening = true;
      _recognizedText = "";
      _errorText = "";
    });

    widget.controller.sendVoiceText().then((finalText) {
      if (mounted) {
        setState(() {
          _recognizedText = finalText;
          _isListening = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _errorText = error.toString();
          _isListening = false;
        });
        // 오류가 발생하면 자동으로 팝업 닫고 null 반환
        Future.microtask(() {
          Navigator.of(context).pop<String?>(null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('서버 처리 오류: $_errorText')),
          );
        });
      }
    });
  }

  /// “취소” 버튼: 즉시 스트리밍 중지 후 null 반환
  void _onCancelPressed() {
    widget.controller.stopStreaming();
    Navigator.of(context).pop<String?>(null);
  }

  /// “완료” 버튼: 서버에서 최종 결과가 이미 왔다면 해당 텍스트 반환
  void _onDonePressed() {
    widget.controller.stopStreaming();
    if (_recognizedText.isNotEmpty) {
      Navigator.of(context).pop<String?>(_recognizedText);
    } else {
      // 아직 서버 최종 응답을 못 받았거나 오류가 있을 때
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
