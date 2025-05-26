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
          padding: EdgeInsets.symmetric(horizontal: 60.h, vertical: 6.w),
          backgroundColor: Colors.blue,
        ),
        child: Text(
          '요리 시작하기',
          style: TextStyle(fontSize: 21.sp, color: Colors.white),
        ),
      ),
    );
  }
}
