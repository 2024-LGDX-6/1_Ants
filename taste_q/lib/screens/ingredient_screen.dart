import 'package:flutter/material.dart';
import 'package:taste_q/views/ingredient_appbar.dart';

class IngredientScreen extends StatelessWidget {
  const IngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터
    final List<String> ingredients = ['계란', '우유', '버터', '당근', '치즈'];

    return Scaffold(
      appBar: const IngredientAppBar(),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            elevation: 0.5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(ingredients[index]),
            ),
          );
        },
      ),
    );
  }
}