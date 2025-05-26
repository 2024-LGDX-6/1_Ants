import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/recipe_mode.dart';
import '../providers/recipe_provider.dart';

// 레시피 모드 드롭다운 선택 위젯
/// - Provider에서 현재 모드를 받아 표시하고 변경 시 Provider 갱신
class RecipeModeSelector extends StatelessWidget {
  const RecipeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    final selectedMode = recipeProvider.selectedMode;

    return Center(
      child: PopupMenuButton<RecipeMode>(
        color: Colors.grey[100],
        offset: Offset(0, 28.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        onSelected: (RecipeMode mode) {
          context.read<RecipeProvider>().updateRecipeMode(mode); // Provider 갱신
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
              modeLabels[selectedMode]!,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            // SizedBox(width: 2.w),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
