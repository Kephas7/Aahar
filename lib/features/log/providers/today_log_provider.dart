import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// ── Today's food log (persisted locally) ─────────────────────────────────────

class TodayLogNotifier extends StateNotifier<List<FoodLogEntry>> {
  TodayLogNotifier() : super([]) {
    _initialize();
  }

  static const _storageKey = 'today_food_log_entries';

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
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_storageKey) ?? const [];
    final restored = encoded
        .map((value) {
          try {
            final decoded = jsonDecode(value);
            if (decoded is Map<String, dynamic>) {
              return FoodLogEntry.fromJson(decoded);
            }
          } catch (_) {
            return null;
          }
          return null;
        })
        .whereType<FoodLogEntry>()
        .toList();

    state = restored;
  }

  Future<void> _persist(List<FoodLogEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      entries.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }

  void add(FoodLogEntry entry) => _enqueue(() async {
    state = [...state, entry];
    await _persist(state);
  });

  void remove(String id) => _enqueue(() async {
    state = state.where((e) => e.id != id).toList();
    await _persist(state);
  });

  void undoLast() {
    _enqueue(() async {
      if (state.isEmpty) return;
      state = state.sublist(0, state.length - 1);
      await _persist(state);
    });
  }
}

final todayLogProvider =
    StateNotifierProvider<TodayLogNotifier, List<FoodLogEntry>>(
      (ref) => TodayLogNotifier(),
    );

// ── Computed totals ───────────────────────────────────────────────────────────

final todayKcalProvider = Provider<double>((ref) {
  return ref.watch(todayLogProvider).fold(0.0, (s, e) => s + e.kcal);
});

final todayProteinProvider = Provider<double>((ref) {
  return ref.watch(todayLogProvider).fold(0.0, (s, e) => s + e.proteinG);
});

final todayCarbsProvider = Provider<double>((ref) {
  return ref.watch(todayLogProvider).fold(0.0, (s, e) => s + e.carbsG);
});

final todayFatProvider = Provider<double>((ref) {
  return ref.watch(todayLogProvider).fold(0.0, (s, e) => s + e.fatG);
});
