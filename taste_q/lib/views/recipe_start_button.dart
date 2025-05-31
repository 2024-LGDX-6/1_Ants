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
    this.connectedDevice,
    this.txCharacteristic,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
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
