import 'package:taste_q/models/home.dart';
import 'package:taste_q/models/recipe.dart';

// 반환용 DTO 클래스 정의
class MainDataDTO {
  final List<String> recipeNames;
  final List<String> recipeImageUrls;

  MainDataDTO({
    required this.recipeNames,
    required this.recipeImageUrls,
  });

  // JSON -> DTO 변환
  factory MainDataDTO.fromJson(Map<String, dynamic> json) {
    return MainDataDTO(
      recipeNames: List<String>.from(json['recipeNames']),
      recipeImageUrls: List<String>.from(json['recipeImageUrls']),
    );
  }

}

class MainController {
  List<Recipe> recipeList = [
    Recipe(
      recipeId: 0,
      recipeName: "김치찌개",
      recipeImageUrl: 'kimchi.jpg',
      recipeLink: 'https://www.10000recipe.com/recipe/6864674',
      mode: 0, // 기본: 표준모드
    ),
    Recipe(
      recipeId: 1,
      recipeName: "제육볶음",
      recipeImageUrl: 'jeyuk.jpg',
      recipeLink: 'https://www.10000recipe.com/recipe/6856673',
      mode: 0, // 기본: 표준모드
    ),
    Recipe(
      recipeId: 2,
      recipeName: "불고기",
      recipeImageUrl: 'bulgogi.jpg',
      recipeLink: 'https://www.10000recipe.com/recipe/6867715',
      mode: 0, // 기본: 표준모드
    ),
    Recipe(
      recipeId: 3,
      recipeName: "너비아니",
      recipeImageUrl: 'neobiani.jpg',
      recipeLink: 'https://www.10000recipe.com/recipe/2338708',
      mode: 0, // 기본: 표준모드
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
  MainDataDTO getRecommendedRecipes() {
    final limitedRecipes = recipeList.length >= 3
        ? recipeList.sublist(0, 3)
        : recipeList.sublist(0, recipeList.length);

    final recommendedRecipeNames = limitedRecipes.map((rn) => rn.recipeName).toList();
    final recommendedRecipeImages = limitedRecipes.map((ri) => ri.recipeImageUrl).toList();

    return MainDataDTO(
        recipeNames: recommendedRecipeNames,
        recipeImageUrls: recommendedRecipeImages
    );
  }

  // List<Home> getRecommendedRecipes() {
  //   return [
  //     Home(recipeName: '콩나물 불고기', recipeImageUrl: 'images/foods/jeyuk.jpg'),
  //     Home(recipeName: '김치찌개', recipeImageUrl: 'images/foods/kimchi.jpg'),
  //     Home(recipeName: '불고기', recipeImageUrl: 'images/foods/bulgogi.jpg'),
  //   ];
  // }


  // 메인화면: 나의 요리 기록
  String getLastRecipeFeedback() {
    final recipeName = recipeList[3].recipeName; // 레시피명
    final feedbackText = feedbackList[2].feedbackText;

    return '어제 $recipeName를 드셨어요!\n\n평가: "$feedbackText"';
  }

  // 메인화면: 오늘의 팁
  String getRandomTip() {
    return "lG전자의 스마트 광파오븐과 \n연동하면 빠른 예열이 가능해요!";
  }

}