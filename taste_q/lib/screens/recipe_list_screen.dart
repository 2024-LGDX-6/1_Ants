import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/dto/main_data_dto.dart';
import 'package:taste_q/controllers/main_controller.dart';
import 'package:taste_q/screens/recipe_data_screen.dart';
import 'package:taste_q/views/front_appbar.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late Future<MainDataDTO> _futureRecipes;
  late TextEditingController _searchController;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    final controller = MainController();
    _futureRecipes = controller.getAllRecipes();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrontAppBar(),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '레시피 검색',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // FutureBuilder로 기존 리스트 출력
          Expanded(
            child: FutureBuilder<MainDataDTO>(
              future: _futureRecipes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('에러: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.recipeIds.isEmpty) {
                  return const Center(child: Text('레시피가 없습니다.'));
                } else {
                  final recipes = snapshot.data!;
                  final filteredIndices = List.generate(recipes.recipeNames.length, (index) => index)
                      .where((i) =>
                          recipes.recipeNames[i].toLowerCase().contains(_searchText) ||
                          recipes.recipeIngredients[i].toLowerCase().contains(_searchText))
                      .toList();

                  return ListView.builder(
                    itemCount: filteredIndices.length,
                    itemBuilder: (context, idx) {
                      final index = filteredIndices[idx];
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.w),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.asset(
                              "images/foods/${recipes.recipeImageUrls[index]}",
                              width: 60.w,
                              height: 50.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(
                            recipes.recipeNames[index],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("주재료: ${recipes.recipeIngredients[index]}"),
                          trailing: Icon(
                            Icons.arrow_forward,
                            color: Colors.orangeAccent,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDataScreen(
                                  recipeId: recipes.recipeIds[index],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
