import 'food_item.dart';

class DetectedFood {
  DetectedFood({
    required this.foodItem,
    required this.confidencePercent,
    required this.defaultQuantity,
    this.isSelected = true,
  });

  final FoodItem foodItem;
  final int confidencePercent;
  final double defaultQuantity;
  bool isSelected;

  double get kcal =>
      foodItem.kcalFor(defaultQuantity, foodItem.defaultUnit);
}
