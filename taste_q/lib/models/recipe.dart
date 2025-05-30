
class Recipe {
  // 레시피명, 레시피사진, 조미료종류, 조미료량, 레시피링크, 모드유형
  final int recipeId;
  final String recipeName;
  final String recipeImageUrl;
  final int cookTimeMin;
  final String recipeLink;
  final String recipeIngredient;

  Recipe({
    required this.recipeId,
    required this.recipeName,
    required this.recipeImageUrl,
    required this.cookTimeMin,
    required this.recipeLink,
    required this.recipeIngredient,
  });

}