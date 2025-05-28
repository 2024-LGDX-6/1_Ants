import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/views/front_appbar.dart';
import 'package:taste_q/views/recipe_data_view.dart';
import '../providers/recipe_provider.dart';

class RecipeDataScreen extends StatelessWidget {
  const RecipeDataScreen({super.key, required int recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FrontAppBar(),
      backgroundColor: Colors.white,
      body: Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          return RecipeDataView();
        },
      ),
    );
  }
}