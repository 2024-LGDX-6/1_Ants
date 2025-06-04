// 반환용 DTO 클래스 정의
import 'package:taste_q/controllers/dto/image_data_dto.dart';

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


  /// details: seasoning 상세 정보 리스트
  factory RecipeDataDTO.fromJson(
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

    // 2. imageJsonList를 ImageDataDto 리스트로 변환
    final imageDtoList = imageJsonList
        .map((img) => ImageDataDto.fromJson(img as Map<String, dynamic>))
        .toList();

    // 3. recipeId와 매칭되는 imagePath 찾기
    final currentId = json['recipe_id'] as int;
    final match = imageDtoList.firstWhere(
          (imgDto) => imgDto.recipeId == currentId,
      orElse: () => ImageDataDto(
        imageId: -1,
        recipeId: currentId,
        imageName: 'default',
        imagePath: 'default.jpg',
      ),
    );
    final imagePath = match.imagePath;

    return RecipeDataDTO(
      recipeId: currentId,
      recipeName: json['recipe_name'] as String,
      recipeImageUrl: imagePath,
      seasoningNames: seasoningNames,
      amounts: amounts,
      recipeLink: json['recipe_link'] as String,
    );
  }

}