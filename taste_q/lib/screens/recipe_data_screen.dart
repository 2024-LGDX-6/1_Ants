import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/views/front_appbar.dart';
import 'package:taste_q/views/recipe_data_view.dart';
import '../providers/recipe_provider.dart';

class RecipeDataScreen extends StatelessWidget {
  const RecipeDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FrontAppBar(),
      backgroundColor: Colors.white,
      body: Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RecipeDataView(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 버튼 클릭 시 동작 정의
                  print("요리 시작 버튼이 눌렸습니다.");
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  '요리 시작',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}