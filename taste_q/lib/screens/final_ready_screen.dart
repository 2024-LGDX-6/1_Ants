import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/views/front_appbar.dart';
import 'package:taste_q/views/safe_images.dart';

class FinalReadyScreen extends StatelessWidget {
  const FinalReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FrontAppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // 상단 로고/제품/냉장고 이미지
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset("images/tasteQ.png", width: 56, height: 56),
                Image.asset("images/elec_oven.png", width: 56, height: 56),
                Image.asset("images/fridge.png", width: 56, height: 56),
              ],
            ),
            const SizedBox(height: 16),
            // 안내 텍스트
            const Text(
              "요리 준비가 완료되었습니다.",
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222)
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // 요리 이미지와 그림자 효과
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16.r,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: safeImage("images/foods/kimchi.jpg", 280.w, 200.h),
              ),
            ),
            SizedBox(height: 14.h),
            // 요리명
            Text(
              "김치찌개",
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)
              ),
            ),
            SizedBox(height: 10.h),
            // 조미료 사용량 카드
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 18.h),
              margin: EdgeInsets.symmetric(vertical: 4.w),
              decoration: BoxDecoration(
                color: Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Text("조미료 사용량", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  SizedBox(height: 8),
                  Text("소금 : 2.5g", style: TextStyle(fontSize: 15.sp)),
                  Text("고춧가루 : 10g", style: TextStyle(fontSize: 15.sp)),
                  Text("후추 : 0.5g", style: TextStyle(fontSize: 15.sp)),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            // 레시피 보러가기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade200,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 14.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  elevation: 0,
                ),
                child: const Text("레시피 보러가기"),
              ),
            ),
            const Spacer(),
            // 하단 버튼 2개
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 13.sp),
                      shape: StadiumBorder(),
                      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                      elevation: 0,
                    ),
                    child: const Text("제품"),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 13.w),
                      shape: StadiumBorder(),
                      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                      elevation: 0,
                    ),
                    child: Text("유용한 기능"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.mic_none, color: Colors.black),
      ),
    );
  }
}