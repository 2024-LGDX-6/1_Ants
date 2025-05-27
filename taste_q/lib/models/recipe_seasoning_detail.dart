
class RecipeSeasoningDetail {
  final int detailId;
  final int recipeId;
  final int seasoningId;
  final double amount;
  final String unit = 'g'; // 단위
  final int injectionOrder;

  RecipeSeasoningDetail({
    required this.detailId,
    required this.recipeId,
    required this.seasoningId,
    required this.amount,
    required this.injectionOrder,
  });

}