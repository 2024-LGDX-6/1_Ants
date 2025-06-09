import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/cook_log_controller.dart';
import 'package:taste_q/controllers/dto/cook_log_data_dto.dart';
import 'package:taste_q/models/route_entry_type.dart';
import 'package:taste_q/screens/recipe_data_screen.dart';
import 'package:taste_q/views/safe_images.dart';

// 사용자 요리 기록 표시
class SectionHistory extends StatelessWidget {
  const SectionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CookLogDataDTO>>(
      future: CookLogController().getLastCookLog(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text("요리 기록 로딩 중..."),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                "기록 정보가 아직 없습니다.",
                style: TextStyle(fontSize: 12.sp,),
              ),
            ),
          );
        } else {
          final cookLog = snapshot.data!.first;
          String dateString = cookLog.startTime;
          DateTime date = DateTime.parse(dateString);
          String formattedDate = "${date.year}년 ${date.month}월 ${date.day}일";

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDataScreen(
                    routeEntryType: RouteEntryType.anotherDefault,
                    recipeId: cookLog.recipeId,
                  ),
                ),
              );
            },
            child: Container(
              // width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "나의 요리 기록",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      safeImage(cookLog.recipeImage, 130.w, 80.w),
                      SizedBox(width: 18.w),
                      Expanded(  // 텍스트가 넘치지 않도록 Expanded() 활용
                        child: Text(
                          '''최근 $formattedDate에\n요리한 음식 : ${cookLog.recipeName}\n음식 평가 : "맛있어요"''',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}