import 'package:taste_q/models/image_mapping.dart';

class CustomRecipeDataDTO {
  final List<int> recipeIds; // customRecipeIds
  final List<String> recipeNames; // customReceipeNames
  final List<String> recipeImageUrls; // customRecipeImageUrls
  final List<String> recipeIngredients; // customRecipeIngredients

  CustomRecipeDataDTO({
    required this.recipeIds,
    required this.recipeNames,
    required this.recipeImageUrls,
    required this.recipeIngredients,
  });

  // JSON -> DTO 변환
  factory CustomRecipeDataDTO.fromJson(
      List<dynamic> jsonList, Map<int, String> recipeImageMapping) {
    // 각 필드별 리스트를 초기화
    final customRecipeIds = <int>[];
    final customReceipeNames = <String>[];
    final customRecipeImageUrls = <String>[];
    final customIngredients = <String>[];

    // JSON 배열 데이터를 순회하면서 각 필드 추출
    for (var item in jsonList) {
      // 1️. recipe_id를 추출하고 리스트에 추가
      final id = item['custom_recipe_id'] as int;
      customRecipeIds.add(id);

      // 2️. recipe_name을 추출하고 리스트에 추가
      customReceipeNames.add(item['custom_recipe_name']);

      // 3️. 이미지 경로는 백엔드 데이터에 없으므로
      // 프론트에서 정의한 imageMapping에서 recipe_id에 해당하는 경로를 찾아 추가
      // 만약 매핑이 없다면 'default.jpg'를 기본값으로 설정
      customRecipeImageUrls.add(customRecipeImageMapping[id] ?? 'default.jpg');

      // 4. main_ingredient를 추출하고 리스트에 추가
      customIngredients.add(item['custom_main_ingredient']);
    }

    // MainDataDTO 객체 생성 및 반환
    return CustomRecipeDataDTO(
        recipeIds: customRecipeIds,
        recipeNames: customReceipeNames,
        recipeImageUrls: customRecipeImageUrls,
        recipeIngredients: customIngredients
    );
  }
}

class CustomRecipeDataDetailDto {
  final int recipeId; // customRecipeId
  final String recipeName; // customRecipeName
  final String recipeImageUrl; // customRecipeImageUrl
  final List<String> seasoningNames; // seasoningNames
  final List<double> amounts; // amounts
  final String recipeLink = '';

  CustomRecipeDataDetailDto({
    required this.recipeId,
    required this.recipeName,
    required this.recipeImageUrl,
    required this.seasoningNames,
    required this.amounts,
  });

  // JSON -> DTO 변환
  // 서버에서 받아온 JSON 데이터를 DTO 객체로 변환하는 factory 메서드
  factory CustomRecipeDataDetailDto.fromJson(
      Map<String, dynamic> json, List<dynamic> details, String imagePath) {
    // details: 시즈닝 상세 정보 (List<Map> 형태)
    final seasoningNames = details.map((e) => e['seasoning_name'] as String).toList();
    final amounts = details.map((e) => (e['amount'] as num).toDouble()).toList();

    return CustomRecipeDataDetailDto(
      recipeId: json['custom_recipe_id'],
      recipeName: json['custom_recipe_name'],
      recipeImageUrl: imagePath, // 이미지 매핑 경로를 전달
      seasoningNames: seasoningNames,
      amounts: amounts,
    );
  }

}
