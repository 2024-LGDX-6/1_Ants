import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/providers/recipe_provider.dart'; // 상태관리 라이브러리
import 'package:taste_q/screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RecipeProvider(), // 전역 상태 보존
      child: ScreenUtilInit(
        designSize: Size(375, 812),
        builder:
            (context, child) => MaterialApp(
              debugShowCheckedModeBanner: false,
              home: HomeScreen(),
            ),
      ),
    ),
  );
}
