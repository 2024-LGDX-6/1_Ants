import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:taste_q/controllers/dto/custom_recipe_data_dto.dart';
import 'package:taste_q/models/image_mapping.dart';
import 'package:taste_q/providers/recipe_provider.dart';
import '../models/recipe_mode.dart';

class CustomRecipeController {

  static const String baseUrl = "http://192.168.219.130:8000";

  // 전체 개인 레시피 목록 불러오기 - getAllCustomRecipes()
  Future<CustomRecipeDataDTO> getAllRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/custom-recipes')); // FastAPI 엔드포인트

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      return CustomRecipeDataDTO.fromJson(jsonData, customRecipeImageMapping);
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }

  // 개인 레시피 데이터 불러오기 - getCustomRecipeData()
  Future<CustomRecipeDataDetailDto> getRecipeData(
      int recipeId, BuildContext context) async {
    // 1. 개인 레시피 기본 정보 요청
    final recipeResponse = await http.get(Uri.parse(
        '$baseUrl/custom-recipes/$recipeId'));
    if (recipeResponse.statusCode != 200) {
      throw Exception('레시피 정보를 불러올 수 없습니다.');
    }
    final recipeJson = json.decode(recipeResponse.body);

    // 2. 개인 레시피 시즈닝 상세정보 요청
    final detailResponse = await http.get(Uri.parse(
        '$baseUrl/custom-recipes/$recipeId/seasoning-details'));
    if (detailResponse.statusCode != 200) {
      throw Exception('레시피 조미료 정보를 불러올 수 없습니다.');
    }
    final List<dynamic> detailJson = json.decode(detailResponse.body);

    // 3. 개인 레시피 이미지 경로 매핑
    final imagePath = customRecipeImageMapping[recipeId] ?? 'default.jpg';

    // 4. 현재 모드와 인분 수 가져오기 (Provider)
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final mode = recipeProvider.mode;
    final multiplier = recipeProvider.multiplier;

    // 5. 모드와 인분에 따른 amounts 연산 후 변환
    final modifiedAmounts = detailJson.map((e) {
      double originalAmount = (e['amount'] as num).toDouble();
      switch (mode) {
        case RecipeMode.wellness:
          originalAmount -= originalAmount * 0.1;  // 웰빙모드
          break;
        case RecipeMode.gourmet:
          originalAmount += originalAmount * 0.1;  // 미식모드
          break;
        case RecipeMode.standard: // 표준모드: 그대로
          break;
      }
      originalAmount *= multiplier;  // multiplier 곱셈은 마지막에
      return originalAmount;
    }).toList();


    // 6. RecipeDataDTO 반환 (amounts를 변환값으로 교체)
    return CustomRecipeDataDetailDto(
      recipeId: recipeJson['custom_recipe_id'],
      recipeName: recipeJson['custom_recipe_name'],
      recipeImageUrl: imagePath,
      seasoningNames: detailJson.map((e) => e['seasoning_name'] as String).toList(),
      amounts: modifiedAmounts,
    );
  }

  // RecipeModeSelector, SettingView에서 사용될 provider 메소드 (mode + multiplier)
  void updateModeAndMultiplier(BuildContext context, RecipeMode newMode, int newMultiplier) {
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    provider.setMode(newMode);  // 모드 설정
    provider.setMultiplier(newMultiplier);  // 인분 수(multiplier) 설정
  }

  RecipeMode getCurrentMode(BuildContext context) {
    return Provider.of<RecipeProvider>(context, listen: false).mode;
  }

  int getCurrentMultiplier(BuildContext context) {
    return Provider.of<RecipeProvider>(context, listen: false).multiplier;
  }

}