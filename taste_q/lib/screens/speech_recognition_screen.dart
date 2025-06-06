import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/stt_controller.dart';
import 'package:taste_q/screens/recipe_list_screen.dart';
import 'package:taste_q/models/route_entry_type.dart';

class SpeechRecognitionScreen extends StatefulWidget {
  const SpeechRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<SpeechRecognitionScreen> createState() => _SpeechRecognitionScreenState();
}

class _SpeechRecognitionScreenState extends State<SpeechRecognitionScreen> {
  final STTController _controller = STTController();

  bool _isInitializing = true;
  bool _isListening = false;
  String _recognizedText = "";
  bool _hasError = false;
  String _errorMsg = "";

  String _cleanedText = "";
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initAndListen();
  }

  Future<void> _initAndListen() async {
    setState(() {
      _isInitializing = true;
      _isListening = false;
      _recognizedText = "";
      _hasError = false;
      _errorMsg = "";
    });

    try {
      String spoken = await _controller.recognizeSpeech(
          timeout: const Duration(seconds: 60)
      );
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _recognizedText = spoken;
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _hasError = true;
        _errorMsg = e.toString();
      });
    }
  }

  Future<void> _onDonePressed() async {
    if (_hasError) return;

    if (_isListening || _isInitializing) {
      _controller.stopListening();
    }

    final raw = _recognizedText.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아직 인식된 내용이 없습니다.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      String cleaned = await _controller.sendTextToServer(raw);
      if (!mounted) return;
      setState(() {
        _cleanedText = cleaned;
        _isSending = false;
      });

      // 레시피 목록 화면으로 이동 (뒤로가면 메인으로)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RecipeListScreen(
            searchQuery: _cleanedText,
            routeEntryType: RouteEntryType.anotherDefault,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _hasError = true;
        _errorMsg = "서버 전송 오류: $e";
      });
    }
  }

  /// 취소 버튼을 눌렀을 때 종료
  @override
  void dispose() {
    _controller.stopListening(); // _isListening 조건 없이 바로 중단
    super.dispose();
  }

  void _onCancel() {
    _controller.stopListening(); // 동일하게 바로 중단
    Navigator.of(context).pop<String?>(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "음성인식",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16.w, vertical: 20.h),
          child: Column(
            children: [
              SizedBox(height: 20.h,),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isInitializing) ...[
                        const CircularProgressIndicator(),
                        SizedBox(height: 20.h),
                        Text(
                          '음성 인식 대기 중...',
                          style: TextStyle(fontSize: 16.sp),
                          textAlign: TextAlign.center,
                        ),
                      ] else if (_hasError) ...[
                        Icon(Icons.error, color: Colors.red, size: 48.sp),
                        SizedBox(height: 12.h),
                        Text(
                          _errorMsg,
                          style: TextStyle(fontSize: 16.sp, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ] else if (_isSending) ...[
                        const CircularProgressIndicator(),
                        SizedBox(height: 12.h),
                        Text(
                          '검색어 전처리 중...',
                          style: TextStyle(fontSize: 16.sp),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        if (_recognizedText.isEmpty) ...[
                          const CircularProgressIndicator(),
                          SizedBox(height: 12.h),
                          Text(
                            '검색어를 말씀해 주세요...',
                            style: TextStyle(fontSize: 16.sp),
                            textAlign: TextAlign.center,
                          ),
                        ] else ...[
                          Icon(Icons.check_circle, color: Colors.green, size: 48.sp),
                          SizedBox(height: 12.h),
                          Text(
                            '인식된 텍스트:\n"$_recognizedText"',
                            style: TextStyle(fontSize: 16.sp),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              // 취소 / 완료 버튼
              const Spacer(),
              Expanded(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _onCancel,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(240.w, 40.h),
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(height: 20.h,),
                    ElevatedButton(
                      onPressed: (_recognizedText.isEmpty || _isSending || _hasError)
                          ? null
                          : _onDonePressed,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(240.w, 40.h),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        '완료',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
