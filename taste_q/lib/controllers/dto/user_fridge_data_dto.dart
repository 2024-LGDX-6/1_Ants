// 반환용 DTO 클래스 정의
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
