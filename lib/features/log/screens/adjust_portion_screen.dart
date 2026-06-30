import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../models/detected_food.dart';
import '../models/food_item.dart';
import '../models/food_log_entry.dart';

class AdjustPortionScreen extends StatefulWidget {
  const AdjustPortionScreen({super.key, required this.foods});
  final List<DetectedFood> foods;

  @override
  State<AdjustPortionScreen> createState() => _AdjustPortionScreenState();
}

class _AdjustPortionScreenState extends State<AdjustPortionScreen> {
  late String _unit;
  late double _quantity;
  late List<String> _availableUnits;

  FoodItem get _primary => widget.foods.first.foodItem;

  @override
  void initState() {
    super.initState();
    _unit = _primary.defaultUnit;
    _quantity = widget.foods.first.defaultQuantity;
    _availableUnits = _primary.availableUnits;
  }

  double get _totalKcal => widget.foods.fold(
        0.0,
        (s, f) => s + f.foodItem.kcalFor(_quantity, _unit),
      );

  double get _totalProtein => widget.foods.fold(
        0.0,
        (s, f) => s + f.foodItem.proteinFor(_quantity, _unit),
      );

  double get _totalCarbs => widget.foods.fold(
        0.0,
        (s, f) => s + f.foodItem.carbsFor(_quantity, _unit),
      );

  double get _totalFat => widget.foods.fold(
        0.0,
        (s, f) => s + f.foodItem.fatFor(_quantity, _unit),
      );

  String get _foodLabel {
    if (widget.foods.length == 1) return _primary.name;
    final others = widget.foods.skip(1).map((f) => f.foodItem.name).join(' + ');
    return '${_primary.name} + $others';
  }

  String _fmtQty(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  void _confirm() {
    final now = DateTime.now();
    final entry = FoodLogEntry(
      id: now.millisecondsSinceEpoch.toString(),
      foodName: _foodLabel,
      quantity: _quantity,
      unit: _unit,
      kcal: _totalKcal,
      proteinG: _totalProtein,
      carbsG: _totalCarbs,
      fatG: _totalFat,
      loggedAt: now,
      mealType: FoodLogEntry.mealTypeForTime(now),
    );
    context.push('/log/success', extra: entry);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AaharTheme.darkBg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Adjust portion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Portion picker card ───────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AaharTheme.darkSurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _foodLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Unit selector
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _availableUnits.map((u) {
                                  final selected = u == _unit;
                                  return GestureDetector(
                                    onTap: () => setState(() {
                                      _unit = u;
                                      // Reset to sensible default qty for new unit
                                      if (u == 'grams') {
                                        _quantity = (_primary.gramsPerUnit[_primary.defaultUnit] ?? 100) *
                                            widget.foods.first.defaultQuantity;
                                      } else if (u == 'ml') {
                                        _quantity = 240;
                                      } else {
                                        _quantity = widget.foods.first.defaultQuantity;
                                      }
                                    }),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 160),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AaharTheme.brandLime
                                            : const Color(0xFF252525),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _capitalize(u),
                                        style: TextStyle(
                                          color: selected
                                              ? AaharTheme.darkBg
                                              : const Color(0xFF888888),
                                          fontSize: 14,
                                          fontWeight: selected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Quantity stepper
                            Row(
                              children: [
                                _StepButton(
                                  icon: Icons.remove,
                                  onTap: () => setState(() {
                                    final step = _stepFor(_unit);
                                    if (_quantity - step >= step) {
                                      _quantity -= step;
                                    }
                                  }),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '${_fmtQty(_quantity)} $_unit',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                _StepButton(
                                  icon: Icons.add,
                                  onTap: () => setState(() {
                                    _quantity += _stepFor(_unit);
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Nutrition preview card ────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AaharTheme.darkSurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'NUTRITION',
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  '${_totalKcal.round()} kcal',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _NutrientBar(
                              label: 'Protein',
                              grams: _totalProtein,
                              color: AaharTheme.nutrientProtein,
                            ),
                            const SizedBox(height: 10),
                            _NutrientBar(
                              label: 'Carbs',
                              grams: _totalCarbs,
                              color: AaharTheme.nutrientCarbs,
                            ),
                            const SizedBox(height: 10),
                            _NutrientBar(
                              label: 'Fat',
                              grams: _totalFat,
                              color: AaharTheme.nutrientFat,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Confirm log button ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AaharTheme.brandLime,
                      foregroundColor: AaharTheme.darkBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Confirm log',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _stepFor(String unit) {
    return switch (unit) {
      'grams' || 'ml' => 25,
      _ => 1,
    };
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ── Step button ───────────────────────────────────────────────────────────────

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Nutrient bar ──────────────────────────────────────────────────────────────

class _NutrientBar extends StatelessWidget {
  const _NutrientBar({
    required this.label,
    required this.grams,
    required this.color,
  });

  final String label;
  final double grams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = (grams / 100).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 36,
          child: Text(
            '${grams.round()}g',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
