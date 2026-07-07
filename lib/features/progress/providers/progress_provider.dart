import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/local_db/meal_log_database.dart';
import '../../log/providers/today_log_provider.dart';

// ── ConsistencyScore ───────────────────────────────────────────────────────────

class ConsistencyScore {
  const ConsistencyScore({
    required this.daysLogged,
    required this.totalDays,
  });

  final int daysLogged;
  final int totalDays;

  double get loggedPercent =>
      totalDays > 0 ? daysLogged / totalDays : 0.0;
}

/// How many of the last 14 calendar days had at least one logged entry.
final consistencyScoreProvider = FutureProvider<ConsistencyScore>((ref) async {
  final entries =
      await MealLogDatabaseService.instance.getEntriesForLastNDays(14);

  final daysWithEntries = <DateTime>{};
  for (final e in entries) {
    daysWithEntries.add(
      DateTime(e.loggedAt.year, e.loggedAt.month, e.loggedAt.day),
    );
  }

  return ConsistencyScore(
    daysLogged: daysWithEntries.length,
    totalDays: 14,
  );
});

// ── DayStatus ──────────────────────────────────────────────────────────────────

class DayStatus {
  const DayStatus({
    required this.date,
    required this.dayLabel,
    required this.status,
  });

  final DateTime date;
  final String dayLabel; // single letter: 'M','T','W','T','F','S','S'
  final String status;   // 'good' | 'partial' | 'none'
}

/// Per-day kcal status for the last 7 calendar days (oldest → newest).
final weekGridProvider = FutureProvider<List<DayStatus>>((ref) async {
  // Watch targets first (before any await) for correct reactivity
  final targetsFuture = ref.watch(userTargetsProvider.future);

  final entries =
      await MealLogDatabaseService.instance.getEntriesForLastNDays(7);
  final targets = await targetsFuture;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Map each calendar day → total kcal
  final kcalByDay = <DateTime, double>{};
  for (final e in entries) {
    final day =
        DateTime(e.loggedAt.year, e.loggedAt.month, e.loggedAt.day);
    kcalByDay[day] = (kcalByDay[day] ?? 0.0) + e.kcal;
  }

  // weekday: 1=Mon … 7=Sun  →  single letter at index [weekday - 1]
  const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  final result = <DayStatus>[];
  for (int i = 6; i >= 0; i--) {
    final day = today.subtract(Duration(days: i));
    final totalKcal = kcalByDay[day] ?? 0.0;
    final hasEntries = kcalByDay.containsKey(day);

    final String status;
    if (!hasEntries) {
      status = 'none';
    } else if (targets.kcal <= 0) {
      status = 'partial';
    } else {
      final ratio = totalKcal / targets.kcal;
      status = (ratio >= 0.85 && ratio <= 1.15) ? 'good' : 'partial';
    }

    result.add(DayStatus(
      date: day,
      dayLabel: letters[day.weekday - 1],
      status: status,
    ));
  }

  return result;
});

// ── Weekly nutrient averages ───────────────────────────────────────────────────

/// Average daily intake as a fraction of target for each tracked nutrient.
///
/// Keys returned: 'protein', 'iron'.
/// calcium and vitB12 require expanding the FoodItem + FoodLogEntry nutrient
/// model before they can be shown here — that is a separate task.
final weeklyNutrientAveragesProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final targetsFuture = ref.watch(userTargetsProvider.future);

  final entries =
      await MealLogDatabaseService.instance.getEntriesForLastNDays(7);
  final targets = await targetsFuture;

  var totalProtein = 0.0;
  var totalIron = 0.0;

  for (final e in entries) {
    totalProtein += e.proteinG;
    totalIron += e.ironMg;
  }

  const ironDailyTargetMg = 18.0; // standard daily recommended iron intake

  final proteinRatio = targets.proteinG > 0
      ? (totalProtein / 7) / targets.proteinG
      : 0.0;
  final ironRatio = (totalIron / 7) / ironDailyTargetMg;

  return {
    'protein': proteinRatio.clamp(0.0, 2.0),
    'iron': ironRatio.clamp(0.0, 2.0),
  };
});
