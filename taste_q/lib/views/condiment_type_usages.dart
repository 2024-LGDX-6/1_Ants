import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/recommend_controller.dart';

class CondimentTypeUsages extends StatelessWidget {
  final int recipeId;
  final List<String> seasoningNames;
  final List<double> amounts;

  const CondimentTypeUsages({
    required this.recipeId,
    required this.seasoningNames,
    required this.amounts,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final recommendController = RecommendController();
    final recommendedNames = recommendController.getRecommendedNames(seasoningNames);
    final recommendedPercents = recommendController.getRecommendedPercents(seasoningNames);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCard(
          title: "예상 조미료 사용량",
          names: seasoningNames,
          values: amounts.map((e) => "${e.toString()}g").toList(),
        ),
        _buildCard(
          title: "하루 권장 사용량",
          names: recommendedNames,
          values: recommendedPercents,
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
          minWidth: 150.w, // 최소 너비 지정
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

}
