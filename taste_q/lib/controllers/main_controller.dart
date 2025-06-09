import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:taste_q/controllers/dto/main_data_dto.dart';
import 'package:taste_q/controllers/dto/user_fridge_data_dto.dart';

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

  /// 냉장고 재료 기반으로 추천 레시피 3개 + 이미지 링크 결합
  /// 냉장고 정보가 정상적으로 로드되면 해당 재료와 일치하는 레시피를 최대 3개 추천,
  /// 냉장고 정보 로드에 실패하거나 일치 레시피가 없으면 전체 레시피 중 랜덤으로 3개 추천
  Future<MainDataDTO> getRecommendedRecipes(int userId, int deviceId) async {
    /// - userId: 로그인된 사용자 ID
    /// - deviceId: 사용할 냉장고 장치 ID
    List<String> fridgeItems = [];

    // 1) 냉장고 재료 목록 시도
    try {
      final fridgeRes = await http.get(Uri.parse('$baseUrl/user-fridge/$userId'));
      if (fridgeRes.statusCode == 200) {
        final List<dynamic> fridgeJson = json.decode(fridgeRes.body) as List<dynamic>;
        final fridgeList = fridgeJson
            .map((e) => UserFridgeDataDTO.fromJson(e as Map<String, dynamic>))
            .where((dto) => dto.deviceId == deviceId)
            .toList();
        fridgeItems = fridgeList.map((dto) => dto.fridgeIngredients).toList();
      }
    } catch (_) {
      // 무시하고 전체 레시피 랜덤 추천으로 넘어감
    }

    // 2) 전체 레시피 가져오기
    final recipeRes = await http.get(Uri.parse('$baseUrl/recipes'));
    if (recipeRes.statusCode != 200) {
      throw Exception('레시피 정보를 불러올 수 없습니다. (${recipeRes.statusCode})');
    }
    final List<dynamic> recipeJson = json.decode(recipeRes.body) as List<dynamic>;

    // 3) 추천 후보 결정
    List<dynamic> candidates;
    if (fridgeItems.isNotEmpty) {
      // 냉장고 재료와 일치하는 레시피 필터
      final matching = recipeJson.where((item) {
        return fridgeItems.contains(item['main_ingredient'] as String);
      }).toList();
      // 일치 레시피가 있으면 그 중에서, 없으면 전체 중에서 고르기
      candidates = matching.isNotEmpty ? matching : recipeJson;
    } else {
      // 냉장고 정보가 없으면 전체에서 랜덤 추천
      candidates = recipeJson;
    }

    // 4) 랜덤으로 최대 3개 추출
    final random = Random();
    final shuffled = List.from(candidates)..shuffle(random);
    final limited = shuffled.length >= 3 ? shuffled.sublist(0, 3) : shuffled;

    // 5) 이미지 링크 전체 목록 요청
    final imageRes = await http.get(Uri.parse('$baseUrl/recipe-image/all'));
    if (imageRes.statusCode != 200) {
      throw Exception('이미지 정보를 불러올 수 없습니다. (${imageRes.statusCode})');
    }
    final List<dynamic> imageJson = json.decode(imageRes.body) as List<dynamic>;

    // 6) DTO 생성 및 반환
    return MainDataDTO.fromJson(limited, imageJson);
  }


  // 메인화면: 오늘의 팁 (하드코딩)
  String getRandomTip() {
    return "LG전자의 스마트 광파오븐과 \n연동하면 빠른 예열이 가능해요!";
  }

}