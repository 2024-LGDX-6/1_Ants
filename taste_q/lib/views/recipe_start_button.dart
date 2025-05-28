import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/screens/loading_screen.dart';


class RecipeStartButton extends StatelessWidget {
  const RecipeStartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoadingScreen()),
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
