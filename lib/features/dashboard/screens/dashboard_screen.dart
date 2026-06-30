import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
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

class _LogEntryTile extends ConsumerWidget {
  const _LogEntryTile({required this.entry});
  final FoodLogEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
          GestureDetector(
            onTap: () {
              ref.read(todayLogProvider.notifier).remove(entry.id);
            },
            child: const Icon(Icons.edit_outlined,
                color: Color(0xFF555555), size: 18),
          ),
        ],
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
