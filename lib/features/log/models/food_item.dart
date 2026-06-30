class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.defaultUnit,
    required this.defaultQuantity,
    required this.gramsPerUnit,
    this.availableUnits = const ['mana', 'grams', 'cups'],
  });

  final String id;
  final String name;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final String defaultUnit;
  final double defaultQuantity;
  final Map<String, double> gramsPerUnit; // grams per 1 unit
  final List<String> availableUnits;

  double gramsFor(double quantity, String unit) =>
      (gramsPerUnit[unit] ?? 100) * quantity;

  double kcalFor(double quantity, String unit) =>
      kcalPer100g * gramsFor(quantity, unit) / 100;

  double proteinFor(double quantity, String unit) =>
      proteinPer100g * gramsFor(quantity, unit) / 100;

  double carbsFor(double quantity, String unit) =>
      carbsPer100g * gramsFor(quantity, unit) / 100;

  double fatFor(double quantity, String unit) =>
      fatPer100g * gramsFor(quantity, unit) / 100;
}
