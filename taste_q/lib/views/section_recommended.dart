import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/screens/recipe_data_screen.dart';
import 'package:taste_q/views/safe_images.dart';
import '../models/home.dart';

// 추천 요리 목록 표시
class SectionRecommended extends StatelessWidget {
  final List<Home> recipeNames;

  const SectionRecommended({required this.recipeNames, super.key});

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
            recipeNames.map((recipe) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDataScreen(),
                        ),
                      );
                    },
                      child: safeImage(recipe.imageUrl, 90.w, 80.w)
                  ),
                  SizedBox(height: 4.h),
                  Text(recipe.title, style: TextStyle(fontSize: 12.sp)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}