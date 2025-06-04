import 'package:taste_q/controllers/dto/image_data_dto.dart';

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
      List<dynamic> recipeJsonList,
      List<dynamic> imageJsonList,
      ) {
    // 1) 레시피 데이터에서 ID, 이름, 주재료 뽑기
    final customRecipeIds = <int>[];
    final customReceipeNames = <String>[];
    final customIngredients = <String>[];

    for (var item in recipeJsonList) {
      customRecipeIds.add(item['custom_recipe_id'] as int);
      customReceipeNames.add(item['custom_recipe_name'] as String);
      customIngredients.add(item['custom_main_ingredient'] as String);
    }

    // 2) imageJsonList를 CustomImageDataDto 객체 리스트로 변환
    final imageDtoList = imageJsonList
        .map((json) => CustomImageDataDto.fromJson(json as Map<String, dynamic>))
        .toList();

    // 3) recipeIds 순서대로 매칭되는 imagePath를 찾아 recipeImageUrls에 추가
    final recipeImageUrls = <String>[];
    for (var id in customRecipeIds) {
      final match = imageDtoList.firstWhere(
            (imgDto) => imgDto.customRecipeId == id,
        orElse: () => CustomImageDataDto(
          customImageId: -1,
          customRecipeId: id,
          customImageName: 'default',
          customImagePath: 'about:blank#blocked',
        ),
      );
      recipeImageUrls.add(match.customImagePath);
    }

    return CustomRecipeDataDTO(
      recipeIds: customRecipeIds,
      recipeNames: customReceipeNames,
      recipeImageUrls: recipeImageUrls,
      recipeIngredients: customIngredients,
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
  final int recipeType = 1;

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
      Map<String, dynamic> json,
      List<dynamic> details,
      List<dynamic> imageJsonList,
      ) {
    // 1. 조미료 이름과 양 추출
    final seasoningNames = details
        .map((e) => e['seasoning_name'] as String)
        .toList();
    final amounts = details
        .map((e) => (e['amount'] as num).toDouble())
        .toList();

    // 2. imageJsonList를 CustomImageDataDto 리스트로 변환
    final imageDtoList = imageJsonList
        .map((img) => CustomImageDataDto.fromJson(img as Map<String, dynamic>))
        .toList();

    // 3. recipeId와 매칭되는 imagePath 찾기
    final currentId = json['recipe_id'] as int;
    final match = imageDtoList.firstWhere(
          (imgDto) => imgDto.customRecipeId == currentId,
      orElse: () => CustomImageDataDto(
        customImageId: -1,
        customRecipeId: currentId,
        customImageName: 'default',
        customImagePath: 'default.jpg',
      ),
    );
    final imagePath = match.customImagePath;

    return CustomRecipeDataDetailDto(
      recipeId: currentId,
      recipeName: json['custom_recipe_id'] as String,
      recipeImageUrl: imagePath,
      seasoningNames: seasoningNames,
      amounts: amounts,
    );
  }

}
