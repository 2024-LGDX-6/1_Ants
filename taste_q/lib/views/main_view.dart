import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/main_controller.dart';
import 'package:taste_q/views/safe_images.dart';
import 'section_recommended.dart';
import 'section_history.dart';
import 'section_buttons.dart';
import 'section_tipbar.dart';

class MainView extends StatelessWidget {
  final MainController controller;

  const MainView({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MainDataDTO>(
      future: controller.getRecommendedRecipes(), // 원래의 메소드 호출

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터 로딩 중 표시
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // 오류 발생 시 표시
          return Center(child: Text('오류: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          // 데이터가 없는 경우 처리
          return Center(
              child: Text('추천 레시피를 불러올 수 없습니다.'),
          );
        } else {
          // 데이터가 정상적으로 로드된 경우
          final MainDataDTO dto = snapshot.data!;
          final List<String> recipeNames = dto.recipeNames;
          final List<String> recipeImages = dto.recipeImageUrls;

          // 하드코딩 데이터 반환
          final feedback = controller.getLastRecipeFeedback();
          final tip = controller.getRandomTip();

          return SingleChildScrollView(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                Center(child: safeImage('images/tasteQ.png', 120.w, 80.h)),
                SizedBox(height: 30.h),
                SectionRecommended(
                  recipeNames: recipeNames,
                  recipeImages: recipeImages,
                ),
                SizedBox(height: 16.h),
                SectionHistory(feedback: feedback),
                SizedBox(height: 16.h),
                SectionButtons(),
                SizedBox(height: 32.h),
                SectionTipBar(tip: tip),
                SizedBox(height: 20.h),
              ],
            ),
          );
        }
      },
    );
  }
}
