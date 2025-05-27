import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeLinkButton extends StatelessWidget {
  final String recipeLink;

  const RecipeLinkButton({super.key, required this.recipeLink});

  // URL 열기 함수
  Future<void> _launchURL(linkUrl) async {
    final Uri url = Uri.parse(linkUrl);
    try { // 기본 브라우저로 열기
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (error) {
      print('Error launching URL: $error');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: ElevatedButton(
        onPressed: () {
          _launchURL(recipeLink);
          print("인터넷 브라우저로 열기");
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 42.h, vertical: 6.w),
          backgroundColor: Colors.grey[100],
        ),
        child: Text(
          '레시피 보러가기',
          style: TextStyle(fontSize: 18.sp, color: Colors.black),
        ),
      ),
    );
  }
}
