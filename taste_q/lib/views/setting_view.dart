import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/models/recipe_mode.dart';
import 'package:taste_q/providers/recipe_provider.dart';

class SettingView extends StatelessWidget { // Provider를 적용한 모드 설정 뷰
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    final selectedMode = recipeProvider.mode; // 현재 모드 가져오기

    final List<String> modes = ["표준 모드", "웰빙 모드", "미식 모드"];
    final List<String> descriptions = [
      "가장 표준적인 레시피를 따릅니다.\n실패하지는 않지만 맛있을 수도 있습니다.",
      "LG는 사용자의 건강도 생각합니다.\n싱거울 수는 있지만 건강에는 좋아요.",
      "강렬한 맛을 선사합니다.\n풍미와 개성이 담긴 만족스런 식사를 위해",
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전력량 모니터링 박스
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 24.w),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "전력량 모니터링",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                          Radius.circular(8.r)),
                      child: Image.asset(
                        "images/graph.jpg",
                        height: 220.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),

          Text(
            "MODE",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 12.h),

          // 모드 설정 버튼 목록
          ListView.builder(
            itemCount: modes.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final mode = RecipeMode.values[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<RecipeMode>(
                    title: Text(
                      modes[index],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: mode,
                    groupValue: selectedMode,
                    onChanged: (RecipeMode? newMode) {
                      if (newMode != null) {
                        context.read<RecipeProvider>().setMode(newMode); // setMode로 변경
                      }
                    },
                  ),
                  if (selectedMode == mode)
                    Padding(
                      padding: EdgeInsets.only(left: 72.w, bottom: 12.h),
                      child: Text(
                        descriptions[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
