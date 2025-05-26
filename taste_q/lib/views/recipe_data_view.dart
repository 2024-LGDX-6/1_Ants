import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/controllers/recipe_controller.dart';
import 'package:taste_q/views/recipe_mode_selector.dart';
import 'package:taste_q/views/safe_images.dart';
import '../providers/recipe_provider.dart';
import 'condiment_type_usages.dart';

// 레시피 정보 출력
class RecipeDataView extends StatelessWidget {
  RecipeDataView({super.key});

  final controller = RecipeController();

  @override
  Widget build(BuildContext context) {
    final recipe = context.watch<RecipeProvider>().recipe;

    return SingleChildScrollView(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30.h),
          Center(
            child: safeImage(recipe.recipeImageUrl, 300.w, 200.h),
          ),
          SizedBox(height: 15.h),
          Center(
            child: Text(
              recipe.recipeTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          RecipeModeSelector(), // controller 없이 Provider 기반
          SizedBox(height: 32.h),
          CondimentTypeUsages(controller: controller),

        ],
      ),
    );
  }
}
