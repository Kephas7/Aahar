class FoodLogEntry {
  const FoodLogEntry({
    required this.id,
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.loggedAt,
    required this.mealType,
  });

  final String id;
  final String foodName;
  final double quantity;
  final String unit;
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final DateTime loggedAt;
  final String mealType; // 'Breakfast', 'Lunch', 'Snack', 'Dinner'

  Map<String, Object?> toJson() => {
    'id': id,
    'foodName': foodName,
    'quantity': quantity,
    'unit': unit,
    'kcal': kcal,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
    'loggedAt': loggedAt.toIso8601String(),
    'mealType': mealType,
  };

  static FoodLogEntry fromJson(Map<String, dynamic> json) {
    return FoodLogEntry(
      id: json['id'] as String,
      foodName: json['foodName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      kcal: (json['kcal'] as num).toDouble(),
      proteinG: (json['proteinG'] as num).toDouble(),
      carbsG: (json['carbsG'] as num).toDouble(),
      fatG: (json['fatG'] as num).toDouble(),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      mealType: json['mealType'] as String,
    );
  }

  String get timeLabel {
    final h = loggedAt.hour;
    final m = loggedAt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'pm' : 'am';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m$period';
  }

  String get portionLabel => '${_fmt(quantity)} $unit';

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  static String mealTypeForTime(DateTime t) {
    final h = t.hour;
    if (h >= 5 && h < 10) return 'Breakfast';
    if (h >= 10 && h < 12) return 'Snack';
    if (h >= 12 && h < 15) return 'Lunch';
    if (h >= 15 && h < 17) return 'Snack';
    if (h >= 17 && h < 21) return 'Dinner';
    return 'Snack';
  }
}
