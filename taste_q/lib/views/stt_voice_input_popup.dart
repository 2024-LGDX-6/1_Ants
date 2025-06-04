import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/stt_controller.dart';

/// 음성인식 팝업을 별도 위젯으로 분리
class STTVoiceInputPopup extends StatefulWidget {
  final STTController controller;

  const STTVoiceInputPopup({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<STTVoiceInputPopup> createState() => _STTVoiceInputPopupState();
}

class _STTVoiceInputPopupState extends State<STTVoiceInputPopup> {
  bool _isListening = false;
  String _recognizedText = "";

  @override
  void initState() {
    super.initState();

    // 팝업이 뜨자마자 음성인식 초기화 후 바로 듣기 시작
    widget.controller.initSpeech().then((_) {
      setState(() => _isListening = true);

      // startListening()이 완료되면 recognizedText에 저장
      widget.controller.startListening().then((value) {
        if (mounted) {
          setState(() {
            _recognizedText = value;
            _isListening = false;
          });
        }
      }).catchError((error) {
        // 에러 시 팝업을 닫고 알림 표시
        if (mounted) {
          Navigator.of(context).pop<String?>(null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('음성인식 오류: $error')),
          );
        }
      });
    }).catchError((error) {
      // 초기화 실패 시 팝업 닫고 오류 표시
      if (mounted) {
        Navigator.of(context).pop<String?>(null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('음성인식 초기화 실패: $error')),
        );
      }
    });
  }

  /// “취소” 버튼: 음성인식 중지 후 null 반환
  void _onCancelPressed() {
    widget.controller.stopListening();
    Navigator.of(context).pop<String?>(null);
  }

  /// “완료” 버튼: 음성인식 중지 후 현재까지 인식된 텍스트 반환
  void _onDonePressed() {
    widget.controller.stopListening();
    Navigator.of(context).pop<String?>(_recognizedText);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("음성인식 검색"),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h,),
          Text(
            _isListening
                ? "음성인식 중입니다..."
                : (_recognizedText.isEmpty
                ? "아직 인식된 음성이 없습니다"
                : "인식 결과:\n'$_recognizedText'"),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.sp,),
          ),
          if (!_isListening && _recognizedText.isEmpty)
            Text(
              "음성인식 결과가 없습니다.\n취소 버튼을 눌러 중단하세요.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp,),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _onCancelPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
          ),
          child: Text(
            "취소",
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
        TextButton(
          onPressed: _onDonePressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
          ),
          child: const Text(
            "완료",
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }
}
