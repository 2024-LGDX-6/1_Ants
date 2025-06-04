
class ImageDataDto {
  final int imageId;
  final int recipeId;
  final String imageName;
  final String imagePath;

  ImageDataDto({
    required this.imageId,
    required this.recipeId,
    required this.imageName,
    required this.imagePath,
  });

  // factory 메서드 (JSON 파싱)
  factory ImageDataDto.fromJson(Map<String, dynamic> json) {
    // json 리스트의 각 요소를 String으로 변환
    return ImageDataDto(
      imageId: json['image_id'] as int,
      recipeId: json['recipe_id'] as int,
      imageName: json['image_name'] as String,
      imagePath: json['image_path'] as String
    );
  }

}

class CustomImageDataDto {
  final int customImageId;
  final int customRecipeId;
  final String customImageName;
  final String customImagePath;

  CustomImageDataDto({
    required this.customImageId,
    required this.customRecipeId,
    required this.customImageName,
    required this.customImagePath,
  });

  // factory 메서드 (JSON 파싱)
  factory CustomImageDataDto.fromJson(Map<String, dynamic> json) {
    // json 리스트의 각 요소를 String으로 변환
    return CustomImageDataDto(
      customImageId: json['custom_image_id'] as int,
      customRecipeId: json['custom_recipe_id'] as int,
      customImageName: json['custom_image_name'] as String,
      customImagePath: json['custom_image_path'] as String
    );
  }
}