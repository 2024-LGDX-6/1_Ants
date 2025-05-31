// 반환용 DTO 클래스 정의
class RecipeDataDTO {
  final int recipeId;
  final String recipeName;
  final String recipeImageUrl;
  final List<String> seasoningNames;
  final List<double> amounts;
  final String recipeLink;
  final int recipeType = 0;

  RecipeDataDTO({
    required this.recipeId,
    required this.recipeName,
    required this.recipeImageUrl,
    required this.seasoningNames,
    required this.amounts,
    required this.recipeLink,
  });

  // JSON -> DTO 변환
  // 서버에서 받아온 JSON 데이터를 DTO 객체로 변환하는 factory 메서드
  factory RecipeDataDTO.fromJson(
      Map<String, dynamic> json, List<dynamic> details, String imagePath) {
    // details: 시즈닝 상세 정보 (List<Map> 형태)
    final seasoningNames = details.map((e) => e['seasoning_name'] as String).toList();
    final amounts = details.map((e) => (e['amount'] as num).toDouble()).toList();

    return RecipeDataDTO(
      recipeId: json['recipe_id'],
      recipeName: json['recipe_name'],
      recipeImageUrl: imagePath, // 이미지 매핑 경로를 전달
      seasoningNames: seasoningNames,
      amounts: amounts,
      recipeLink: json['recipe_link'],
    );
  }

}