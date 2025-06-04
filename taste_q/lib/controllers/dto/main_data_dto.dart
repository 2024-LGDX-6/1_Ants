// 반환용 DTO 클래스 정의
import 'image_data_dto.dart';

class MainDataDTO {
  final List<int> recipeIds;
  final List<String> recipeNames;
  final List<String> recipeImageUrls;
  final List<String> recipeIngredients;

  MainDataDTO({
    required this.recipeIds,
    required this.recipeNames,
    required this.recipeImageUrls,
    required this.recipeIngredients,
  });

  /// imageJsonList: JSON 리스트 형태로 들어온 이미지 정보
  /// (ImageDataDto.fromJson이 가능한 구조)
  factory MainDataDTO.fromJson(
      List<dynamic> recipeJsonList,
      List<dynamic> imageJsonList,
      ) {
    // 1) 레시피 데이터에서 ID, 이름, 주재료 뽑기
    final recipeIds = <int>[];
    final recipeNames = <String>[];
    final recipeIngredients = <String>[];

    for (var item in recipeJsonList) {
      recipeIds.add(item['recipe_id'] as int);
      recipeNames.add(item['recipe_name'] as String);
      recipeIngredients.add(item['main_ingredient'] as String);
    }

    // 2) imageJsonList를 ImageDataDto 객체 리스트로 변환
    final imageDtoList = imageJsonList
        .map((json) => ImageDataDto.fromJson(json as Map<String, dynamic>))
        .toList();

    // 3) recipeIds 순서대로 매칭되는 imagePath를 찾아 recipeImageUrls에 추가
    final recipeImageUrls = <String>[];
    for (var id in recipeIds) {
      final match = imageDtoList.firstWhere(
            (imgDto) => imgDto.recipeId == id,
        orElse: () => ImageDataDto(
          imageId: -1,
          recipeId: id,
          imageName: 'default',
          imagePath: 'about:blank#blocked',
        ),
      );
      recipeImageUrls.add(match.imagePath);
    }

    return MainDataDTO(
      recipeIds: recipeIds,
      recipeNames: recipeNames,
      recipeImageUrls: recipeImageUrls,
      recipeIngredients: recipeIngredients,
    );
  }
}