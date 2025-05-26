import '../models/recipe.dart';
import '../models/recipe_mode.dart';

class RecipeController {
  late Recipe recipe;

  RecipeController() {
    recipe = getRecipeData(); // 초기화
  }

  // 초기 하드코딩 데이터 반환
  Recipe getRecipeData() {
    return Recipe(
      recipeTitle: '김치찌개',
      recipeImageUrl: 'images/foods/kimchi.jpg',
      condimentTypes: ['소금', '고추가루', '후추'],
      condimentUsages: [2.5, 12, 0.6],
      recipeLinkUrl: 'https://www.10000recipe.com/recipe/3686217',
      mode: 0, // 기본: 표준모드
    );
  }

  // RecipeModeSelector, SettingView에서 사용될 메소드
  RecipeMode getCurrentMode() => RecipeModeExtension.fromIndex(recipe.mode);

  void updateMode(RecipeMode newMode) {
    recipe.mode = newMode.indexValue;
  }

}
