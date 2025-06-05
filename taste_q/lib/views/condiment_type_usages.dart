import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/controllers/recommend_controller.dart';
import 'package:taste_q/providers/recipe_provider.dart';

class CondimentTypeUsages extends StatelessWidget {
  final int recipeId;
  final List<String> seasoningNames;
  final List<double> amounts; // Controller에서 최신 연산된 값 전달

  const CondimentTypeUsages({
    required this.recipeId,
    required this.seasoningNames,
    required this.amounts,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // multiplier가 바뀌면 이 위젯 전체가 rebuild 되어서
    // amounts와 multiplier가 동시에 최신 상태가 되는 로직
    final multiplier = context.watch<RecipeProvider>().multiplier;

    final recommendController = RecommendController();
    final recommendedNames = recommendController.getRecommendedNames(seasoningNames);
    final recommendedPercents = recommendController.getRecommendedPercents(
        seasonings: seasoningNames,
        amounts: amounts,
        multiplier: multiplier
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCard(
          title: "예상 조미료 사용량",
          names: seasoningNames,
          percents: amounts.map((e) => "${double.parse(e.toStringAsFixed(1))}g").toList(),
        ),
        _buildCard(
          title: "하루 권장 사용량",
          names: recommendedNames,
          percents: recommendedPercents,
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required List<String> names,
    required List<String> percents,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      color: Colors.grey[200],
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 150.w, minHeight: 120.h),
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
                  "${names[i]} : ${percents[i]}",
                  style: TextStyle(fontSize: 12.sp),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
