import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taste_q/models/home.dart';
import 'package:taste_q/models/recipe.dart';

// 반환용 DTO 클래스 정의
class MainDataDTO {
  final List<int> recipeIds;
  final List<String> recipeNames;
  final List<String> recipeImageUrls;

  MainDataDTO({
    required this.recipeIds,
    required this.recipeNames,
    required this.recipeImageUrls,
  });

  // JSON -> DTO 변환
  factory MainDataDTO.fromJson(List<dynamic> jsonList, Map<int, String> imageMapping) {
    // 각 필드별 리스트를 초기화
    final recipeIds = <int>[];
    final recipeNames = <String>[];
    final recipeImageUrls = <String>[];

    // JSON 배열 데이터를 순회하면서 각 필드 추출
    for (var item in jsonList) {
      // 1️. recipe_id를 추출하고 리스트에 추가
      final id = item['recipe_id'] as int;
      recipeIds.add(id);

      // 2️. recipe_name을 추출하고 리스트에 추가
      recipeNames.add(item['recipe_name']);

      // 3️. 이미지 경로는 백엔드 데이터에 없으므로
      // 프론트에서 정의한 imageMapping에서 recipe_id에 해당하는 경로를 찾아 추가
      // 만약 매핑이 없다면 'default.jpg'를 기본값으로 설정
      recipeImageUrls.add(imageMapping[id] ?? 'default.jpg');
    }

    // MainDataDTO 객체 생성 및 반환
    return MainDataDTO(
      recipeIds: recipeIds,
      recipeNames: recipeNames,
      recipeImageUrls: recipeImageUrls,
    );
  }

}

class MainController {
  // 하드코딩 데이터
  List<Recipe> recipeList = [
    Recipe(
      recipeId: 3,
      recipeName: "너비아니",
      recipeImageUrl: 'neobiani.jpg',
      cookTimeMin: 0,
      recipeLink: 'https://www.10000recipe.com/recipe/2338708',
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

  // 메인화면: 오늘의 추천 요리
  static const String baseUrl = "http://192.168.219.207:8000";

  // 이미지 매핑 (recipe_id → local image path)
  final Map<int, String> imageMapping = {
    0: 'jeyuk.jpg',
    1: 'bulgogi.jpg',
    2: 'kimchi.jpg',
    3: 'neobiani.jpg',
    // 필요시 추가
  };

  // 레시피 데이터 불러오기 및 조합
  Future<MainDataDTO> getRecommendedRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/recipe')); // FastAPI 엔드포인트

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      // 추천 레시피 상위 3개 선택
      final limitedData = jsonData.length >= 3
          ? jsonData.sublist(0, 3)
          : jsonData.sublist(0, jsonData.length);

      return MainDataDTO.fromJson(limitedData, imageMapping);

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
    return "lG전자의 스마트 광파오븐과 \n연동하면 빠른 예열이 가능해요!";
  }

}