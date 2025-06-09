import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/models/route_entry_type.dart';
import 'package:taste_q/screens/recipe_data_screen.dart';
import 'package:taste_q/views/safe_images.dart';

class SectionRecommended extends StatelessWidget {
  final List<int> recipeIds;
  final List<String> recipeNames;
  final List<String> recipeImages;
  final bool showPrompt;  // 추가

  const SectionRecommended({
    required this.recipeIds,
    required this.recipeNames,
    required this.recipeImages,
    this.showPrompt = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (showPrompt) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          '냉장고 재료를 추가해주세요.',
          style: TextStyle(fontSize: 14.sp,),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "오늘의 추천 Taste",
            style: TextStyle(
                fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(recipeNames.length, (index) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDataScreen(
                            routeEntryType:
                            RouteEntryType.anotherDefault,
                            recipeId: recipeIds[index],
                          ),
                        ),
                      );
                    },
                    child:
                    safeImage(recipeImages[index], 90.w, 80.w),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    recipeNames[index],
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
