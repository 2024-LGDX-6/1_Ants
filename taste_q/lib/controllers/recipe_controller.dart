import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:taste_q/models/image_mapping.dart';
import 'package:taste_q/models/recipe_mode.dart';
import 'package:taste_q/providers/recipe_provider.dart';

// 반환용 DTO 클래스 정의
class RecipeDataDTO {
  final int recipeId;
  final String recipeName;
  final String recipeImageUrl;
  final List<String> seasoningNames;
  final List<double> amounts;
  final String recipeLink;

  RecipeDataDTO({
    required this.recipeId,
    required this.recipeName,
    required this.recipeImageUrl,
    required this.seasoningNames,
    required this.amounts,
    required this.recipeLink,
  });

  // JSON -> DTO 변환
  // 서버에서 받아온 JSON 데이터를 DTO 객체로 변환하는 factory 메서드
  factory RecipeDataDTO.fromJson(
      Map<String, dynamic> json, List<dynamic> details, String imagePath) {
    // details: 시즈닝 상세 정보 (List<Map> 형태)
    final seasoningNames = details.map((e) => e['seasoning_name'] as String).toList();
    final amounts = details.map((e) => (e['amount'] as num).toDouble()).toList();

    return RecipeDataDTO(
      recipeId: json['recipe_id'],
      recipeName: json['recipe_name'],
      recipeImageUrl: imagePath, // 이미지 매핑 경로를 전달
      seasoningNames: seasoningNames,
      amounts: amounts,
      recipeLink: json['recipe_link'],
    );
  }

}

class RecipeController {
  static const String baseUrl = "http://192.168.219.207:8000";

  // 특정 레시피ID로 레시피 및 시즈닝 데이터를 백엔드에서 받아 RecipeDataDTO 반환
  Future<RecipeDataDTO> getRecipeData(int recipeId) async {
    // 1. 레시피 기본 정보 요청
    final recipeResponse = await http.get(Uri.parse(
        '$baseUrl/recipes/$recipeId'));
    if (recipeResponse.statusCode != 200) {
      throw Exception('레시피 정보를 불러올 수 없습니다.');
    }
    final recipeJson = json.decode(recipeResponse.body);

    // 2. 레시피 시즈닝 상세정보 요청
    final detailResponse = await http.get(Uri.parse(
        '$baseUrl/recipes/$recipeId/seasoning-details'));
    if (detailResponse.statusCode != 200) {
      throw Exception('레시피 조미료 정보를 불러올 수 없습니다.');
    }
    final List<dynamic> detailJson = json.decode(detailResponse.body);

    // 3. 이미지 경로 매핑
    final imagePath = recipeImageMapping[recipeId] ?? 'default.jpg';

    // 4. RecipeDataDTO 객체 반환
    return RecipeDataDTO.fromJson(recipeJson, detailJson, imagePath);
  }

  // 하드코딩 데이터 사용하는 경우: 기본 레시피 초기화
  // late Recipe recipe;
  // RecipeController() {
  //   recipe = recipeList[0]; // 김치찌개 레시피 사용
  // }

  // 특정 레시피의 데이터 반환
  // RecipeDataDTO getRecipeData(int recipeId) {
  //   final recipe = recipeList.firstWhere((r) => r.recipeId == recipeId);
  //   final details = recipeSeasoningDetails.where((d) => d.recipeId == recipeId).toList();
  //
  //   // 해당 레시피의 조미료 상세정보만 추출
  //   final seasoningNames = details.map((d) {
  //     final seasoning = seasoningList.firstWhere((s) => s.seasoningId == d.seasoningId);
  //     return seasoning.seasoningName;
  //   }).toList();
  //
  //   // 조미료 이름 및 사용량 추출
  //   final amounts = details.map((d) => d.amount).toList();
  //
  //   return RecipeDataDTO(
  //     recipeId: recipe.recipeId, // 레시피ID
  //     recipeName: recipe.recipeName, // 레시피명
  //     recipeImageUrl: recipe.recipeImageUrl, // 레시피이미지
  //     seasoningNames: seasoningNames, // 조미로명 목록
  //     amounts: amounts, // 조미료별 사용량 목록
  //     recipeLink: recipe.recipeLink, // 레시피 원본 링크
  //   );
  // }

  // RecipeModeSelector, SettingView에서 사용될 provider 메소드
  void updateMode(BuildContext context, RecipeMode newMode) {
    // Provider에서 모드 설정
    Provider.of<RecipeProvider>(context, listen: false).setMode(newMode);
  }

  RecipeMode getCurrentMode(BuildContext context) {
    return Provider.of<RecipeProvider>(context, listen: false).mode;
  }

}
