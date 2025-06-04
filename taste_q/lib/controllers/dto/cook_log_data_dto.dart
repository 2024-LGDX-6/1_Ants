
import 'package:taste_q/controllers/dto/image_data_dto.dart';

class CookLogDataDTO {
  final int logId;          // 저장 로그 아이디
  final int recipeId;       // 레시피 아이디
  final String recipeName;  // 레시피 이름
  final String recipeImage; // 레시피 이미지 경로
  final int cookingMode;    // 조리 모드 (표준, 웰빙, 미식)
  final String startTime;   // 조리 시작 시간
  final int servings;       // 인분 수
  final int recipeType;     // 레시피 유형 (일반, 개인)

  CookLogDataDTO({
    required this.logId,
    required this.recipeId,
    required this.recipeName,
    required this.recipeImage,
    required this.cookingMode,
    required this.startTime,
    required this.servings,
    required this.recipeType,
  });

  factory CookLogDataDTO.fromJson(
      Map<String, dynamic> json,
      List<dynamic> imageJsonList,
      ) {
    // 1. 요리 로그 필드
    final logId       = json['log_id'] as int;
    final recipeId    = json['recipe_id'] as int;
    final recipeName  = json['recipe_name'] as String;
    final cookingMode = json['cooking_mode'] as int;
    final startTime   = json['start_time'] as String;
    final servings    = json['servings'] as int;
    final recipeType  = json['recipe_type'] as int;

    // 2. imageJsonList를 ImageDataDto 객체 리스트로 변환
    final imageDtoList = imageJsonList
        .map((item) => ImageDataDto.fromJson(item as Map<String, dynamic>))
        .toList();

    // 3. recipeId와 매칭되는 ImageDataDto를 찾아 imagePath를 가져오기
    final match = imageDtoList.firstWhere(
          (imgDto) => imgDto.recipeId == recipeId,
      orElse: () => ImageDataDto(
        imageId: -1,
        recipeId: recipeId,
        imageName: 'default',
        imagePath: 'about:blank#blocked',
      ),
    );
    final recipeImage = match.imagePath;

    return CookLogDataDTO(
      logId: logId,
      recipeId: recipeId,
      recipeName: recipeName,
      recipeImage: recipeImage,
      cookingMode: cookingMode,
      startTime: startTime,
      servings: servings,
      recipeType: recipeType,
    );
  }
}