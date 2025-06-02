import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taste_q/controllers/dto/cook_log_data_dto.dart';

class CookLogController {
  static const String baseUrl = "http://192.168.219.66:8000";

  // 전체 요리기록에서 마지막 기록 불러오기
  Future<List<CookLogDataDTO>> getLastCookLog() async {
    final response = await http.get(Uri.parse('$baseUrl/cooking-logs'));
    if (response.statusCode != 200) {
      throw Exception('서버 오류: ${response.statusCode}');
    }
    final List<dynamic> jsonList = json.decode(response.body);

    // ['log_id']의 최대값을 구함
    final maxLogId = jsonList
        .map((item) => item['log_id'])
        .fold<int?>(null, (prev, elem) => prev == null
        ? elem : (elem > prev ? elem : prev));

    // 최대 log_id만 가진 json만 필터링
        final filtered = jsonList
            .where((item) => item['log_id'] == maxLogId)
            .toList();

    // DTO 리스트로 변환
        return filtered
          .map(
            (item) => CookLogDataDTO(
              logId: item['log_id'],
              recipeId: item['recipe_id'],
              recipeName: item['recipe_name'],
              cookingMode: item['cooking_mode'],
              startTime: item['start_time'],
              servings: item['servings'],
              recipeType: item['recipe_type'],
            ),
          ).toList();
  }

  // 저장기록 추가(create) 로직
  Future<void> createCookLog(
      int recipeId, int cookingMode,
      DateTime startTime, int servings, int recipeType
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cooking-logs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'recipe_id': recipeId,
        'cooking_mode': cookingMode,
        'start_time': startTime,
        'servings': servings,
        'recipe_type': recipeType
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('재료 추가 실패: ${response.statusCode}');
    }
  }

}
