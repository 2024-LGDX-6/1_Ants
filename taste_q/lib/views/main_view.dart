import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/dto/main_data_dto.dart';
import 'package:taste_q/controllers/main_controller.dart';
import 'section_recommended.dart';
import 'section_history.dart';
import 'section_buttons.dart';
import 'section_tipbar.dart';

class MainView extends StatelessWidget {
  final MainController controller;

  const MainView({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    const int userId = 1; // 로그인 사용자ID
    const int deviceId = 3; // 디바이스 냉장고ID

    return FutureBuilder<MainDataDTO>(
      future: controller.getRecommendedRecipes(userId, deviceId),
      builder: (context, snapshot) {
        // 1) 로딩 중엔 스피너
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // 2) 오류가 있거나 데이터가 없더라도, 화면은 그대로 구성
        final bool hasError = snapshot.hasError;
        final MainDataDTO dto = snapshot.data ??
            MainDataDTO(
              recipeIds: [],
              recipeNames: [],
              recipeImageUrls: [],
              recipeIngredients: [],
            );
        // 냉장고 재료 기반 추천이 비어 있거나, 오류 발생 시 프롬프트
        final bool showPrompt = hasError || dto.recipeIds.isEmpty;

        final recipeIds = dto.recipeIds;
        final recipeNames = dto.recipeNames;
        final recipeImages = dto.recipeImageUrls;
        final tip = controller.getRandomTip();

        return SingleChildScrollView(
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              Center(
                child: Image.asset(
                  'images/tasteQ.png',
                  width: 120.w,
                  height: 80.h,
                ),
              ),
              SizedBox(height: 20.h),
              SectionRecommended(
                recipeIds: recipeIds,
                recipeNames: recipeNames,
                recipeImages: recipeImages,
                showPrompt: showPrompt, // 오류 혹은 빈 리스트 시 메시지 표시
              ),
              SizedBox(height: 16.h),
              SectionHistory(),
              SizedBox(height: 16.h),
              SectionButtons(),
              SizedBox(height: 32.h),
              SectionTipBar(tip: tip),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
