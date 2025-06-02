import 'package:flutter/material.dart';
import 'package:taste_q/controllers/main_controller.dart';
import 'package:taste_q/controllers/stt_controller.dart';
import 'package:taste_q/views/front_appbar.dart';
import 'package:taste_q/views/main_view.dart';
import 'package:taste_q/views/setting_view.dart';

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
  String _recognizedText = "음성인식을 시작하세요.";

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

  // 음성인식 로직
  void _startVoiceRecognition() async {
    try {
      final result = await _sttController.startListening();
      setState(() {
        _recognizedText = result;
      });
      print("음성인식 결과: $result");
    } catch (e) {
      setState(() {
        _recognizedText = "음성인식 실패: $e";
      });
      print("음성인식 오류: $e");
    }
  }


  @override
  void dispose() {
    _pageController.dispose(); // 메모리 누수 방지
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
        onPressed: _startVoiceRecognition,
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        child: const Icon(Icons.mic, color: Colors.black),
      ),
    );
  }
}
