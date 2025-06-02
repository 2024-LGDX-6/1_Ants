import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/screens/loading_screen.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RecipeStartButton extends StatelessWidget {
  final String recipeImageUrl;
  final String recipeName;
  final int recipeId;
  final List<String> seasoningName;
  final List<double> amounts;
  final String recipeLink;
  final int recipeType;
  final int servings;
  final int cookingMode;
  final BluetoothDevice? connectedDevice;
  final BluetoothCharacteristic? txCharacteristic;

  const RecipeStartButton({
    super.key,
    required this.recipeImageUrl,
    required this.recipeName,
    required this.recipeId,
    required this.seasoningName,
    required this.amounts,
    required this.recipeLink,
    required this.recipeType,
    required this.servings,
    required this.cookingMode,
    this.connectedDevice,
    this.txCharacteristic,
  });

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.now();

    return Center(
      child: ElevatedButton(
        onPressed: () {
          print({
            "레시피명 : $recipeName",
            "$seasoningName 사용량 : ${amounts}g",
            "레시피 유형 : $recipeType (0번: 일반용, 1번: 개인용)",
            "레시피 모드 : $cookingMode (0번: 표준, 1번: 웰빙, 2번: 미식)",
            "인원 수 : $servings인분",
            "시작 시간 : $dateTime"
          });
          // 버튼 클릭 시 동작 정의
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoadingScreen(
                recipeImageUrl: recipeImageUrl,
                recipeName: recipeName,
                recipeId: recipeId,
                seasoningName: seasoningName,
                amounts: amounts,
                recipeLink: recipeLink,
                recipeType: recipeType,
                servings: servings,
                cookingMode: cookingMode,
                startTime: dateTime.toString(),
                connectedDevice: connectedDevice,
                txCharacteristic: txCharacteristic,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 32.h, vertical: 16.w),
          backgroundColor: Colors.orange,
        ),
        child: const Text(
          '요리 시작',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
