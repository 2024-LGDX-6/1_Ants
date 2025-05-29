
class RecommendController {
  // 하루권장량 예시: 권장 사용량 임의로 지정
  final Set<String> _recommendedItems = {'고춧가루', '설탕', '소금', '다시다'};

  List<String> getRecommendedNames(List<String> seasonings) {
    return seasonings.where((e) => _recommendedItems.contains(e)).toList();
  }

  List<String> getRecommendedPercents(List<String> seasonings) {
    return seasonings.where((e) => _recommendedItems.contains(e)).map((e) {
      switch (e) {
        case '고춧가루':
          return '50%';
        case '설탕':
          return '50%';
        case '소금':
          return '25%';
        case '다시다':
          return '40%';
        default:
          return '10%';
      }
    }).toList();
  }
}