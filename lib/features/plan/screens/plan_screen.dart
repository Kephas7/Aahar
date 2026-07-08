import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../../log/models/detected_food.dart';
import '../providers/plan_provider.dart';
import '../services/meal_suggester.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  // Tracks which suggestion indices have been swapped away
  final _swappedIndices = <int>{};

  // Returns the key ('protein' | 'carbs' | 'fat') with the largest
  // proportional gap (gap / target).
  String _largestGapKey(
      Map<String, double> gaps, Map<String, double> targets) {
    final protein =
        (gaps['protein'] ?? 0.0) / (targets['proteinG'] ?? 50.0);
    final carbs = (gaps['carbs'] ?? 0.0) / (targets['carbsG'] ?? 250.0);
    final fat = (gaps['fat'] ?? 0.0) / (targets['fatG'] ?? 65.0);
    if (protein >= carbs && protein >= fat) return 'protein';
    if (carbs >= protein && carbs >= fat) return 'carbs';
    return 'fat';
  }

  void _logMeal(SuggestedMeal meal) {
    context.push('/log/portion', extra: [
      DetectedFood(
        foodItem: meal.food,
        confidencePercent: 100,
        defaultQuantity: meal.food.defaultQuantity,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final activePlan = ref.watch(activePlanTypeProvider);
    final targets = ref.watch(activePlanTargetsProvider);
    final gaps = ref.watch(todaysGapsProvider);
    final suggestions = ref.watch(suggestedMealsProvider);

    // First 3 non-swapped suggestions
    final visible = <MapEntry<int, SuggestedMeal>>[];
    for (var i = 0; i < suggestions.length && visible.length < 3; i++) {
      if (!_swappedIndices.contains(i)) {
        visible.add(MapEntry(i, suggestions[i]));
      }
    }

    final largestGapKey = _largestGapKey(gaps, targets);
    final gapLabel = switch (largestGapKey) {
      'carbs' => 'carbs',
      'fat' => 'fat',
      _ => 'protein',
    };
    final gapGrams = (gaps[largestGapKey] ?? 0.0).round();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AaharTheme.darkBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────────
                Row(
                  children: [
                    const Text(
                      'My plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () =>
                          context.push('/home/plan/select'),
                      icon: const Icon(Icons.tune_rounded,
                          color: Colors.white70),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Active plan card ─────────────────────────────────────────
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
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: activePlan.iconBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(activePlan.icon,
                                color: activePlan.iconColor, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            activePlan.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                context.push('/home/plan/select'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                  color: AaharTheme.brandLime,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _MacroCell(
                            value: _fmtKcal(targets['kcal'] ?? 2000),
                            label: 'kcal/day',
                            color: Colors.white,
                          ),
                          _MacroCell(
                            value:
                                '${(targets['proteinG'] ?? 50).round()}g',
                            label: 'protein',
                            color: AaharTheme.nutrientProtein,
                          ),
                          _MacroCell(
                            value:
                                '${(targets['carbsG'] ?? 250).round()}g',
                            label: 'carbs',
                            color: AaharTheme.nutrientCarbs,
                          ),
                          _MacroCell(
                            value:
                                '${(targets['fatG'] ?? 65).round()}g',
                            label: 'fat',
                            color: AaharTheme.nutrientFat,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Today's gaps ─────────────────────────────────────────────
                const _SectionLabel('TODAY\'S GAPS'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AaharTheme.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _GapProgressRow(
                        label: 'Protein',
                        gap: gaps['protein'] ?? 0,
                        target: targets['proteinG'] ?? 50,
                        color: AaharTheme.nutrientProtein,
                      ),
                      const SizedBox(height: 12),
                      _GapProgressRow(
                        label: 'Carbs',
                        gap: gaps['carbs'] ?? 0,
                        target: targets['carbsG'] ?? 250,
                        color: AaharTheme.nutrientCarbs,
                      ),
                      const SizedBox(height: 12),
                      _GapProgressRow(
                        label: 'Fat',
                        gap: gaps['fat'] ?? 0,
                        target: targets['fatG'] ?? 65,
                        color: AaharTheme.nutrientFat,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Dynamic info card ────────────────────────────────────────
                if (gapGrams > 0)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2233),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF378ADD)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFF378ADD), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${gapGrams}g $gapLabel to go',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Here are high-$gapLabel Nepali meals that fit your remaining calories.',
                                style: const TextStyle(
                                    color: Color(0xFF7AAFCC),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // ── Suggested meals ──────────────────────────────────────────
                Row(
                  children: [
                    const _SectionLabel('SUGGESTED MEALS'),
                    const Spacer(),
                    TextButton(
                      // TODO: navigate to a full meal list screen once built
                      onPressed: null,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('See all',
                          style: TextStyle(
                              color: Color(0xFF555555), fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text('No suggestions available.',
                          style: TextStyle(
                              color: Color(0xFF555555), fontSize: 13)),
                    ),
                  )
                else
                  for (final entry in visible) ...[
                    _SuggestedMealCard(
                      meal: entry.value,
                      onLog: () => _logMeal(entry.value),
                      onSwap: () =>
                          setState(() => _swappedIndices.add(entry.key)),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtKcal(double kcal) {
  final n = kcal.round();
  if (n >= 1000) {
    return '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}';
  }
  return n.toString();
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Macro cell (plan card target row) ────────────────────────────────────────

class _MacroCell extends StatelessWidget {
  const _MacroCell({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFF666666), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Gap progress row ──────────────────────────────────────────────────────────

class _GapProgressRow extends StatelessWidget {
  const _GapProgressRow({
    required this.label,
    required this.gap,
    required this.target,
    required this.color,
  });

  final String label;
  final double gap;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final consumed = (target - gap).clamp(0.0, target);
    final fraction =
        target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(
                color: Color(0xFF888888), fontSize: 13),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 56,
          child: Text(
            '${gap.round()}g left',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ── Suggested meal card ───────────────────────────────────────────────────────

class _SuggestedMealCard extends StatelessWidget {
  const _SuggestedMealCard({
    required this.meal,
    required this.onLog,
    required this.onSwap,
  });

  final SuggestedMeal meal;
  final VoidCallback onLog;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final kcalInServing =
        meal.food.kcalFor(meal.food.defaultQuantity, meal.food.defaultUnit);
    final metaText =
        '+${meal.amountFilled.round()}g ${meal.primaryGapFilled} · ${kcalInServing.round()} kcal';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AaharTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3C38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant_outlined,
                    color: Color(0xFF1D9E75), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.food.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metaText,
                      style: const TextStyle(
                          color: Color(0xFF666666), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (meal.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (final tag in meal.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2800),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                          color: AaharTheme.brandLime, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AaharTheme.brandLime,
                    foregroundColor: AaharTheme.darkBg,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Log this',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onSwap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF444444)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Swap',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
