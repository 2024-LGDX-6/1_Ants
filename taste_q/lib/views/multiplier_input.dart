import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/providers/recipe_provider.dart';

class MultiplierInput extends StatelessWidget {
  final VoidCallback onSubmitted;

  const MultiplierInput({super.key, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<RecipeProvider>();
    final multiplierInt = recipeProvider.multiplier;
    final controller = TextEditingController(text: multiplierInt.toString());

    return SizedBox(
      width: 60.w,
      height: 40.h,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          label: Text(
            "인분 수",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.grey[100]
        ),
        onSubmitted: (value) {
          int newValue = (value.isEmpty) ? 1 : int.tryParse(value) ?? 1;
          if (newValue <= 0) newValue = 1;
          if (newValue > 10) newValue = 10;
          recipeProvider.setMultiplier(newValue);
          onSubmitted();  // 데이터 다시 불러오기 호출
        },
      ),
    );
  }
}

