import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:taste_q/controllers/dto/main_data_dto.dart';
import 'package:taste_q/models/home.dart';
import 'package:taste_q/models/image_mapping.dart';
import 'package:taste_q/models/recipe.dart';

class MainController {
  // 하드코딩 데이터
  List<Recipe> recipeList = [
    Recipe(
      recipeId: 3,
      recipeName: "너비아니",
      recipeImageUrl: 'neobiani.jpg',
      cookTimeMin: 0,
      recipeLink: 'https://www.10000recipe.com/recipe/2338708',
      recipeIngredient: "고기"
    ),
  ];

  List<HomeFeedback> feedbackList = [
    HomeFeedback(feedbackId: 0, feedbackText: "짰어요", ),
    HomeFeedback(feedbackId: 1, feedbackText: "달았어요."),
    HomeFeedback(feedbackId: 2, feedbackText: "맛있어요."),
    HomeFeedback(feedbackId: 3, feedbackText: "싱거웠어요")
  ];

  List<HomeTip> tipList = [
    HomeTip(
      tipId: 0,
      tipText: "lG 스마트 광파오븐과 연동하면 빠른 예열이 가능해요!",
      tipImg: "elec_oven.png",
    ),
  ];

  static const String baseUrl = "http://192.168.219.130:8000";

  // 전체 레시피 목록 불러오기
  Future<MainDataDTO> getAllRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/recipes')); // FastAPI 엔드포인트

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      return MainDataDTO.fromJson(jsonData, recipeImageMapping);
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }


  // 메인화면: 오늘의 추천 요리
  // 레시피 데이터 중 추천용 3개 불러오기
  Future<MainDataDTO> getRecommendedRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/recipes'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      // 추천 레시피 중복 없이 랜덤 3개 선택
      final random = Random();
      final shuffledList = List.from(jsonData.toSet())..shuffle(random);
      final limitedData = shuffledList.length >= 3
          ? shuffledList.sublist(0, 3)
          : shuffledList.sublist(0, shuffledList.length);

      return MainDataDTO.fromJson(limitedData, recipeImageMapping);

    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }

  // 메인화면: 나의 요리 기록
  String getLastRecipeFeedback() {
    final recipeName = recipeList[0].recipeName; // 레시피명
    final feedbackText = feedbackList[2].feedbackText;

    return '어제 $recipeName를 드셨어요!\n\n평가: "$feedbackText"';
  }

  // 메인화면: 오늘의 팁
  String getRandomTip() {
    return "LG전자의 스마트 광파오븐과 \n연동하면 빠른 예열이 가능해요!";
  }

}