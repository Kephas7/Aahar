import '../../log/data/nepali_foods.dart';
import '../../log/models/food_item.dart';

class SuggestedMeal {
  const SuggestedMeal({
    required this.food,
    required this.primaryGapFilled,
    required this.amountFilled,
    required this.tags,
  });

  final FoodItem food;
  final String primaryGapFilled; // 'protein' (or 'iron' once FoodItem has ironPer100g)
  final double amountFilled;     // grams of the filled nutrient in default serving
  final List<String> tags;
}

// NOTE: Iron-based suggestions are not yet implemented because FoodItem has no
// ironPer100g field. All suggestions currently target protein gaps. Add
// ironPer100g to FoodItem to unlock iron-targeted suggestions.
//
// NOTE: Cost-based filtering ("Budget-friendly" tag, NPR display) is omitted
// because FoodItem has no cost field. Add nprCost to FoodItem as a separate
// task before budget-based suggestions can work.
List<SuggestedMeal> suggestMeals(Map<String, double> gaps, int? budgetNPR) {
  // Sort by protein per default serving, descending
  final sorted = [...kNepaliFoods]
    ..sort((a, b) {
      final ap = a.proteinFor(a.defaultQuantity, a.defaultUnit);
      final bp = b.proteinFor(b.defaultQuantity, b.defaultUnit);
      return bp.compareTo(ap);
    });

  return sorted.take(6).map((food) {
    final proteinInServing = food.proteinFor(food.defaultQuantity, food.defaultUnit);
    final tags = <String>[];
    if (food.proteinPer100g >= 10.0) tags.add('High protein');
    return SuggestedMeal(
      food: food,
      primaryGapFilled: 'protein',
      amountFilled: proteinInServing,
      tags: tags,
    );
  }).toList();
}
