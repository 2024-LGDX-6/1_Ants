import 'package:flutter/material.dart';
import '../models/recipe_mode.dart';

class RecipeProvider with ChangeNotifier {
  RecipeMode _mode = RecipeMode.standard; // 기본 모드

  // 현재 모드 가져오기
  RecipeMode get mode => _mode;

  // 현재 모드 index (서버 전송용)
  int get modeIndex => _mode.indexValue;

  // 현재 모드의 라벨 (UI 표시용)
  String get modeLabel => modeLabels[_mode]!;

  // 모드 변경 (RecipeMode로 직접)
  void setMode(RecipeMode newMode) {
    _mode = newMode;
    notifyListeners();
  }

  // 모드 변경 (index 값으로)
  void updateRecipeMode(int index) {
    _mode = RecipeModeExtension.fromIndex(index);
    notifyListeners();
  }
}
