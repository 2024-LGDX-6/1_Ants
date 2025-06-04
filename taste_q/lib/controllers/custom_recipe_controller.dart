import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:taste_q/controllers/dto/custom_recipe_data_dto.dart';
import 'package:taste_q/controllers/dto/image_data_dto.dart';
import 'package:taste_q/models/base_url.dart';
import 'package:taste_q/providers/recipe_provider.dart';
import '../models/recipe_mode.dart';

class CustomRecipeController {

  String baseUrl = BaseUrl.baseUrl;

  // 전체 개인 레시피 목록 불러오기 - getAllCustomRecipes()
  Future<CustomRecipeDataDTO> getAllRecipes() async {
    // 1. 레시피 데이터 요청
    final recipeRes = await http.get(Uri.parse('$baseUrl/custom-recipes'));
    if (recipeRes.statusCode != 200) {
      throw Exception('서버 오류: ${recipeRes.statusCode}');
    }
    final List<dynamic> recipeJson = json.decode(recipeRes.body);

    // 2. 전체 이미지 링크 데이터 요청
    final imageRes = await http.get(Uri.parse('$baseUrl/custom-recipe-image/all'));
    if (imageRes.statusCode != 200) {
      throw Exception('서버 오류: ${imageRes.statusCode}');
    }
    final List<dynamic> imageJson = json.decode(imageRes.body);

    // 3. DTO 생성 (레시피 JSON + 이미지 JSON)
    return CustomRecipeDataDTO.fromJson(recipeJson, imageJson);
  }

  // 개인 레시피 데이터 불러오기 - getCustomRecipeData()
  Future<CustomRecipeDataDetailDto> getRecipeData(int recipeId, BuildContext context) async {
    // 1. 레시피 기본 정보 요청
    final recipeResponse = await http.get(Uri.parse('$baseUrl/custom-recipes/$recipeId'));
    if (recipeResponse.statusCode != 200) {
      throw Exception('레시피 정보를 불러올 수 없습니다. (${recipeResponse.statusCode})');
    }
    final recipeJson = json.decode(recipeResponse.body) as Map<String, dynamic>;

    // 2. 레시피 시즈닝 상세정보 요청
    final detailResponse =
    await http.get(Uri.parse('$baseUrl/custom-recipes/$recipeId/seasoning-details'));
    if (detailResponse.statusCode != 200) {
      throw Exception('레시피 조미료 정보를 불러올 수 없습니다. (${detailResponse.statusCode})');
    }
    final List<dynamic> detailJson = json.decode(detailResponse.body) as List<dynamic>;

    // 3. “전체 레시피 이미지” 요청 (List<dynamic> 형태로 반환됨)
    final imageAllResponse = await http.get(Uri.parse('$baseUrl/custom-recipe-image/all'));
    if (imageAllResponse.statusCode != 200) {
      throw Exception(
          '전체 이미지 정보를 불러올 수 없습니다. (${imageAllResponse.statusCode})');
    }
    final List<dynamic> imageJsonList = json.decode(imageAllResponse.body) as List<dynamic>;

    // 4. imageJsonList를 ImageDataDto 리스트로 변환
    final imageDtoList = imageJsonList
        .map((json) => CustomImageDataDto.fromJson(json as Map<String, dynamic>))
        .toList();

    // 5. 전체 이미지 중 현재 recipeId와 매칭되는 항목을 찾음
    final match = imageDtoList.firstWhere(
          (imgDto) => imgDto.customRecipeId == recipeId,
      orElse: () => CustomImageDataDto(
        customImageId: -1,
        customRecipeId: recipeId,
        customImageName: 'default',
        customImagePath: 'about:blank#blocked',
      ),
    );
    final String imagePath = match.customImagePath;

    // 6. 현재 모드와 인분 수 가져오기 (Provider)
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final mode = recipeProvider.mode;
    final multiplier = recipeProvider.multiplier;

    // 7. 모드와 인분에 따른 amounts 연산 후 변환
    final modifiedAmounts = detailJson.map((e) {
      double originalAmount = (e['amount'] as num).toDouble();
      switch (mode) {
        case RecipeMode.wellness:
          originalAmount -= originalAmount * 0.1; // 웰빙모드: 10% 감량
          break;
        case RecipeMode.gourmet:
          originalAmount += originalAmount * 0.1; // 미식모드: 10% 증가
          break;
        case RecipeMode.standard:
          break; // 표준모드: 그대로
      }
      originalAmount *= multiplier; // 인분수 곱셈
      return originalAmount;
    }).toList();

    // 8. 조미료 이름 리스트 추출
    final seasoningNames =
    detailJson.map((e) => e['seasoning_name'] as String).toList();

    // 9. RecipeDataDTO 생성 후 반환
    return CustomRecipeDataDetailDto(
      recipeId: recipeJson['custom_recipe_id'] as int,
      recipeName: recipeJson['custom_recipe_name'] as String,
      recipeImageUrl: imagePath,
      seasoningNames: seasoningNames,
      amounts: modifiedAmounts,
    );
  }

  // 피드백 저장 - customPatchFeedback
  Future<void> patchFeedback(int customRecipeId, String feedback) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/custom-recipes/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'custom_recipe_id': customRecipeId,
        'feedback': feedback
      }),
    );
    if (response.statusCode != 200) {
      print('PATCH 요청 실패: ${response.statusCode}');
    }
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