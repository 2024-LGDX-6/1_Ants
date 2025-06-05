class RecommendController {
  // 하루 권장량(그램 단위 예시)
  final Map<String, double> _recommendedAmounts = {
    '고춧가루': 5.0,
    '설탕': 30.0,
    '소금': 6.0,
    '다시다': 2.0,
  };

  // 추천 이름 리스트
  List<String> getRecommendedNames(List<String> seasonings) {
    return seasonings.where((e) => _recommendedAmounts.containsKey(e)).toList();
  }

  // multiplier를 인자로 받도록 변경
  List<String> getRecommendedPercents({
    required List<String> seasonings,
    required List<double> amounts,
    required int multiplier,
  }) {
    List<String> percents = [];

    for (int i = 0; i < seasonings.length; i++) {
      final item = seasonings[i];
      if (_recommendedAmounts.containsKey(item)) {
        final recAmount = _recommendedAmounts[item]!;
        final usedPerServing = amounts[i] / multiplier;
        final percentValue = (usedPerServing / recAmount) * 100;
        percents.add("${percentValue.toStringAsFixed(0)}%");
      }
    }

    return percents;
  }
}