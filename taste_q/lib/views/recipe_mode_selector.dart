import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/models/recipe_mode.dart';
import 'package:taste_q/providers/recipe_provider.dart';

// 레시피 모드 드롭다운 선택 위젯 (수정된 Provider 버전)
class RecipeModeSelector extends StatelessWidget {
  const RecipeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    final selectedMode = recipeProvider.mode; // 현재 선택된 모드 가져오기

    return Center(
      child: PopupMenuButton<RecipeMode>(
        color: Colors.grey[100],
        offset: Offset(0, 28.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        onSelected: (RecipeMode mode) {
          context.read<RecipeProvider>().setMode(mode); // Provider의 모드 갱신 메소드 호출
        },
        itemBuilder: (BuildContext context) {
          return RecipeMode.values.map((mode) {
            return PopupMenuItem<RecipeMode>(
              value: mode,
              child: Text(
                modeLabels[mode]!,
                style: TextStyle(fontSize: 14.sp),
              ),
            );
          }).toList();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              modeLabels[selectedMode]!, // 선택된 모드 라벨 표시
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
