import '../models/food_item.dart';

// Nutrition values are per 100g (approximate, based on USDA & local estimates)
// Nepali unit conversions:
//   1 mana (maan) ≈ 300g for cooked rice/dal dishes
//   1 mana for flat/dry foods (chiura) ≈ 200g
//   1 roti ≈ 50g
//   1 bowl ≈ 250ml/g (soups)
//   1 cup ≈ 240g

const List<FoodItem> kNepaliFoods = [
  // ── Staples ──────────────────────────────────────────────────────────────
  FoodItem(
    id: 'dal_bhat',
    name: 'Dal bhat',
    kcalPer100g: 93,
    proteinPer100g: 3.0,
    carbsPer100g: 18.3,
    fatPer100g: 0.7,
    defaultUnit: 'mana',
    defaultQuantity: 1,
    gramsPerUnit: {'mana': 300, 'grams': 1, 'cups': 240},
    availableUnits: ['mana', 'grams', 'cups'],
  ),
  FoodItem(
    id: 'chiura',
    name: 'Chiura',
    kcalPer100g: 110,
    proteinPer100g: 2.2,
    carbsPer100g: 24.0,
    fatPer100g: 0.25,
    defaultUnit: 'mana',
    defaultQuantity: 1,
    gramsPerUnit: {'mana': 200, 'grams': 1, 'cups': 240},
    availableUnits: ['mana', 'grams', 'cups'],
  ),
  FoodItem(
    id: 'roti',
    name: 'Roti',
    kcalPer100g: 310,
    proteinPer100g: 8.0,
    carbsPer100g: 56.0,
    fatPer100g: 8.0,
    defaultUnit: 'roti',
    defaultQuantity: 2,
    gramsPerUnit: {'roti': 50, 'grams': 1},
    availableUnits: ['roti', 'grams'],
  ),
  FoodItem(
    id: 'roti_sabji',
    name: 'Roti + sabji',
    kcalPer100g: 200,
    proteinPer100g: 5.5,
    carbsPer100g: 35.0,
    fatPer100g: 5.0,
    defaultUnit: 'roti',
    defaultQuantity: 2,
    gramsPerUnit: {'roti': 80, 'grams': 1},
    availableUnits: ['roti', 'grams'],
  ),
  FoodItem(
    id: 'sel_roti',
    name: 'Sel roti',
    kcalPer100g: 350,
    proteinPer100g: 5.0,
    carbsPer100g: 55.0,
    fatPer100g: 14.0,
    defaultUnit: 'piece',
    defaultQuantity: 1,
    gramsPerUnit: {'piece': 80, 'grams': 1},
    availableUnits: ['piece', 'grams'],
  ),

  // ── Soups & Sides ─────────────────────────────────────────────────────────
  FoodItem(
    id: 'gundruk_soup',
    name: 'Gundruk soup',
    kcalPer100g: 34,
    proteinPer100g: 1.6,
    carbsPer100g: 4.8,
    fatPer100g: 0.8,
    defaultUnit: 'bowl',
    defaultQuantity: 1,
    gramsPerUnit: {'bowl': 250, 'grams': 1},
    availableUnits: ['bowl', 'grams'],
  ),
  FoodItem(
    id: 'achar',
    name: 'Achar (pickle)',
    kcalPer100g: 60,
    proteinPer100g: 1.0,
    carbsPer100g: 12.0,
    fatPer100g: 1.0,
    defaultUnit: 'tbsp',
    defaultQuantity: 2,
    gramsPerUnit: {'tbsp': 15, 'grams': 1},
    availableUnits: ['tbsp', 'grams'],
  ),
  FoodItem(
    id: 'papad',
    name: 'Papad',
    kcalPer100g: 360,
    proteinPer100g: 22.0,
    carbsPer100g: 58.0,
    fatPer100g: 6.0,
    defaultUnit: 'piece',
    defaultQuantity: 1,
    gramsPerUnit: {'piece': 12, 'grams': 1},
    availableUnits: ['piece', 'grams'],
  ),
  FoodItem(
    id: 'dal_soup',
    name: 'Dal (lentil soup)',
    kcalPer100g: 48,
    proteinPer100g: 2.8,
    carbsPer100g: 8.0,
    fatPer100g: 0.4,
    defaultUnit: 'bowl',
    defaultQuantity: 1,
    gramsPerUnit: {'bowl': 250, 'grams': 1},
    availableUnits: ['bowl', 'grams'],
  ),
  FoodItem(
    id: 'tarkari',
    name: 'Tarkari (sabji)',
    kcalPer100g: 55,
    proteinPer100g: 2.0,
    carbsPer100g: 8.0,
    fatPer100g: 2.0,
    defaultUnit: 'bowl',
    defaultQuantity: 1,
    gramsPerUnit: {'bowl': 200, 'grams': 1},
    availableUnits: ['bowl', 'grams'],
  ),

  // ── Snacks ────────────────────────────────────────────────────────────────
  FoodItem(
    id: 'samosa',
    name: 'Samosa',
    kcalPer100g: 260,
    proteinPer100g: 5.0,
    carbsPer100g: 32.0,
    fatPer100g: 13.0,
    defaultUnit: 'piece',
    defaultQuantity: 2,
    gramsPerUnit: {'piece': 55, 'grams': 1},
    availableUnits: ['piece', 'grams'],
  ),
  FoodItem(
    id: 'momo',
    name: 'Momo (steamed)',
    kcalPer100g: 150,
    proteinPer100g: 8.0,
    carbsPer100g: 18.0,
    fatPer100g: 5.0,
    defaultUnit: 'piece',
    defaultQuantity: 6,
    gramsPerUnit: {'piece': 30, 'grams': 1},
    availableUnits: ['piece', 'grams'],
  ),
  FoodItem(
    id: 'momo_fried',
    name: 'Momo (fried)',
    kcalPer100g: 220,
    proteinPer100g: 7.5,
    carbsPer100g: 20.0,
    fatPer100g: 12.0,
    defaultUnit: 'piece',
    defaultQuantity: 6,
    gramsPerUnit: {'piece': 30, 'grams': 1},
    availableUnits: ['piece', 'grams'],
  ),
  FoodItem(
    id: 'chatpate',
    name: 'Chatpate',
    kcalPer100g: 210,
    proteinPer100g: 4.0,
    carbsPer100g: 30.0,
    fatPer100g: 9.0,
    defaultUnit: 'bowl',
    defaultQuantity: 1,
    gramsPerUnit: {'bowl': 150, 'grams': 1},
    availableUnits: ['bowl', 'grams'],
  ),

  // ── Eggs & Protein ────────────────────────────────────────────────────────
  FoodItem(
    id: 'egg_boiled',
    name: 'Boiled egg',
    kcalPer100g: 155,
    proteinPer100g: 13.0,
    carbsPer100g: 1.1,
    fatPer100g: 11.0,
    defaultUnit: 'egg',
    defaultQuantity: 2,
    gramsPerUnit: {'egg': 50, 'grams': 1},
    availableUnits: ['egg', 'grams'],
  ),
  FoodItem(
    id: 'chicken_curry',
    name: 'Chicken curry',
    kcalPer100g: 165,
    proteinPer100g: 17.0,
    carbsPer100g: 4.0,
    fatPer100g: 9.0,
    defaultUnit: 'bowl',
    defaultQuantity: 1,
    gramsPerUnit: {'bowl': 200, 'grams': 1},
    availableUnits: ['bowl', 'grams'],
  ),

  // ── Drinks ────────────────────────────────────────────────────────────────
  FoodItem(
    id: 'milk_tea',
    name: 'Chiya (milk tea)',
    kcalPer100g: 30,
    proteinPer100g: 1.2,
    carbsPer100g: 4.0,
    fatPer100g: 0.8,
    defaultUnit: 'cup',
    defaultQuantity: 1,
    gramsPerUnit: {'cup': 240, 'ml': 1},
    availableUnits: ['cup', 'ml'],
  ),
  FoodItem(
    id: 'lassi',
    name: 'Lassi',
    kcalPer100g: 70,
    proteinPer100g: 3.5,
    carbsPer100g: 9.0,
    fatPer100g: 2.5,
    defaultUnit: 'glass',
    defaultQuantity: 1,
    gramsPerUnit: {'glass': 300, 'ml': 1},
    availableUnits: ['glass', 'ml'],
  ),

  // ── Fruits ────────────────────────────────────────────────────────────────
  FoodItem(
    id: 'banana',
    name: 'Banana',
    kcalPer100g: 89,
    proteinPer100g: 1.1,
    carbsPer100g: 23.0,
    fatPer100g: 0.3,
    defaultUnit: 'piece',
    defaultQuantity: 1,
    gramsPerUnit: {'piece': 120, 'grams': 1},
    availableUnits: ['piece', 'grams'],
  ),
  FoodItem(
    id: 'rice_plain',
    name: 'Steamed rice',
    kcalPer100g: 130,
    proteinPer100g: 2.7,
    carbsPer100g: 28.0,
    fatPer100g: 0.3,
    defaultUnit: 'mana',
    defaultQuantity: 1,
    gramsPerUnit: {'mana': 200, 'grams': 1, 'cups': 186},
    availableUnits: ['mana', 'grams', 'cups'],
  ),
];

// Quick-access lists for the log screen
final kRecentFoodIds = ['dal_bhat', 'roti_sabji'];
final kPopularFoodIds = ['chiura', 'gundruk_soup', 'momo', 'sel_roti'];

FoodItem? findFoodById(String id) {
  try {
    return kNepaliFoods.firstWhere((f) => f.id == id);
  } catch (_) {
    return null;
  }
}

List<FoodItem> searchFoods(String query) {
  if (query.isEmpty) return kNepaliFoods;
  final q = query.toLowerCase();
  return kNepaliFoods.where((f) => f.name.toLowerCase().contains(q)).toList();
}
