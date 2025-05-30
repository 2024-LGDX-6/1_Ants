// 반환용 DTO 클래스 정의
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

  // JSON -> DTO 변환
  factory MainDataDTO.fromJson(
      List<dynamic> jsonList, Map<int, String> recipeImageMapping) {
    // 각 필드별 리스트를 초기화
    final recipeIds = <int>[];
    final recipeNames = <String>[];
    final recipeImageUrls = <String>[];
    final recipeIngredients = <String>[];

    // JSON 배열 데이터를 순회하면서 각 필드 추출
    for (var item in jsonList) {
      // 1️. recipe_id를 추출하고 리스트에 추가
      final id = item['recipe_id'] as int;
      recipeIds.add(id);

      // 2️. recipe_name을 추출하고 리스트에 추가
      recipeNames.add(item['recipe_name']);

      // 3️. 이미지 경로는 백엔드 데이터에 없으므로
      // 프론트에서 정의한 imageMapping에서 recipe_id에 해당하는 경로를 찾아 추가
      // 만약 매핑이 없다면 'default.jpg'를 기본값으로 설정
      recipeImageUrls.add(recipeImageMapping[id] ?? 'default.jpg');

      // 4. main_ingredient를 추출하고 리스트에 추가
      recipeIngredients.add(item['main_ingredient']);
    }

    // MainDataDTO 객체 생성 및 반환
    return MainDataDTO(
        recipeIds: recipeIds,
        recipeNames: recipeNames,
        recipeImageUrls: recipeImageUrls,
        recipeIngredients: recipeIngredients
    );
  }

}