
class CookLogDataDTO {
  final int recipeId; // 레시피 아이디
  final String recipeName; // 레시피 이름
  final int cookingMode; // 조리모드(표준, 웰빙, 미식)
  final DateTime startTime; // (조리시작시간)
  final int servings; // 인분 수
  final int recipeType; // 레시피 유형(일반, 개인)
  final String feedback; // 레시피 피드백

  CookLogDataDTO({
    required this.recipeId,
    required this.recipeName,
    required this.cookingMode,
    required this.startTime,
    required this.servings,
    required this.recipeType,
    required this.feedback,
  });
}