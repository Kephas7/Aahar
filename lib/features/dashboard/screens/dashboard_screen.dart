import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../../log/data/nepali_foods.dart';
import '../../log/models/food_item.dart';
import '../../log/models/food_log_entry.dart';
import '../../log/providers/today_log_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetsAsync = ref.watch(userTargetsProvider);
    final log = ref.watch(todayLogProvider);
    final consumed = ref.watch(todayKcalProvider);
    final consumedProtein = ref.watch(todayProteinProvider);
    final consumedCarbs = ref.watch(todayCarbsProvider);
    final consumedFat = ref.watch(todayFatProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AaharTheme.darkBg,
        body: targetsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AaharTheme.brandLime),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (targets) {
            final remaining =
                (targets.kcal - consumed).clamp(0, targets.kcal.toDouble());

            return Stack(
              children: [
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Header ──────────────────────────────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _greeting(),
                                        style: const TextStyle(
                                          color: Color(0xFF888888),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            targets.userName.isNotEmpty
                                                ? targets.userName
                                                : 'there',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text('👋',
                                              style: TextStyle(fontSize: 22)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  _AvatarCircle(
                                    name: targets.userName,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // ── Calorie card ─────────────────────────────
                              _CalorieCard(
                                remaining: remaining.round(),
                                consumed: consumed.round(),
                                goal: targets.kcal,
                              ),
                              const SizedBox(height: 12),

                              // ── Macros card ──────────────────────────────
                              _MacrosCard(
                                proteinConsumed: consumedProtein,
                                carbsConsumed: consumedCarbs,
                                fatConsumed: consumedFat,
                                proteinGoal: targets.proteinG.toDouble(),
                                carbsGoal: targets.carbsG.toDouble(),
                                fatGoal: targets.fatG.toDouble(),
                              ),
                              const SizedBox(height: 20),

                              // ── Today's log ───────────────────────────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "TODAY'S LOG",
                                    style: TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push('/log'),
                                    child: const Text(
                                      'tap to edit',
                                      style: TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              if (log.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AaharTheme.darkSurface,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text(
                                    'Nothing logged yet — tap Log a meal to start.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              else
                                ...log.map((e) => _LogEntryTile(entry: e)),

                              const SizedBox(height: 12),

                              // ── Insight chip ──────────────────────────────
                              if (consumed > 0)
                                _InsightChip(
                                  proteinConsumed: consumedProtein,
                                  proteinGoal: targets.proteinG.toDouble(),
                                ),

                              // Bottom padding so Log a meal button doesn't cover content
                              const SizedBox(height: 88),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Log a meal — sticky above bottom nav ──────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AaharTheme.darkBg],
                        stops: [0.0, 0.4],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/log'),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'Log a meal',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AaharTheme.brandLime,
                          foregroundColor: AaharTheme.darkBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Good morning,';
    if (h >= 12 && h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// ── Calorie card ─────────────────────────────────────────────────────────────

class _CalorieCard extends StatelessWidget {
  const _CalorieCard({
    required this.remaining,
    required this.consumed,
    required this.goal,
  });

  final int remaining;
  final int consumed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF152A1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _formatNumber(remaining),
            style: const TextStyle(
              color: AaharTheme.brandLime,
              fontSize: 52,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'kcal remaining',
            style: TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_formatNumber(consumed)} eaten',
                style: const TextStyle(
                  color: AaharTheme.nutrientProtein,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('·',
                    style:
                        TextStyle(color: Color(0xFF444444), fontSize: 13)),
              ),
              Text(
                '${_formatNumber(goal)} goal',
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
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

// ── Macros card ──────────────────────────────────────────────────────────────

class _MacrosCard extends StatelessWidget {
  const _MacrosCard({
    required this.proteinConsumed,
    required this.carbsConsumed,
    required this.fatConsumed,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  final double proteinConsumed;
  final double carbsConsumed;
  final double fatConsumed;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: AaharTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MACROS TODAY',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroRing(
                consumed: proteinConsumed,
                goal: proteinGoal,
                color: AaharTheme.nutrientProtein,
                label: 'Protein',
              ),
              _MacroRing(
                consumed: carbsConsumed,
                goal: carbsGoal,
                color: AaharTheme.nutrientCarbs,
                label: 'Carbs',
              ),
              _MacroRing(
                consumed: fatConsumed,
                goal: fatGoal,
                color: AaharTheme.nutrientFat,
                label: 'Fat',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroRing extends StatelessWidget {
  const _MacroRing({
    required this.consumed,
    required this.goal,
    required this.color,
    required this.label,
  });

  final double consumed;
  final double goal;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? min(consumed / goal, 1.0) : 0.0;
    final consumedRounded = consumed.round();
    final goalRounded = goal.round();

    return Column(
      children: [
        SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF2A2A2A),
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${consumedRounded}g',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '/$goalRounded',
                    style: const TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
        ),
      ],
    );
  }
}

// ── Log entry tile ────────────────────────────────────────────────────────────

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});
  final FoodLogEntry entry;

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EditEntrySheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AaharTheme.darkSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.mealType} · ${entry.foodName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${entry.kcal.round()} kcal · ${entry.portionLabel} · ${entry.timeLabel}',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Color(0xFF555555), size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Insight chip ─────────────────────────────────────────────────────────────

class _InsightChip extends StatelessWidget {
  const _InsightChip({
    required this.proteinConsumed,
    required this.proteinGoal,
  });

  final double proteinConsumed;
  final double proteinGoal;

  @override
  Widget build(BuildContext context) {
    final remaining = (proteinGoal - proteinConsumed).clamp(0, proteinGoal);
    if (remaining <= 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/home/plan'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2A35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1A4A5E)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline,
                color: Color(0xFF4ECDB4), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${remaining.round()}g protein to go — see your plan',
                style: const TextStyle(
                  color: Color(0xFF4ECDB4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFF4ECDB4), size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Edit entry bottom sheet ───────────────────────────────────────────────────

class _EditEntrySheet extends ConsumerStatefulWidget {
  const _EditEntrySheet({required this.entry});
  final FoodLogEntry entry;

  @override
  ConsumerState<_EditEntrySheet> createState() => _EditEntrySheetState();
}

class _EditEntrySheetState extends ConsumerState<_EditEntrySheet> {
  late double _quantity;
  late String _unit;
  FoodItem? _food;
  late List<String> _units;

  @override
  void initState() {
    super.initState();
    _quantity = widget.entry.quantity;
    _unit = widget.entry.unit;
    // Try exact name match — compound meals (e.g. "Dal bhat + Achar") won't match.
    try {
      _food = kNepaliFoods.firstWhere((f) => f.name == widget.entry.foodName);
      _units = _food!.availableUnits;
    } catch (_) {
      _food = null;
      _units = [_unit];
    }
  }

  // Step size: coarser for named portions, finer for raw grams/ml.
  double get _step => (_unit == 'grams' || _unit == 'ml') ? 25 : 1;

  // Nutrition at current quantity/unit.
  // If no FoodItem found (compound meal) scale the original values proportionally.
  double _scale(double original) {
    if (widget.entry.quantity <= 0) return original;
    return original * (_quantity / widget.entry.quantity);
  }

  double get _kcal =>
      _food != null ? _food!.kcalFor(_quantity, _unit) : _scale(widget.entry.kcal);
  double get _protein =>
      _food != null ? _food!.proteinFor(_quantity, _unit) : _scale(widget.entry.proteinG);
  double get _carbs =>
      _food != null ? _food!.carbsFor(_quantity, _unit) : _scale(widget.entry.carbsG);
  double get _fat =>
      _food != null ? _food!.fatFor(_quantity, _unit) : _scale(widget.entry.fatG);

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  void _save() {
    final updated = FoodLogEntry(
      id: widget.entry.id,
      foodName: widget.entry.foodName,
      quantity: _quantity,
      unit: _unit,
      kcal: _kcal,
      proteinG: _protein,
      carbsG: _carbs,
      fatG: _fat,
      loggedAt: widget.entry.loggedAt,
      mealType: widget.entry.mealType,
    );
    ref.read(todayLogProvider.notifier).update(updated);
    Navigator.of(context).pop();
  }

  void _delete() {
    ref.read(todayLogProvider.notifier).remove(widget.entry.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Keep sheet above keyboard if it appears.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ─────────────────────────────────────────────────
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Food name + meal context ─────────────────────────────────────
            Text(
              widget.entry.foodName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.entry.mealType} · ${widget.entry.timeLabel}',
              style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),
            const SizedBox(height: 20),

            // ── Unit chips (hidden when only one unit) ───────────────────────
            if (_units.length > 1) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final u in _units)
                      GestureDetector(
                        onTap: () => setState(() => _unit = u),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: u == _unit
                                ? AaharTheme.brandLime
                                : const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            u,
                            style: TextStyle(
                              color: u == _unit
                                  ? AaharTheme.darkBg
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Quantity stepper ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepBtn(
                  icon: Icons.remove,
                  onTap: () {
                    final next = _quantity - _step;
                    if (next >= _step) setState(() => _quantity = next);
                  },
                ),
                const SizedBox(width: 24),
                Text(
                  '${_fmt(_quantity)} $_unit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 24),
                _StepBtn(
                  icon: Icons.add,
                  onTap: () => setState(() => _quantity += _step),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Live nutrition row ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutriBadge(
                      label: 'kcal', value: _kcal.round().toString()),
                  _NutriBadge(
                      label: 'Protein',
                      value: '${_protein.round()}g',
                      color: AaharTheme.nutrientProtein),
                  _NutriBadge(
                      label: 'Carbs',
                      value: '${_carbs.round()}g',
                      color: AaharTheme.nutrientCarbs),
                  _NutriBadge(
                      label: 'Fat',
                      value: '${_fat.round()}g',
                      color: AaharTheme.nutrientFat),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Actions ──────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline, size: 17),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5555),
                        backgroundColor: const Color(0xFF2A0F0F),
                        side: const BorderSide(color: Color(0xFF4A1A1A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AaharTheme.brandLime,
                        foregroundColor: AaharTheme.darkBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save changes',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _NutriBadge extends StatelessWidget {
  const _NutriBadge({
    required this.label,
    required this.value,
    this.color = Colors.white,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF666666), fontSize: 11)),
      ],
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join();

    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xFFE8A040),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}
