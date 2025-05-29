// 반환용 DTO 클래스 정의
import 'dart:convert';

import 'package:http/http.dart' as http;

class UserFridgeDataDTO {
  final int fridgeIngredientsId;
  final int deviceId; // 냉장고ID: 3번
  final String deviceName;
  final int userId;
  final String userName;
  final String fridgeIngredients;

  UserFridgeDataDTO({
    required this.fridgeIngredientsId,
    required this.deviceId,
    required this.deviceName,
    required this.userId,
    required this.userName,
    required this.fridgeIngredients,
  });

  // JSON -> DTO 변환 factory 생성자
  factory UserFridgeDataDTO.fromJson(Map<String, dynamic> json) {
    return UserFridgeDataDTO(
      fridgeIngredientsId: json['fridge_Ingredients_id'] as int,
      deviceId: json['device_id'] as int,
      deviceName: json['device_name'] as String,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      fridgeIngredients: json['fridge_Ingredients'] as String,
    );
  }
}

// 데이터 반환 컨트롤러
class UserFridgeController {
  static const String baseUrl = "http://192.168.219.207:8000";

  // 특정 user_id와 device_id에 해당하는 냉장고 데이터 반환
  Future<List<UserFridgeDataDTO>> getFridgeDataByUser(
    int userId,
    int targetDeviceId,
  ) async {
    final response = await http.get(Uri.parse('$baseUrl/user-fridge/$userId'));
    if (response.statusCode != 200) {
      throw Exception('냉장고 정보를 불러올 수 없습니다.');
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
      throw Exception('재료 추가 실패');
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
      throw Exception('삭제 실패');
    }
  }

  // Future<void> deleteFridgeIngredient(int deviceId, String fridgeIngredient) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/user-fridge'), // POST 방식 엔드포인트
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'device_id': deviceId,
  //       'fridge_Ingredients': fridgeIngredient,
  //     }),
  //   );
  //   if (response.statusCode != 200) {
  //     throw Exception('삭제 실패');
  //   }
  // }

}
