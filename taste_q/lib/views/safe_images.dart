import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 이미지 출력 위젯 메소드
Widget safeImage(String assetPath, double width, double height, {
  double borderRadius = 8.0,
  BoxFit fit = BoxFit.cover,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius.r),
    child: Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // 오류 발생 시 공백 칸 출력
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius.r),
            color: Colors.grey[300],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.image_not_supported, size: width * 0.5, color: Colors.grey),
        );
      },
    ),
  );
}

