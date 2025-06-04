import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/custom_recipe_controller.dart';
import 'package:taste_q/controllers/main_controller.dart';
import 'package:taste_q/models/route_entry_type.dart';
import 'package:taste_q/screens/recipe_data_screen.dart';
import 'package:taste_q/views/front_appbar.dart';

class RecipeListScreen extends StatefulWidget {
  final RouteEntryType routeEntryType;
  final String? searchQuery;

  const RecipeListScreen({
    super.key,
    required this.routeEntryType,
    required this.searchQuery
  });

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late Future<dynamic> _futureRecipes; // 반환 타입 dynamic으로 통일
  late TextEditingController _searchController;
  String _searchText = '';

  late dynamic controller;

  @override
  void initState() {
    super.initState();

    // RouteEntryType에 따라 올바른 컨트롤러 인스턴스 생성
    switch (widget.routeEntryType) {
      case RouteEntryType.anotherDefault:
        controller = MainController();
        break;
      case RouteEntryType.customRecipeList:
        controller = CustomRecipeController();
        break;
    }
    // 전체 레시피 Future 로드
    _futureRecipes = controller.getAllRecipes();

    // 검색 컨트롤러 초기화
    _searchController = TextEditingController();

    // 음성인식 팝업에서 전달된 searchQuery가 있으면 미리 텍스트 설정
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchController.text = widget.searchQuery!;
      _searchText = widget.searchQuery!.toLowerCase();
    } else {
      _searchText = '';
    }

    // 사용자 검색창을 수정할 때마다 _searchText 갱신
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
    // build는 Future<Widget>이 아니라 Widget을 반환해야 함
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FrontAppBar(appBarName: "레시피 목록",),
      body: Column(
        children: [
          // 레시피 검색창
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
            child: FutureBuilder<dynamic>( // dynamic으로 변경
              future: _futureRecipes, // await 제거
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('에러: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data.recipeIds.isEmpty) {
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
                            // print(recipes.recipeIds[index]);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDataScreen(
                                  routeEntryType: widget.routeEntryType,
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
