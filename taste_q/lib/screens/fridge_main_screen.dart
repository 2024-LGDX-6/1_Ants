import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taste_q/views/fridge_front_appbar.dart';
import 'package:taste_q/screens/tasteq_main_screen.dart';

class FridgeMainScreen extends StatefulWidget {
  const FridgeMainScreen({super.key});

  @override
  State<FridgeMainScreen> createState() => _FridgeMainScreenState();
}

class _FridgeMainScreenState extends State<FridgeMainScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  bool _showCheckmark = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // 키보드 올라올 때 상태바 스타일 다시 적용
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FridgeFrontAppbar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Image.asset(
                'images/fridge.png',
                width: MediaQuery.of(context).size.width * 0.9, // 화면 너비의 90%
                fit: BoxFit.contain, // 비율 유지
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: '빠르게 재료 입력하기',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(color: Colors.black),
                        onSubmitted: (_) => _handleInput(),
                      ),
                    ),
                    if (_showCheckmark)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ),
                    TextButton(
                      onPressed: _handleInput,
                      child: const Text('입력'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: 재료 보기 기능 연결
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFEFEF),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('재료 보기'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.only(left: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TasteqMainScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('빠른 요리'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildImageCard(String imagePath, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(imagePath, width: 100, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16, color: Colors.black),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEFEFEF),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  void _handleInput() {
    final input = _textController.text;
    if (input.isNotEmpty) {
      print('입력된 재료: $input');
      _textController.clear();
      _sendInputToBackend(input);
      setState(() {
        _showCheckmark = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _showCheckmark = false;
        });
      });
    }
  }

  // [백엔드 연동 준비 함수]
  // 실제 백엔드 API에 연결하려면 http 패키지를 사용하고, 아래 코드에 URL과 전송 방식 등을 설정해야 합니다.
  // 예시: http.post(Uri.parse('https://your-backend.com/input'), body: {'ingredient': input})
  void _sendInputToBackend(String input) {
    print('백엔드로 전송할 입력값: $input');

    // TODO: 여기에 실제 백엔드 전송 로직 추가
    // 예시:
    // final response = await http.post(
    //   Uri.parse('https://your-backend-endpoint.com/api/ingredients'),
    //   body: {'ingredient': input},
    // );
    //
    // if (response.statusCode == 200) {
    //   print('전송 성공!');
    // } else {
    //   print('전송 실패: ${response.statusCode}');
    // }
  }
}
