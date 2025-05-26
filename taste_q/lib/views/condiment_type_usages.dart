import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/recipe_controller.dart';

class CondimentTypeUsages extends StatelessWidget {
  final RecipeController controller;

  const CondimentTypeUsages({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final recipe = controller.recipe;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCard(
          title: "예상 조미료 사용량",
          names: recipe.condimentTypes,
          values: recipe.condimentUsages.map(
            (e) => "${e.toString()}g"
          ).toList(),
        ),
        _buildCard(
          title: "하루 권장 사용량",
          names: _getRecommendedNames(recipe.condimentTypes),
          values: _getRecommendedPercents(recipe.condimentTypes),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title, // 각 카드 블록명
    required List<String> names, // 조미료명
    required List<String> values, // 조미료량
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        // side: BorderSide(color: Colors.white, width: 1,),
        borderRadius: BorderRadius.circular(16.r),
      ),
      color: Colors.grey[200],
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 150.w,  // 최소 너비 지정
          minHeight: 120.h, // 최소 높이 지정
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              for (int i = 0; i < names.length; i++)
                Text(
                  "${names[i]} : ${values[i]}",
                  style: TextStyle(fontSize: 12.sp),
                ),
            ],
          ),
        ),
      ),
    );
  }


  // 하루권장량 예시: 권장 사용량 임의로 지정
  // - 별도의 모델, 컨트롤러 추가 및 서버에서 받아온다면 수정 필요!
  List<String> _getRecommendedNames(List<String> condiments) {
    return condiments.where((e) => e == '소금' || e == '후추').toList();
  }

  List<String> _getRecommendedPercents(List<String> condiments) {
    return condiments.where((e) => e == '소금' || e == '후추').map((e) {
      switch (e) {
        case '소금':
          return '50%';
        case '후추':
          return '25%';
        default:
          return '10%';
      }
    }).toList();
  }
}
