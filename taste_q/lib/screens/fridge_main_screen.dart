import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/user_fridge_controller.dart';
import 'package:taste_q/views/fridge_front_appbar.dart';
import 'package:taste_q/screens/tasteq_main_screen.dart';
import 'package:taste_q/screens/ingredient_screen.dart';

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
    final controller = UserFridgeController();
    final int userId = 1;

    return Scaffold(
      appBar: const FridgeFrontAppbar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
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
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
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
                        child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20
                        ),
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
              padding: EdgeInsets.symmetric(horizontal: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      margin: EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IngredientScreen(
                                  userId: userId,
                                  controller: controller,
                                ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)
                          ),
                          elevation: 0,
                        ),
                        child: const Text('재료 보기'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      margin: EdgeInsets.only(left: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TasteqMainScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)
                          ),
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

  // controller로 create 메소드 호출
  void _handleInput() async {
    final input = _textController.text;
    if (input.isNotEmpty) {
      print('입력된 재료: $input');
      _textController.clear();
      setState(() {
        _showCheckmark = true;
      });

      // 컨트롤러의 POST 메소드 호출
      final controller = UserFridgeController();
      final int deviceId = 3; // 임의의 디바이스 ID 지정
      try {
        await controller.createUserFridge(deviceId, input);
        print('재료 추가 성공');
      } catch (e) {
        print('재료 추가 실패: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('재료 추가 실패')),
        );
      }

      // 체크마크 1초 표시 후 해제
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _showCheckmark = false;
        });
      });
    }
  }
}


