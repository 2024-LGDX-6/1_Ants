import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/recipe_controller.dart';
import 'package:taste_q/views/recipe_link_button.dart';
import 'package:taste_q/views/recipe_mode_selector.dart';
import 'package:taste_q/views/recipe_start_button.dart';
import 'package:taste_q/views/safe_images.dart';
import 'condiment_type_usages.dart';

// 레시피 정보 출력
class RecipeDataView extends StatelessWidget {
  RecipeDataView({super.key});

  final controller = RecipeController();

  @override
  Widget build(BuildContext context) {
    // final recipe = context.watch<RecipeProvider>().recipe;

    // 1. 메소드 호출하여 DTO 반환
    final RecipeDataDTO dto = controller.getRecipeData(0);
    // 2. 반환된 DTO에서 값 추출
    final String recipeName = dto.recipeName;
    final String recipeImageUrl = dto.recipeImageUrl;
    final List<String> seasoningNames = dto.seasoningNames;
    final List<double> amounts = dto.amounts;
    final String recipeLink = dto.recipeLink;


    return SingleChildScrollView(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Center(
            child: safeImage("images/foods/$recipeImageUrl", 300.w, 200.h),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                recipeName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.sp,
                ),
              ),
              Icon(Icons.bookmark_border, size: 32.sp,)
            ],
          ),
          SizedBox(height: 8.h),
          RecipeModeSelector(), // controller 없이 Provider 기반
          SizedBox(height: 28.h),
          CondimentTypeUsages(
            seasoningNames: seasoningNames,
            amounts: amounts,
          ),
          SizedBox(height: 20.h),
          RecipeStartButton(),
          SizedBox(height: 20.h),
          RecipeLinkButton(recipeLink: recipeLink),
        ],
      ),
    );
  }
}
