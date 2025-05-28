import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/models/recipe.dart';
import 'package:taste_q/models/recipe_mode.dart';
import 'package:taste_q/models/recipe_seasoning_detail.dart';
import 'package:taste_q/models/seasoning.dart';
import 'package:taste_q/providers/recipe_provider.dart';

// 반환용 DTO 클래스 정의
class RecipeDataDTO {
  final int recipeId;
  final String recipeName;
  final String recipeImageUrl;
  final List<String> seasoningNames;
  final List<double> amounts;
  final String recipeLink;
  // int mode; // 설정에서 변환

  RecipeDataDTO({
    required this.recipeId,
    required this.recipeName,
    required this.recipeImageUrl,
    required this.seasoningNames,
    required this.amounts,
    required this.recipeLink,
   // required this.mode,
  });

  // JSON -> DTO 변환
  factory RecipeDataDTO.fromJson(Map<String, dynamic> json) {
    return RecipeDataDTO(
      recipeId: json['recipeId'] as int,
      recipeName: json['recipeName'] as String,
      recipeImageUrl: json['recipeImageUrl'] as String,
      seasoningNames: List<String>.from(json['seasoningNames']),
      amounts: List<double>.from(json['amounts'].map(
        // num -> double 변환 처리
        (e) => (e as num).toDouble())
      ),
      recipeLink: json['recipeLink'] as String,
    );
  }

}

class RecipeController {
  List<Recipe> recipeList = [
    Recipe(
        recipeId: 0,
        recipeName: "김치찌개",
        recipeImageUrl: 'kimchi.jpg',
        cookTimeMin: 0,
        recipeLink: 'https://www.10000recipe.com/recipe/6864674',
    ),
  ];

  List<Seasoning> seasoningList = [
    Seasoning(seasoningId: 0, seasoningName: '소금'),
    Seasoning(seasoningId: 1, seasoningName: '고춧가루'),
    Seasoning(seasoningId: 2, seasoningName: '후추'),
  ];

  List<RecipeSeasoningDetail> recipeSeasoningDetails = [
    RecipeSeasoningDetail(
        detailId: 0,
        recipeId: 0,
        seasoningId: 0,
        amount: 2.5,
        injectionOrder: 0
    ),
    RecipeSeasoningDetail(
        detailId: 1,
        recipeId: 0,
        seasoningId: 1,
        amount: 10,
        injectionOrder: 1
    ),
    RecipeSeasoningDetail(
        detailId: 2,
        recipeId: 0,
        seasoningId: 2,
        amount: 0.5,
        injectionOrder: 2
    ),
  ];


  // 하드코딩 데이터 사용하는 경우: 기본 레시피 초기화
  late Recipe recipe;
  RecipeController() {
    recipe = recipeList[0]; // 김치찌개 레시피 사용
  }

  // 특정 레시피의 데이터 반환 (Map 형식)
  RecipeDataDTO getRecipeData(int recipeId) {
    final recipe = recipeList.firstWhere((r) => r.recipeId == recipeId);
    final details = recipeSeasoningDetails.where((d) => d.recipeId == recipeId).toList();

    // 해당 레시피의 조미료 상세정보만 추출
    final seasoningNames = details.map((d) {
      final seasoning = seasoningList.firstWhere((s) => s.seasoningId == d.seasoningId);
      return seasoning.seasoningName;
    }).toList();

    // 조미료 이름 및 사용량 추출
    final amounts = details.map((d) => d.amount).toList();

    return RecipeDataDTO(
      recipeId: recipe.recipeId, // 레시피ID
      recipeName: recipe.recipeName, // 레시피명
      recipeImageUrl: recipe.recipeImageUrl, // 레시피이미지
      seasoningNames: seasoningNames, // 조미로명 목록
      amounts: amounts, // 조미료별 사용량 목록
      recipeLink: recipe.recipeLink, // 레시피 원본 링크
    );
  }

  // Recipe getRecipeData() {
  //   return Recipe(
  //     recipeName: '김치찌개',
  //     recipeImageUrl: 'images/foods/kimchi.jpg',
  //     condimentTypes: ['소금', '고추가루', '후추'],
  //     condimentUsages: [2.5, 12, 0.6],
  //     recipeLink: 'https://www.10000recipe.com/recipe/3686217',
  //     mode: 0, // 기본: 표준모드
  //   );
  // }

  // RecipeModeSelector, SettingView에서 사용될 메소드
  void updateMode(BuildContext context, RecipeMode newMode) {
    // Provider에서 모드 설정
    Provider.of<RecipeProvider>(context, listen: false).setMode(newMode);
  }

  RecipeMode getCurrentMode(BuildContext context) {
    return Provider.of<RecipeProvider>(context, listen: false).mode;
  }

}
