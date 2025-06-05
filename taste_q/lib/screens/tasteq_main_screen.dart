import 'package:flutter/material.dart';
import 'package:taste_q/controllers/main_controller.dart';
import 'package:taste_q/controllers/stt_controller.dart';
import 'package:taste_q/models/route_entry_type.dart';
import 'package:taste_q/screens/recipe_list_screen.dart';
import 'package:taste_q/views/front_appbar.dart';
import 'package:taste_q/views/main_view.dart';
import 'package:taste_q/views/setting_view.dart';
import 'package:taste_q/views/stt_voice_input_popup.dart';


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
  String _displayText = "여기에 음성인식 결과가 표시됩니다.";

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

  /// FAB 클릭 시: 팝업 띄워서 오디오 스트리밍 → 서버에서 받은 텍스트로 화면 전환
  void _onFabPressed() async {
    final cleanedText = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => STTVoiceInputPopup(controller: _sttController),
    );

    if (cleanedText != null && cleanedText.isNotEmpty) {
      setState(() {
        _displayText = cleanedText;
        print("인식된 텍스트: $_displayText");
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecipeListScreen(
            searchQuery: cleanedText,
            routeEntryType: RouteEntryType.anotherDefault,
          ),
        ),
      );
    }
    // null이거나 빈 문자열이면 아무 동작 없음
  }


  @override
  void dispose() {
    _pageController.dispose(); // 메모리 누수 방지
    if (_sttController.isStreaming) {
      _sttController.stopStreaming();
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
