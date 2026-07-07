import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/local_db/meal_log_database.dart';
import '../models/food_log_entry.dart';

// ── User targets (loaded once from SharedPrefs) ───────────────────────────────

class UserTargets {
  const UserTargets({
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.userName,
  });

  final int kcal;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final String userName;
}

final userTargetsProvider = FutureProvider<UserTargets>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return UserTargets(
    kcal: prefs.getInt('target_kcal') ?? 2000,
    proteinG: prefs.getInt('target_protein') ?? 50,
    carbsG: prefs.getInt('target_carbs') ?? 250,
    fatG: prefs.getInt('target_fat') ?? 65,
    userName: prefs.getString('user_name') ?? 'there',
  );
});

// ── Today's food log (persisted to SQLite) ────────────────────────────────────

class TodayLogNotifier extends StateNotifier<List<FoodLogEntry>> {
  TodayLogNotifier() : super([]) {
    _initialize();
  }

  Future<void> _initialized = Future.value();
  Future<void> _queue = Future.value();

  void _initialize() {
    _initialized = _restore();
  }

  void _enqueue(Future<void> Function() action) {
    _queue = _queue.then((_) async {
      await _initialized;
      await action();
    });
    unawaited(_queue);
  }

  Future<void> _restore() async {
    await _migrateFromSharedPrefs();
    state = await MealLogDatabaseService.instance
        .getEntriesForDate(DateTime.now());
  }

  // One-time migration: if the old SharedPreferences key exists and SQLite
  // has no entries yet for today, copy them across then delete the key.
  Future<void> _migrateFromSharedPrefs() async {
    const legacyKey = 'today_food_log_entries';
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(legacyKey);
    if (encoded == null || encoded.isEmpty) return;

    final existing = await MealLogDatabaseService.instance
        .getEntriesForDate(DateTime.now());
    if (existing.isNotEmpty) {
      // SQLite already has data — just drop the stale key.
      await prefs.remove(legacyKey);
      return;
    }

    for (final raw in encoded) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          await MealLogDatabaseService.instance
              .insertEntry(FoodLogEntry.fromJson(decoded));
        }
      } catch (_) {}
    }
    await prefs.remove(legacyKey);
  }

  void add(FoodLogEntry entry) => _enqueue(() async {
        await MealLogDatabaseService.instance.insertEntry(entry);
        state = [...state, entry];
      });

  void remove(String id) => _enqueue(() async {
        await MealLogDatabaseService.instance.deleteEntry(id);
        state = state.where((e) => e.id != id).toList();
      });

  void update(FoodLogEntry entry) => _enqueue(() async {
        await MealLogDatabaseService.instance.updateEntry(entry);
        state = [for (final e in state) if (e.id == entry.id) entry else e];
      });

  void undoLast() {
    _enqueue(() async {
      if (state.isEmpty) return;
      final last = state.last;
      await MealLogDatabaseService.instance.deleteEntry(last.id);
      state = state.sublist(0, state.length - 1);
    });
  }
}

final todayLogProvider =
    StateNotifierProvider<TodayLogNotifier, List<FoodLogEntry>>(
  (ref) => TodayLogNotifier(),
);

// ── Computed totals ───────────────────────────────────────────────────────────

final todayKcalProvider = Provider<double>(
    (ref) => ref.watch(todayLogProvider).fold(0.0, (s, e) => s + e.kcal));

final todayProteinProvider = Provider<double>(
    (ref) => ref.watch(todayLogProvider).fold(0.0, (s, e) => s + e.proteinG));

final todayCarbsProvider = Provider<double>(
    (ref) => ref.watch(todayLogProvider).fold(0.0, (s, e) => s + e.carbsG));

final todayFatProvider = Provider<double>(
    (ref) => ref.watch(todayLogProvider).fold(0.0, (s, e) => s + e.fatG));

// ── Historical queries (for Progress screen) ─────────────────────────────────

/// Returns all log entries for the last [days] calendar days (today included).
/// Usage: ref.watch(weeklyLogsProvider(7))
final weeklyLogsProvider =
    FutureProvider.family<List<FoodLogEntry>, int>((ref, days) {
  return MealLogDatabaseService.instance.getEntriesForLastNDays(days);
});
