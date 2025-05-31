import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/controllers/custom_recipe_controller.dart';
import 'package:taste_q/controllers/recipe_controller.dart';
import 'package:taste_q/models/route_entry_type.dart';
import 'package:taste_q/providers/recipe_provider.dart';
import 'package:taste_q/views/condiment_type_usages.dart';
import 'package:taste_q/views/multiplier_input.dart';
import 'package:taste_q/views/recipe_link_button.dart';
import 'package:taste_q/views/recipe_mode_selector.dart';
import 'package:taste_q/views/recipe_start_button.dart';
import 'package:taste_q/views/safe_images.dart';

class RecipeDataView extends StatefulWidget {
  final RouteEntryType routeEntryType;
  final int recipeId;

  const RecipeDataView({
    super.key,
    required this.routeEntryType,
    required this.recipeId,
  });

  @override
  _RecipeDataViewState createState() => _RecipeDataViewState();
}

class _RecipeDataViewState extends State<RecipeDataView> {
  dynamic controller;
  dynamic dto;
  String? errorMessage;

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
    _loadData();  // 최초 데이터 불러오기
  }

  Future<void> _loadData() async {
    try {
      final data = await controller.getRecipeData(widget.recipeId, context);
      if (mounted) {
        setState(() {
          dto = data;
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = '데이터를 불러오는 중 오류가 발생했습니다.\n오류: $e';
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider 변경 시 데이터 갱신
    context.watch<RecipeProvider>();
    _loadData();  // 로딩 없이 dto만 갱신
  }

  @override
  void dispose() {
    context.read<RecipeProvider>().resetMultiplier();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, textAlign: TextAlign.center));
    }

    if (dto == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final int recipeId = dto.recipeId;
    final String recipeName = dto.recipeName;
    final String recipeImageUrl = dto.recipeImageUrl;
    final List<String> seasoningNames = dto.seasoningNames;
    final List<double> amounts = dto.amounts;
    final String recipeLink = dto.recipeLink ?? '';
    final int recipeType = dto.recipeType;

    List<double> roundedAmounts = amounts.map( // 소수점 1자리 수로 수정
      (e) => double.parse(e.toStringAsFixed(1))
    ).toList();

    return SingleChildScrollView(

      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Center(child: safeImage("images/foods/$recipeImageUrl", 300.w, 200.h)),
          SizedBox(height: 15.h),
          Center(
            child: Text(
              recipeName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.sp),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RecipeModeSelector(),
              SizedBox(width: 15.w),
              MultiplierInput(onSubmitted: _loadData),
            ],
          ),
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
            amounts: roundedAmounts,
            recipeLink: recipeLink,
            recipeType: recipeType,
            servings: context.watch<RecipeProvider>().multiplier,
            cookingMode: context.watch<RecipeProvider>().modeIndex,
          ),
          SizedBox(height: 20.h),
          Opacity(
            opacity: (recipeLink != '') ? 1.0 : 0.5,
            child: IgnorePointer(
              ignoring: recipeLink == '',
              child: RecipeLinkButton(recipeLink: recipeLink),
            ),
          ),
        ],
      ),
    );
  }
}
