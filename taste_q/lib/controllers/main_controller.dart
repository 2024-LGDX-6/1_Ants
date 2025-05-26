import '../models/home.dart';

class MainController {
  List<Home> getRecommendedRecipes() {
    return [
      Home(title: '콩나물 불고기', imageUrl: 'images/foods/jeyuk.jpg'),
      Home(title: '김치찌개', imageUrl: 'images/foods/kimchi.jpg'),
      Home(title: '불고기', imageUrl: 'images/foods/bulgogi.jpg'),
    ];
  }

  String getLastRecipeFeedback() {
    return '어제 너비아니를 드셨어요!\n\n평가: "맛있었어요."';
  }

  String getRandomTip() {
    return "lG 스마트 광파오븐과 연동하면 빠른 예열이 가능해요!";
  }

}