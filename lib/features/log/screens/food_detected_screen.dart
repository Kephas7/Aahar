import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../models/detected_food.dart';

class FoodDetectedScreen extends StatefulWidget {
  const FoodDetectedScreen({super.key, required this.detectedFoods});
  final List<DetectedFood> detectedFoods;

  @override
  State<FoodDetectedScreen> createState() => _FoodDetectedScreenState();
}

class _FoodDetectedScreenState extends State<FoodDetectedScreen> {
  late final List<DetectedFood> _foods;

  @override
  void initState() {
    super.initState();
    _foods = widget.detectedFoods;
  }

  List<DetectedFood> get _selected =>
      _foods.where((f) => f.isSelected).toList();

  void _confirm() {
    if (_selected.isEmpty) return;
    context.push('/log/portion', extra: _selected);
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
                      'Food detected',
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
                      // ── Photo preview ─────────────────────────────────────
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.rice_bowl_outlined,
                                color: Color(0xFF444444), size: 48),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'your photo',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'We found ${_foods.length} ${_foods.length == 1 ? 'item' : 'items'} — confirm or correct them',
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Detected items ────────────────────────────────────
                      ..._foods.asMap().entries.map((entry) {
                        final i = entry.key;
                        final food = entry.value;
                        return _DetectedFoodTile(
                          food: food,
                          onToggle: (selected) {
                            setState(() => _foods[i].isSelected = selected);
                          },
                        );
                      }),

                      const SizedBox(height: 8),

                      // ── Add missing ───────────────────────────────────────
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add,
                                  color: Color(0xFF666666), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Add missing item',
                                style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Confirm button ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _selected.isEmpty ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AaharTheme.brandLime,
                      disabledBackgroundColor: const Color(0xFF2A2A2A),
                      foregroundColor: AaharTheme.darkBg,
                      disabledForegroundColor: const Color(0xFF555555),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Confirm selection',
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
}

// ── Detected food tile ────────────────────────────────────────────────────────

class _DetectedFoodTile extends StatelessWidget {
  const _DetectedFoodTile({required this.food, required this.onToggle});
  final DetectedFood food;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final selected = food.isSelected;
    final kcal = food.kcal.round();

    return GestureDetector(
      onTap: () => onToggle(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF152A1E) : AaharTheme.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AaharTheme.nutrientProtein
                : const Color(0xFF2A2A2A),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.foodItem.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${food.confidencePercent}% confident · $kcal kcal',
                    style: const TextStyle(
                        color: Color(0xFF666666), fontSize: 13),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AaharTheme.nutrientProtein
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AaharTheme.nutrientProtein
                      : const Color(0xFF444444),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
