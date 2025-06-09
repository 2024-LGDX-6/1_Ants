import 'dart:convert';
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

  /// 냉장고 재료가 있을 때만 최대 3개 추천, 없으면 빈 리스트 반환
  /// - userId: 로그인된 사용자 ID
  /// - deviceId: 사용할 냉장고 장치 ID
  Future<MainDataDTO> getRecommendedRecipes(int userId, int deviceId) async {
    // 1) 냉장고 재료 요청
    final fridgeRes = await http.get(Uri.parse('$baseUrl/user-fridge/$userId'));
    if (fridgeRes.statusCode != 200) {
      throw Exception('냉장고 정보를 불러올 수 없습니다. (${fridgeRes.statusCode})');
    }
    final fridgeJson = json.decode(fridgeRes.body) as List<dynamic>;
    final fridgeList = fridgeJson
        .map((e) => UserFridgeDataDTO.fromJson(e as Map<String, dynamic>))
        .where((dto) => dto.deviceId == deviceId)
        .toList();
    final items = fridgeList.map((dto) => dto.fridgeIngredients).toSet();

    // 2) 전체 레시피 가져오기
    final recipeRes = await http.get(Uri.parse('$baseUrl/recipes'));
    if (recipeRes.statusCode != 200) {
      throw Exception('레시피 정보를 불러올 수 없습니다. (${recipeRes.statusCode})');
    }
    final recipeJson = json.decode(recipeRes.body) as List<dynamic>;

    // 3) 재료 일치 레시피 필터 (없으면 빈 리스트 반환)
    final matching = items.isEmpty
        ? <dynamic>[]
        : recipeJson.where((r) => items.contains(r['main_ingredient'] as String)).toList();

    // 4) 최대 3개로 자르기
    final limited = matching.length > 3 ? matching.sublist(0, 3) : matching;

    // 5) 이미지 전체 목록 요청
    final imageRes = await http.get(Uri.parse('$baseUrl/recipe-image/all'));
    if (imageRes.statusCode != 200) {
      throw Exception('이미지 정보를 불러올 수 없습니다. (${imageRes.statusCode})');
    }
    final imageJson = json.decode(imageRes.body) as List<dynamic>;

    // 6) DTO 생성 및 반환
    return MainDataDTO.fromJson(limited, imageJson);
  }


  // 메인화면: 오늘의 팁 (하드코딩)
  String getRandomTip() {
    return "LG전자의 스마트 광파오븐과 \n연동하면 빠른 예열이 가능해요!";
  }

}