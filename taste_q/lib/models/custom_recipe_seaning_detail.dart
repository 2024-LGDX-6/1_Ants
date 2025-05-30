
class CustomRecipeSeaningDetail {
  final int detailId;
  final int customRecipeId;
  final int seasoningId;
  final double amount;
  final String unit = 'g'; // 단위
  final int injectionOrder;

  CustomRecipeSeaningDetail({
    required this.detailId,
    required this.customRecipeId,
    required this.seasoningId,
    required this.amount,
    required this.injectionOrder
  });

}