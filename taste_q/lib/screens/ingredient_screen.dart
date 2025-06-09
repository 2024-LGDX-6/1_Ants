import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/controllers/dto/user_fridge_data_dto.dart';
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
  // 기존 Future 대신 로컬 리스트와 로딩 플래그로 변경
  List<UserFridgeDataDTO> _fridgeData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(); // 로컬 리스트에 한 번만 불러옴
  }

  void _loadData() async {
    try {
      final list = await widget.controller.getFridgeDataByUser(widget.userId, 3);
      setState(() {
        _fridgeData = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('데이터 로드 실패: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('데이터 로드 실패: $e')),
      // );
    }
  }

  Future<void> _deleteItem(String fridgeIngredient) async {
    // 1) 로컬에서 즉시 삭제
    setState(() {
      _fridgeData.removeWhere((dto) => dto.fridgeIngredients == fridgeIngredient);
    });
    // 2) 서버에도 삭제 요청
    try {
      await widget.controller.deleteFridgeIngredient(3, fridgeIngredient);
    } catch (e) {
      // 실패 시 알림 및 복원
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e')),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_fridgeData.isEmpty) {
      return Scaffold(
        appBar: const IngredientAppBar(),
        body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Center(
              child: Text('냉장고 재료 데이터가 아직 없습니다.')
          )
        ),
      );
    }

    return Scaffold(
      appBar: const IngredientAppBar(),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: EdgeInsets.all(16.h),
        itemCount: _fridgeData.length,
        itemBuilder: (context, index) {
          final item = _fridgeData[index];
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
      ),
    );
  }
}
