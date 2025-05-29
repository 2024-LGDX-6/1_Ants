
// 반환용 DTO 클래스 정의
class UserFridgeDataDTO {
  final int fridgeIngredientsId;
  final int deviceId ; // 냉장고ID: 3번
  final String deviceName;
  final int userId = 1;
  final String userName;
  final String fridgeIngredients;

  UserFridgeDataDTO({
    required this.fridgeIngredientsId,
    required this.deviceId,
    required this.deviceName,
    required this.userName,
    required this.fridgeIngredients
  });

}

class UserFridgeController {

}