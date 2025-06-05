import 'package:flutter/material.dart';
import 'package:taste_q/controllers/main_controller.dart';
import 'package:taste_q/controllers/stt_controller.dart';
import 'package:taste_q/models/route_entry_type.dart';
import 'package:taste_q/screens/recipe_list_screen.dart';
import 'package:taste_q/views/front_appbar.dart';
import 'package:taste_q/views/main_view.dart';
import 'package:taste_q/views/setting_view.dart';
import 'package:taste_q/views/stt_voice_input_popup.dart';
import 'package:permission_handler/permission_handler.dart';

class TasteqMainScreen extends StatefulWidget {
  const TasteqMainScreen({super.key});

  @override
  State<TasteqMainScreen> createState() => _TasteqMainScreenState();
}

class _TasteqMainScreenState extends State<TasteqMainScreen> {
  final PageController _pageController = PageController();
  final STTController _sttController = STTController();
  String _displayText = "여기에 음성인식 결과가 표시됩니다.";

  int _currentIndex = 0;
  final List<Widget> _pages = [
    MainView(controller: MainController()),
    SettingView(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 마이크 권한 요청
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  /// FAB 클릭 시: 권한 요청 → 팝업 띄우기 → 결과 받아 레시피 목록으로 이동
  void _onFabPressed() async {
    // ① 마이크 권한 요청
    bool granted = await _requestMicrophonePermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마이크 권한이 필요합니다. 설정에서 허용해주세요.')),
      );
      return;
    }

    // ② 팝업 띄워서 오디오 스트리밍 → 종료 → 최종 텍스트 반환
    final cleanedText = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => STTVoiceInputPopup(controller: _sttController),
    );

    // ③ 팝업이 닫힌 뒤: cleanedText가 null이 아니면 화면 이동
    if (cleanedText != null && cleanedText.isNotEmpty) {
      setState(() {
        _displayText = cleanedText;
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
    // null 또는 빈 문자열이면 아무 동작 안 함
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (_sttController.isStreaming) {
      _sttController.stopStreaming();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FrontAppBar(appBarName: "테이스트Q"),
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) => setState(() => _currentIndex = index),
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        child: const Icon(Icons.mic, color: Colors.black),
      ),
    );
  }
}
