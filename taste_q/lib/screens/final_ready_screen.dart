import 'package:flutter/material.dart';
import 'package:taste_q/screens/feedback_screen.dart';
import 'package:taste_q/views/final_ready_appbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/views/safe_images.dart';
import 'package:taste_q/views/condiment_type_usages.dart';

class FinalReadyScreen extends StatelessWidget {
  final String recipeLink;
  final List<double> amounts;
  final List<String> seasoningName;
  final String recipeName;
  final String recipeImageUrl;
  final int recipeId;

  const FinalReadyScreen({
    super.key,
    required this.recipeLink,
    required this.amounts,
    required this.seasoningName,
    required this.recipeName,
    required this.recipeImageUrl,
    required this.recipeId,
  });

  Future<void> _launchRecipeLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FinalReadyAppbar(),
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
                child: safeImage("images/foods/${recipeImageUrl}", 280.w, 200.h),
              ),
            ),
            SizedBox(height: 14.h),
            // 요리명
            Text(
              recipeName,
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333)
              ),
            ),
            SizedBox(height: 10.h),
            // 조미료 사용량 카드 (유동적)
            CondimentTypeUsages(
              recipeId: recipeId,
              seasoningNames: seasoningName,
              amounts: amounts,
            ),
            SizedBox(height: 18.h),
            // 레시피 보러가기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _launchRecipeLink(recipeLink);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade200,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 14.w),
                  shape: const StadiumBorder(),
                  textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  elevation: 0,
                ),
                child: const Text("레시피 보러가기"),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 14.w),
                  shape: const StadiumBorder(),
                  textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  elevation: 0,
                ),
                child: const Text("요리 끝내기"),
              ),
            ),
            const Spacer(),
            // (하단 버튼 2개 및 아래 여백 제거됨)
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