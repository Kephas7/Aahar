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

// ── Today's food log (in-memory, resets on restart) ──────────────────────────

class TodayLogNotifier extends StateNotifier<List<FoodLogEntry>> {
  TodayLogNotifier() : super([]);

  void add(FoodLogEntry entry) => state = [...state, entry];

  void remove(String id) =>
      state = state.where((e) => e.id != id).toList();

  void undoLast() {
    if (state.isNotEmpty) state = state.sublist(0, state.length - 1);
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
