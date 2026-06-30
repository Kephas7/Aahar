import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../models/food_log_entry.dart';
import '../providers/today_log_provider.dart';

class MealLoggedScreen extends ConsumerStatefulWidget {
  const MealLoggedScreen({super.key, required this.entry});
  final FoodLogEntry entry;

  @override
  ConsumerState<MealLoggedScreen> createState() => _MealLoggedScreenState();
}

class _MealLoggedScreenState extends ConsumerState<MealLoggedScreen> {
  @override
  void initState() {
    super.initState();
    // Add entry once on first frame so providers reflect the new totals
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todayLogProvider.notifier).add(widget.entry);
    });
  }

  FoodLogEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final targetsAsync = ref.watch(userTargetsProvider);
    final totalKcal = ref.watch(todayKcalProvider);
    final totalProtein = ref.watch(todayProteinProvider);
    final totalCarbs = ref.watch(todayCarbsProvider);
    final totalFat = ref.watch(todayFatProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AaharTheme.darkBg,
        body: SafeArea(
          child: targetsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AaharTheme.brandLime),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (targets) {
              final remaining =
                  (targets.kcal - totalKcal).clamp(0, targets.kcal.toDouble());

              return Column(
                children: [
                  const Spacer(),
                  // ── Success indicator ──────────────────────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AaharTheme.nutrientProtein,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Meal logged!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${entry.foodName} · ${entry.portionLabel} · ${entry.kcal.round()} kcal',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Remaining calories card ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 22, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF152A1E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _formatNumber(remaining.round()),
                            style: const TextStyle(
                              color: AaharTheme.brandLime,
                              fontSize: 44,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'kcal remaining today',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Updated macros card ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AaharTheme.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'UPDATED MACROS',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _MacroBar(
                            label: 'Protein',
                            consumed: totalProtein,
                            goal: targets.proteinG.toDouble(),
                            color: AaharTheme.nutrientProtein,
                          ),
                          const SizedBox(height: 10),
                          _MacroBar(
                            label: 'Carbs',
                            consumed: totalCarbs,
                            goal: targets.carbsG.toDouble(),
                            color: AaharTheme.nutrientCarbs,
                          ),
                          const SizedBox(height: 10),
                          _MacroBar(
                            label: 'Fat',
                            consumed: totalFat,
                            goal: targets.fatG.toDouble(),
                            color: AaharTheme.nutrientFat,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Actions ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ref
                                    .read(todayLogProvider.notifier)
                                    .undoLast();
                                context.go('/home/dashboard');
                              },
                              icon: const Icon(Icons.undo, size: 16),
                              label: const Text('Undo'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Color(0xFF2A2A2A)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 5,
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () =>
                                  context.go('/home/dashboard'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AaharTheme.brandLime,
                                foregroundColor: AaharTheme.darkBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Back to home',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}';
    }
    return '$n';
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
  });

  final String label;
  final double consumed;
  final double goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = goal > 0 ? min(consumed / goal, 1.0) : 0.0;
    final pctLabel = '${(pct * 100).round()}%';

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
              value: pct,
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
            pctLabel,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
