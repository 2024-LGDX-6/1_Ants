import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/recipe_mode.dart';
import '../controllers/recipe_controller.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeController _controller = RecipeController();

  // 현재 Recipe 모델 객체
  Recipe get recipe => _controller.recipe;

  // 현재 선택된 레시피 모드(enum)
  RecipeMode get selectedMode => RecipeModeExtension.fromIndex(recipe.mode);

  // 모드 설정 변경 및 알림
  void updateRecipeMode(RecipeMode newMode) {
    _controller.updateMode(newMode);
    notifyListeners();
    // await _controller.saveModeToServer(); // 서버에도 반영
  }

  /// 서버 연동 시 controller와 provider 역할을 분명히!

}
