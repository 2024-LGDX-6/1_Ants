import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/custom_recipe_controller.dart';
import 'package:taste_q/controllers/recipe_controller.dart';
import 'package:taste_q/models/route_entry_type.dart';
import 'package:taste_q/views/recipe_link_button.dart';
import 'package:taste_q/views/recipe_mode_selector.dart';
import 'package:taste_q/views/recipe_start_button.dart';
import 'package:taste_q/views/safe_images.dart';
import 'condiment_type_usages.dart';

class RecipeDataView extends StatefulWidget {
  final RouteEntryType routeEntryType;
  // final RecipeController controller;
  final int recipeId;

  const RecipeDataView({
    super.key,
    required this.routeEntryType,
    // required this.controller,
    required this.recipeId,
  });

  @override
  _RecipeDataViewState createState() => _RecipeDataViewState();
}

class _RecipeDataViewState extends State<RecipeDataView> {
  late Future<dynamic> _recipeFuture; // 타입을 dynamic으로 변경
  late dynamic controller;

  @override
  void initState() {
    super.initState();
    switch (widget.routeEntryType) {
      case RouteEntryType.anotherDefault:
        controller = RecipeController();
        break;
      case RouteEntryType.customRecipeList:
        controller = CustomRecipeController();
        break;
    }
    // Future를 initState에서 초기화 -> build() 재호출에도 Future 유지
    _recipeFuture = controller.getRecipeData(widget.recipeId, context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>( // FutureBuilder의 타입도 dynamic으로 변경
      future: _recipeFuture,
      builder: (context, snapshot) {
        // print('Fetched data: ${snapshot.data}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('레시피 정보를 불러올 수 없습니다.'));
        } else {
          final dto = snapshot.data!;
          // recipeLink 안전 처리
          String recipeLink = '';
          try {
            recipeLink = dto.recipeLink ?? '';
          } catch (e) {
            recipeLink = ''; // 레시피 링크 필드가 없을 땐 빈 문자열
          }
          final int recipeId = dto.recipeId;
          final String recipeName = dto.recipeName;
          final String recipeImageUrl = dto.recipeImageUrl;
          final List<String> seasoningNames = dto.seasoningNames;
          final List<double> amounts = dto.amounts;


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
                  recipeLink: recipeLink, // null일 경우 빈 문자열로 대체
                  // connectedDevice와 txCharacteristic은 이제 선택적 nullable 파라미터이므로 전달하지 않아도 됩니다.
                ),
                SizedBox(height: 20.h),
                Opacity(
                  opacity: (recipeLink != '') ? 1.0 : 0.5, // null 또는 빈 문자열 처리
                  child: IgnorePointer(
                    ignoring: recipeLink == '', // null 또는 빈 문자열일 때 터치 비활성화
                    child: RecipeLinkButton(recipeLink: recipeLink), // null일 경우 빈 문자열 대체
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
