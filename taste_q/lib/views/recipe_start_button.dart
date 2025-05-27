import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecipeStartButton extends StatelessWidget {
  const RecipeStartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // 버튼 클릭 시 동작 정의
          print("요리 시작 버튼이 눌렸습니다.");
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32.h, vertical: 16.w),
          backgroundColor: Colors.orange,
        ),
        child: const Text(
          '요리 시작',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
