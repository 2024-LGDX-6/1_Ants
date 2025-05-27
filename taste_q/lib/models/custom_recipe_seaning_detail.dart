
class CustomRecipeSeaningDetail {
  final int detailId;
  final int customRecipeId;
  final int seasoningId;
  int amount;
  String unit;
  int injectionOrder;

  CustomRecipeSeaningDetail({
    required this.detailId,
    required this.customRecipeId,
    required this.seasoningId,
    required this.amount,
    required this.unit,
    required this.injectionOrder
  });

}