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
  List<UserFridgeDataDTO> _fridgeData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await widget.controller.getFridgeDataByUser(widget.userId, 3);
      setState(() {
        _fridgeData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 로드 실패: $e')),
      );
    }
  }

  Future<void> _deleteItem(UserFridgeDataDTO item) async {
    setState(() {
      _fridgeData.remove(item); // UI 즉시 갱신
    });
    try {
      await widget.controller.deleteFridgeIngredient(
          item.deviceId, item.fridgeIngredients);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.fridgeIngredients} 삭제 완료')),
      );
    } catch (e) {
      // 실패 시 UI 복구
      setState(() {
        _fridgeData.add(item);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IngredientAppBar(),
      backgroundColor: Colors.white,
      body: _fridgeData.isEmpty
          ? const Center(child: Text('냉장고 데이터가 없습니다.'))
          : ListView.builder(
        padding: EdgeInsets.all(16.h),
        itemCount: _fridgeData.length,
        itemBuilder: (context, index) {
          final item = _fridgeData[index];
          return Card(
            color: Colors.grey[100],
            elevation: 0.5,
            margin: EdgeInsets.symmetric(vertical: 8.r),
            child: ListTile(
              title: Text(item.fridgeIngredients),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _deleteItem(item),
              ),
            ),
          );
        },
      ),
    );
  }
}
