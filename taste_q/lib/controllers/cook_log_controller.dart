import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taste_q/controllers/dto/cook_log_data_dto.dart';
import 'package:taste_q/models/base_url.dart';

class CookLogController {
  String baseUrl = BaseUrl.baseUrl;

  /// 전체 요리 기록 중에서 가장 마지막(log_id가 최대인) 항목들을 가져오고,
  /// 각 항목에 맞는 레시피 이미지를 imageDtoList에서 찾아 CookLogDataDTO로 반환
  Future<List<CookLogDataDTO>> getLastCookLog() async {
    // 1. 전체 요리 기록 요청
    final response = await http.get(Uri.parse('$baseUrl/cooking-logs'));
    if (response.statusCode != 200) {
      throw Exception('서버 오류: ${response.statusCode}');
    }
    final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;

    // 2. 최대 log_id 구하기
    final maxLogId = jsonList
        .map((item) => item['log_id'] as int)
        .fold<int?>(null, (prev, elem) => prev == null
        ? elem : (elem > prev ? elem : prev));

    // 3. 마지막 로그(log_id == maxLogId)만 필터링
    final filtered = jsonList.where((item) => item['log_id'] == maxLogId).toList();

    // 4. 전체 레시피 이미지 목록 요청 (List<dynamic> 형태)
    final imageResponse = await http.get(Uri.parse('$baseUrl/recipe-image/all'));
    if (imageResponse.statusCode != 200) {
      throw Exception('이미지 정보를 불러올 수 없습니다. (${imageResponse.statusCode})');
    }
    final List<dynamic> imageJsonList = json.decode(imageResponse.body) as List<dynamic>;

    // 5. filtered 리스트를 CookLogDataDTO로 변환하여 반환
    return filtered.map((item) {
      // CookLogDataDTO.fromJson에는 :
      //  - item         : 요리 로그 하나(Map<String, dynamic>)
      //  - imageJsonList: 전체 이미지 정보(JSON 배열)
      return CookLogDataDTO.fromJson(item as Map<String, dynamic>, imageJsonList);
    }).toList();
  }

  // 저장기록 추가(create) 로직
  Future<void> createCookLog(
      int recipeId, int cookingMode,
      int servings, int recipeType
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cooking-logs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'recipe_id': recipeId,
        'cooking_mode': cookingMode,
        'servings': servings,
        'recipe_type': recipeType
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('재료 추가 실패: ${response.statusCode}');
    }
  }

}
