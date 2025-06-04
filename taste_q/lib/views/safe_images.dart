import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/models/base_url.dart';

String baseUrl = BaseUrl.baseUrl;

// 이미지 출력 위젯 메소드
Widget safeImage(String imagePath, double width, double height, {
  double borderRadius = 8.0,
  BoxFit fit = BoxFit.cover,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius.r),
    child: Image.network(
      "$baseUrl$imagePath",
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

