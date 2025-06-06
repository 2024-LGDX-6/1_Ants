import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taste_q/controllers/main_controller.dart';
import 'package:taste_q/models/route_entry_type.dart';
import 'package:taste_q/screens/recipe_list_screen.dart';
import 'package:taste_q/screens/speech_recognition_screen.dart';
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

  /// FAB 클릭 시 음성인식 호출
  void _onFabPressed() async {
    // ① 마이크 권한 요청 (여기서도 한 번 더 체크해도 무방)
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마이크 권한이 필요합니다. 설정에서 허용해주세요.')),
        );
        return;
      }
    }

    // ② SpeechRecognitionScreen으로 이동
    final cleanedText = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (_) => const SpeechRecognitionScreen(),
      ),
    );

    // ③ 결과 처리: null이 아니면 레시피 목록 페이지로 이동
    if (cleanedText != null && cleanedText.isNotEmpty) {
      setState(() {
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
    // null 또는 빈 문자열이면 아무 동작 없음
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
        onPressed: _onFabPressed,
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        child: const Icon(Icons.mic, color: Colors.black),
      ),
    );
  }
}
