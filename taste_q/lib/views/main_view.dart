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

  const MainView({
    required this.controller,
    super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 메소드 호출하여 DTO 반환
    final MainDataDTO dto = controller.getRecommendedRecipes();
    // 2. 반환된 DTO에서 값 추출
    final List<String> recipeNames = dto.recipeNames;
    final List<String> recipeImages = dto.recipeImageUrls;

    final feedback = controller.getLastRecipeFeedback();
    final tip = controller.getRandomTip();

    return SingleChildScrollView(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30.h),
          Center(
            child: safeImage('images/tasteQ.png', 120.w, 80.h)
          ),
          SizedBox(height: 30.h),
          SectionRecommended(
            recipeNames: recipeNames,
            recipeImages: recipeImages,
          ),
          SizedBox(height: 16.h),
          SectionHistory(feedback: feedback,),
          SizedBox(height: 16.h),
          SectionButtons(),
          SizedBox(height: 32.h),
          SectionTipBar(tip: tip,),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
