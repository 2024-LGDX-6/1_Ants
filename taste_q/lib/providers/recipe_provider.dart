import 'package:flutter/material.dart';
import '../models/recipe_mode.dart';

class RecipeProvider with ChangeNotifier {
  RecipeMode _mode = RecipeMode.standard; // 기본 모드
  int _multiplier = 1; // 기본 1인분

  // 현재 모드 가져오기
  RecipeMode get mode => _mode;

  // 현재 모드 index (서버 전송용)
  int get modeIndex => _mode.toInt();

  // 현재 모드의 라벨 (UI 표시용)
  String get modeLabel => modeLabels[_mode]!;

  // 현재 인분 수 가져오기
  int get multiplier => _multiplier;

  // 모드 변경 (RecipeMode로 직접)
  void setMode(RecipeMode newMode) {
    _mode = newMode;
    notifyListeners();
  }

  // 인분 수 변경
  void setMultiplier(int newMultiplier) {
    _multiplier = newMultiplier;
    notifyListeners();
  }

  // 페이지 이동 시 인분 수 초기화
  void resetMultiplier() {
    _multiplier = 1;
    notifyListeners();
  }

  // 모드 변경 (index 값으로)
  void updateRecipeMode(int index) {
    _mode = RecipeModeExtension.fromInt(index);
    notifyListeners();
  }
}
