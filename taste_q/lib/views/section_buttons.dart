import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 마이 레시피, 메뉴 찾기 버튼
class SectionButtons extends StatelessWidget {
  const SectionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.person, color: Colors.black, weight: 10),
            label: Text(
              "나만의 레시피",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 20.h,),
              backgroundColor: Colors.grey[300],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.bookmark_border, color: Colors.black, weight: 10),
            label: Text(
              "메뉴 찾기",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 20.h),
              backgroundColor: Colors.grey[300],
            ),
          ),
        ),
      ],
    );
  }
}
