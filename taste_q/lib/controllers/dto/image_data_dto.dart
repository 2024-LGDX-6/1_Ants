
class RecipeImageDto {
  final int imageId;
  final int recipeId;
  final String imageName;

  RecipeImageDto({
    required this.imageId,
    required this.recipeId,
    required this.imageName
  });

  // factory 메서드 (JSON 파싱)
  factory RecipeImageDto.fromJson(Map<String, dynamic> json) {
    // json 리스트의 각 요소를 String으로 변환
    return RecipeImageDto(
      imageId: json['image_id'] as int,
      recipeId: json['recipe_id'] as int,
      imageName: json['image_name'] as String,
    );
  }

}

class CustomImageDto {
  final int imageId;
  final int recipeId;
  final String imageName;

  CustomImageDto({
    required this.imageId,
    required this.recipeId,
    required this.imageName
  });

  // factory 메서드 (JSON 파싱)
  factory CustomImageDto.fromJson(Map<String, dynamic> json) {
    // json 리스트의 각 요소를 String으로 변환
    return CustomImageDto(
      imageId: json['image_id'] as int,
      recipeId: json['recipe_id'] as int,
      imageName: json['image_name'] as String,
    );
  }
}