
class CookLogDataDTO {
  final int logId; // 저장로그 아이디
  final int recipeId; // 레시피 아이디
  final String recipeName; // 레시피 이름
  final int cookingMode; // 조리모드(표준, 웰빙, 미식)
  final String startTime; // (조리시작시간)
  final int servings; // 인분 수
  final int recipeType; // 레시피 유형(일반, 개인)

  CookLogDataDTO({
    required this.logId,
    required this.recipeId,
    required this.recipeName,
    required this.cookingMode,
    required this.startTime,
    required this.servings,
    required this.recipeType,
  });

  // JSon -> DTO 변환 factory 생성자
  factory CookLogDataDTO.fromJson(Map<String, dynamic> json) {
    return CookLogDataDTO(
        logId: json["log_id"] as int,
        recipeId: json["recipe_id"] as int,
        recipeName: json["recipe_name"] as String,
        cookingMode: json["cooking_mode"] as int,
        startTime: json["start_time"] as String,
        servings: json["servings"] as int,
        recipeType: json["recipe_type"] as int,
    );
  }
}