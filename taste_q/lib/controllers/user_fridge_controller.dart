import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taste_q/controllers/dto/user_fridge_data_dto.dart';

// 데이터 반환 컨트롤러
class UserFridgeController {
  static const String baseUrl = "http://192.168.219.66:8000";

  // 특정 user_id와 device_id에 해당하는 냉장고 데이터 반환
  Future<List<UserFridgeDataDTO>> getFridgeDataByUser(
    int userId,
    int targetDeviceId,
  ) async {
    final response = await http.get(Uri.parse('$baseUrl/user-fridge/$userId'));
    if (response.statusCode != 200) {
      throw Exception('서버 오류: ${response.statusCode}');
    }
    final List<dynamic> jsonList = json.decode(response.body);

    // device_id == targetDeviceId인 데이터만 필터링
    final filtered =
        jsonList.where((item) => item['device_id'] == targetDeviceId).toList();

    // DTO 리스트로 변환
    return filtered
        .map(
          (item) => UserFridgeDataDTO(
            fridgeIngredientsId: item['fridge_Ingredients_id'],
            deviceId: item['device_id'],
            deviceName: item['device_name'],
            userId: item['user_id'],
            userName: item['user_name'],
            fridgeIngredients: item['fridge_Ingredients'],
          ),
        ).toList();
  }

  // 데이터 추가(create) 로직
  Future<void> createUserFridge(int deviceId, String fridgeIngredient) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user-fridge'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': deviceId,
        'fridge_Ingredients': fridgeIngredient,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('재료 추가 실패: ${response.statusCode}');
    }
  }

  // 데이터 삭제(delete) 로직
  Future<void> deleteFridgeIngredient(
    int deviceId,
    String fridgeIngredient,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/user-fridge?device_id=$deviceId&ingredient=${
            Uri.encodeComponent(fridgeIngredient)}',
      ),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('삭제 실패: ${response.statusCode}');
    }
  }

}
