import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/recipe_controller.dart';
import 'package:taste_q/views/recipe_link_button.dart';
import 'package:taste_q/views/recipe_mode_selector.dart';
import 'package:taste_q/views/recipe_start_button.dart';
import 'package:taste_q/views/safe_images.dart';
import 'condiment_type_usages.dart';

class RecipeDataView extends StatefulWidget {
  final RecipeController controller;
  final int recipeId;

  const RecipeDataView({
    super.key,
    required this.controller,
    required this.recipeId,
  });

  @override
  _RecipeDataViewState createState() => _RecipeDataViewState();
}

class _RecipeDataViewState extends State<RecipeDataView> {
  late Future<RecipeDataDTO> _recipeFuture;

  @override
  void initState() {
    super.initState();
    // Future를 initState에서 초기화 -> build() 재호출에도 Future 유지
    _recipeFuture = widget.controller.getRecipeData(widget.recipeId, context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecipeDataDTO>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('레시피 정보를 불러올 수 없습니다.'));
        } else {
          final dto = snapshot.data!;
          final int recipeId = dto.recipeId;
          final String recipeName = dto.recipeName;
          final String recipeImageUrl = dto.recipeImageUrl;
          final List<String> seasoningNames = dto.seasoningNames;
          final List<double> amounts = dto.amounts;
          final String recipeLink = dto.recipeLink;

          return SingleChildScrollView(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Center(
                  child: safeImage("images/foods/$recipeImageUrl", 300.w, 200.h),
                ),
                SizedBox(height: 15.h),
                Center(
                  child: Text(
                    recipeName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                RecipeModeSelector(), // Provider와 연결, build() 재호출과 무관
                SizedBox(height: 28.h),
                CondimentTypeUsages(
                  recipeId: recipeId,
                  seasoningNames: seasoningNames,
                  amounts: amounts,
                ),
                SizedBox(height: 20.h),
                RecipeStartButton(
                    recipeImageUrl: recipeImageUrl,
                    recipeName: recipeName,
                    recipeId: recipeId,
                    seasoningName: seasoningNames,
                    amounts: amounts,
                    recipeLink: recipeLink,
                ),
                SizedBox(height: 20.h),
                RecipeLinkButton(recipeLink: recipeLink),
              ],
            ),
          );
        }
      },
    );
  }
}

