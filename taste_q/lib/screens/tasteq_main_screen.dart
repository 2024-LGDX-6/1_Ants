import 'package:flutter/material.dart';
import 'package:taste_q/controllers/main_controller.dart';
import 'package:taste_q/views/front_appbar.dart';
import 'package:taste_q/views/main_view.dart';
import 'package:taste_q/views/setting_view.dart';
import 'package:taste_q/views/stt_voice_input_popup.dart';

import '../controllers/stt_controller.dart';

class TasteqMainScreen extends StatefulWidget {
  const TasteqMainScreen({super.key});

  @override
  State<TasteqMainScreen> createState() => _TasteqMainScreenState();
}

class _TasteqMainScreenState extends State<TasteqMainScreen> {
  // final MainController controller = MainController();
  final PageController _pageController = PageController();

  // 음성인식 객체 및 컨트롤러
  final STTController _sttController = STTController();
  String _recognizedText = "음성인식 결과가 여기에 표시됩니다.";

  int _currentIndex = 0;

  final List<Widget> _pages = [ // 페이지 뷰 목록
    MainView(controller: MainController()), // 메인 뷰
    SettingView(), // 설정 뷰
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // FAB 위젯 클릭 시 음성인식 호출
  void _onFabPressed() async {
    // 1) 팝업 띄우기
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => STTVoiceInputPopup(controller: _sttController),
    );

    // 2) 팝업이 닫힌 뒤, 음성인식 결과를 받아 화면에 표시
    //  startListening()의 Completer가 완료된 텍스트를 가져옵니다.
    //  (VoiceRecognitionDialog 내에서 stopListening이 호출되면
    //  startListening()의 Future가 완료됩니다.)
    try {
      final result = await _sttController.startListening();
      setState(() {
        _recognizedText = result;
        print(_recognizedText);
      });
    } catch (e) {
      setState(() {
        _recognizedText = "음성인식 실패: $e";
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // 메모리 누수 방지
    // 화면을 벗어날 때 음성인식이 살아 있으면 중지
    if (_sttController.isListening) {
      _sttController.stopListening();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final recipes = controller.getRecommendedRecipes();
    // final feedback = controller.getLastRecipeFeedback();

    return Scaffold(
      appBar: FrontAppBar(appBarName: "테이스트Q",),
      backgroundColor: Colors.white,

      // 본문 - 하단바의 탭 클릭에 따라 변경됨
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(), // 손가락 조작 방지
        children: _pages,
      ),

      // 하단 네비게이션바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '제품'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '모드'),
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
      ),

      // 음성인식 검색 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        child: const Icon(Icons.mic, color: Colors.black),
      ),
    );
  }
}
