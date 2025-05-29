import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/user_fridge_controller.dart';
import 'package:taste_q/views/ingredient_appbar.dart';

class IngredientScreen extends StatefulWidget {
  final int userId;
  final UserFridgeController controller;

  const IngredientScreen({
    super.key,
    required this.userId,
    required this.controller,
  });

  @override
  _IngredientScreenState createState() => _IngredientScreenState();
}

// 냉장고 재료 리스트뷰 타일 출력
class _IngredientScreenState extends State<IngredientScreen> {
  late Future<List<UserFridgeDataDTO>> _futureFridgeData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureFridgeData = widget.controller.getFridgeDataByUser(widget.userId, 3);
  }

  Future<void> _deleteItem(String fridgeIngredient) async {
    try {
      await widget.controller.deleteFridgeIngredient(3, fridgeIngredient);
      setState(() {
        _loadData(); // 삭제 후 데이터 다시 로드
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IngredientAppBar(),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<UserFridgeDataDTO>>(
        future: _futureFridgeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('냉장고 데이터가 없습니다.'));
          } else {
            final fridgeData = snapshot.data!;

            return ListView.builder(
              padding: EdgeInsets.all(16.h),
              itemCount: fridgeData.length,
              itemBuilder: (context, index) {
                final item = fridgeData[index];
                return Card(
                  color: Colors.white,
                  elevation: 0.5,
                  margin: EdgeInsets.symmetric(vertical: 8.r),
                  child: ListTile(
                    title: Text(item.fridgeIngredients),
                    trailing: IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => _deleteItem(item.fridgeIngredients),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
