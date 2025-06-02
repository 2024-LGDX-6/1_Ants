import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/models/route_entry_type.dart';
import 'package:taste_q/views/front_appbar.dart';
import 'package:taste_q/views/recipe_data_view.dart';
import '../providers/recipe_provider.dart';

class RecipeDataScreen extends StatelessWidget {
  final RouteEntryType routeEntryType;
  final int recipeId;

  const RecipeDataScreen({
    super.key,
    required this.routeEntryType,
    required this.recipeId
  });

  @override
  Widget build(BuildContext context) {
    // final controller = RecipeController();

    return Scaffold(
      appBar: FrontAppBar(appBarName: "레시피 정보",),
      backgroundColor: Colors.white,
      body: Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          return RecipeDataView(
            routeEntryType: routeEntryType,
            // controller: controller,
            recipeId: recipeId,
          );
        },
      ),
    );
  }
}