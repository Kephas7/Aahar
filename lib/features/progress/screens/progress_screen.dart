import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/aahar_theme.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistencyAsync = ref.watch(consistencyScoreProvider);
    final weekGridAsync = ref.watch(weekGridProvider);
    final nutrientsAsync = ref.watch(weeklyNutrientAveragesProvider);

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
                // ── Title ────────────────────────────────────────────────────
                const Text(
                  'Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Consistency hero card ─────────────────────────────────────
                consistencyAsync.when(
                  loading: () => const _SkeletonBox(height: 120),
                  error: (_, _) => const _SkeletonBox(height: 120),
                  data: (score) => _ConsistencyCard(score: score),
                ),
                const SizedBox(height: 16),

                // ── Week grid card ────────────────────────────────────────────
                weekGridAsync.when(
                  loading: () => const _SkeletonBox(height: 104),
                  error: (_, _) => const _SkeletonBox(height: 104),
                  data: (days) => _WeekGridCard(days: days),
                ),
                const SizedBox(height: 16),

                // ── Nutrient averages + warning ───────────────────────────────
                nutrientsAsync.when(
                  loading: () => const _SkeletonBox(height: 120),
                  error: (_, _) => const _SkeletonBox(height: 120),
                  data: (nutrients) {
                    final lowKeys = nutrients.entries
                        .where((e) => e.value < 0.5)
                        .map((e) => e.key)
                        .toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NutrientAveragesCard(nutrients: nutrients),
                        if (lowKeys.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _LowNutrientWarning(nutrientKeys: lowKeys),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Consistency card ──────────────────────────────────────────────────────────

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard({required this.score});
  final ConsistencyScore score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF152A1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${score.daysLogged} of ${score.totalDays} days',
            style: const TextStyle(
              color: AaharTheme.brandLime,
              fontSize: 42,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'consistency this fortnight',
            style: TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Week grid card ────────────────────────────────────────────────────────────

class _WeekGridCard extends StatelessWidget {
  const _WeekGridCard({required this.days});
  final List<DayStatus> days;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AaharTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('THIS WEEK'),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < days.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _DayTile(
                    day: days[i],
                    isToday: days[i].date == today,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, required this.isToday});
  final DayStatus day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final bg = switch (day.status) {
      'good' => const Color(0xFF173D2C),
      'partial' => const Color(0xFF1C2B20),
      _ => const Color(0xFF222222),
    };
    final textColor = switch (day.status) {
      'good' => const Color(0xFF3DD68C),
      'partial' => const Color(0xFF3A5A47),
      _ => const Color(0xFF444444),
    };

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AaharTheme.brandLime, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            day.dayLabel,
            style: TextStyle(
              color: isToday ? AaharTheme.brandLime : textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nutrient averages card ────────────────────────────────────────────────────

class _NutrientAveragesCard extends StatelessWidget {
  const _NutrientAveragesCard({required this.nutrients});
  final Map<String, double> nutrients;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AaharTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('7-DAY NUTRIENT AVERAGE'),
          const SizedBox(height: 14),
          if (nutrients.containsKey('protein')) ...[
            _NutrientProgressRow(
              label: 'Protein',
              fraction: nutrients['protein']!,
              color: AaharTheme.nutrientProtein,
            ),
          ],
          if (nutrients.containsKey('iron')) ...[
            const SizedBox(height: 10),
            _NutrientProgressRow(
              label: 'Iron',
              fraction: nutrients['iron']!,
              color: AaharTheme.nutrientIron,
            ),
          ],
        ],
      ),
    );
  }
}

class _NutrientProgressRow extends StatelessWidget {
  const _NutrientProgressRow({
    required this.label,
    required this.fraction,
    required this.color,
  });

  final String label;
  final double fraction; // 0.0 = 0% of daily target, 1.0 = 100%
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (fraction * 100).round().clamp(0, 999);
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
              value: fraction.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '$pct%',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ── Low nutrient warning ──────────────────────────────────────────────────────

class _LowNutrientWarning extends StatelessWidget {
  const _LowNutrientWarning({required this.nutrientKeys});
  final List<String> nutrientKeys;

  static const _labels = {
    'protein': 'Protein',
    'iron': 'Iron',
  };

  @override
  Widget build(BuildContext context) {
    final names =
        nutrientKeys.map((k) => _labels[k] ?? k).toList();

    final String message;
    if (names.length == 1) {
      message = '${names[0]} is consistently low';
    } else {
      final joined = names.sublist(0, names.length - 1).join(', ');
      message = '$joined and ${names.last} are consistently low';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB700).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFFB700),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFFD60A),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

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

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AaharTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
