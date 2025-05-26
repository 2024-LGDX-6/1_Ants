/// [RecipeMode]는 레시피의 설정 모드를 나타내는 열거형(enum)입니다.
/// - 표준, 웰빙, 미식 모드를 명확한 이름으로 구분하기 위해 사용됩니다.
/// - UI에서는 드롭다운 등의 항목 표시로 사용되고
/// - 백엔드 서버와 연동할 때는 index(int) 값으로 직렬화됩니다.
/// - 코드 가독성과 유지보수를 위해 int 대신 enum을 사용합니다.
enum RecipeMode {
  standard, // 0번
  wellness, // 1번
  gourmet,  // 2번
}

extension RecipeModeExtension on RecipeMode {
  // 서버로 전송할 때 enum -> int 변환
  int get indexValue => index;

  // 서버에서 받은 int -> enum으로 변환
  static RecipeMode fromIndex(int index) => RecipeMode.values[index];
}

// UI 표시에 사용할 라벨 맵
const Map<RecipeMode, String> modeLabels = {
  RecipeMode.standard: '표준모드',
  RecipeMode.wellness: '웰빙모드',
  RecipeMode.gourmet: '미식모드',
};
