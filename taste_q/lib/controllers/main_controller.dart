import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:taste_q/controllers/dto/main_data_dto.dart';

import '../models/base_url.dart';

class MainController {

  String baseUrl = BaseUrl.baseUrl;

  /// 전체 레시피 + 이미지 링크 결합
  Future<MainDataDTO> getAllRecipes() async {
    // 1. 레시피 데이터 요청
    final recipeRes = await http.get(Uri.parse('$baseUrl/recipes'));
    if (recipeRes.statusCode != 200) {
      throw Exception('서버 오류: ${recipeRes.statusCode}');
    }
    final List<dynamic> recipeJson = json.decode(recipeRes.body);

    // 2. 전체 이미지 링크 데이터 요청
    final imageRes = await http.get(Uri.parse('$baseUrl/recipe-image/all'));
    if (imageRes.statusCode != 200) {
      throw Exception('서버 오류: ${imageRes.statusCode}');
    }
    final List<dynamic> imageJson = json.decode(imageRes.body);

    // 3. DTO 생성 (레시피 JSON + 이미지 JSON)
    return MainDataDTO.fromJson(recipeJson, imageJson);
  }

  /// 추천 레시피 3개 + 이미지 링크 결합
  Future<MainDataDTO> getRecommendedRecipes() async {
    // 1. 전체 레시피 가져오기
    final recipeRes = await http.get(Uri.parse('$baseUrl/recipes'));
    if (recipeRes.statusCode != 200) {
      throw Exception('서버 오류: ${recipeRes.statusCode}');
    }
    final List<dynamic> recipeJson = json.decode(recipeRes.body);

    // 2. 랜덤으로 3개 선택
    final random = Random();
    final shuffled = List.from(recipeJson.toSet())..shuffle(random);
    final limitedRecipes = (shuffled.length >= 3)
        ? shuffled.sublist(0, 3)
        : shuffled.sublist(0, shuffled.length);

    // 3. 이미지 링크 데이터 요청
    final imageRes = await http.get(Uri.parse('$baseUrl/recipe-image/all'));
    if (imageRes.statusCode != 200) {
      throw Exception('서버 오류: ${imageRes.statusCode}');
    }
    final List<dynamic> imageJson = json.decode(imageRes.body);

    // 4. DTO 생성 (추천된 3개 JSON + 전체 이미지 JSON → 내부에서 매핑)
    return MainDataDTO.fromJson(limitedRecipes, imageJson);
  }

  // 메인화면: 오늘의 팁 (하드코딩)
  String getRandomTip() {
    return "LG전자의 스마트 광파오븐과 \n연동하면 빠른 예열이 가능해요!";
  }

}