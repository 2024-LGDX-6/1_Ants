
class Recipe {
  // 레시피명, 레시피사진, 조미료종류, 조미료량, 레시피링크, 모드유형
  final String recipeTitle;
  final String recipeImageUrl;
  final List<String> condimentTypes; // 플러터에선 튜플형은 갯수 제한 있음
  final List<double> condimentUsages;
  final String recipeLinkUrl;
  int mode; // 번경될 값

  Recipe({
    required this.recipeTitle,
    required this.recipeImageUrl,
    required this.condimentTypes,
    required this.condimentUsages,
    required this.recipeLinkUrl,
    required this.mode
  });

}