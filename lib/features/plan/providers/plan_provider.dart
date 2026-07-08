import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../log/providers/today_log_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/plan_type.dart';
import '../services/meal_suggester.dart';

// ── Default targets used while profile is loading ─────────────────────────────

const _kDefaultTargets = <String, double>{
  'kcal': 2000.0,
  'proteinG': 50.0,
  'carbsG': 250.0,
  'fatG': 65.0,
};

// ── Active plan targets ────────────────────────────────────────────────────────

/// Macro targets for the user's current active plan (their stored goal).
/// Synchronous: returns defaults while the profile is loading or errored.
final activePlanTargetsProvider = Provider<Map<String, double>>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (p) => p?.calculateTargets() ?? _kDefaultTargets,
    loading: () => _kDefaultTargets,
    error: (_, _) => _kDefaultTargets,
  );
});

// ── Active plan type info ─────────────────────────────────────────────────────

/// The PlanTypeInfo corresponding to the user's current goal.
final activePlanTypeProvider = Provider<PlanTypeInfo>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  final goalKey = profileAsync.whenOrNull(data: (p) => p?.goal) ?? 'health';
  return kPlanTypes.firstWhere(
    (p) => p.goalKey == goalKey,
    orElse: () => kPlanTypes.first,
  );
});

// ── All plan previews ─────────────────────────────────────────────────────────

/// Targets for every plan type, computed from the current user's body stats.
/// Used by PlanSelectorScreen to show real kcal numbers without switching plans.
final allPlanPreviewsProvider = Provider<Map<String, Map<String, double>>>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (p) {
      if (p == null) return {};
      return {
        for (final plan in kPlanTypes)
          plan.id: p.calculateTargets(goalOverride: plan.goalKey),
      };
    },
    loading: () => {},
    error: (_, _) => {},
  );
});

// ── Today's gaps ──────────────────────────────────────────────────────────────

/// Remaining macro amounts for today: target − consumed, clamped to ≥ 0.
final todaysGapsProvider = Provider<Map<String, double>>((ref) {
  final targets = ref.watch(activePlanTargetsProvider);
  final protein = ref.watch(todayProteinProvider);
  final carbs = ref.watch(todayCarbsProvider);
  final fat = ref.watch(todayFatProvider);
  final ironMg =
      ref.watch(todayLogProvider).fold(0.0, (s, e) => s + e.ironMg);

  return {
    'protein':
        ((targets['proteinG'] ?? 50.0) - protein).clamp(0.0, double.infinity),
    'carbs':
        ((targets['carbsG'] ?? 250.0) - carbs).clamp(0.0, double.infinity),
    'fat': ((targets['fatG'] ?? 65.0) - fat).clamp(0.0, double.infinity),
    'iron': (18.0 - ironMg).clamp(0.0, double.infinity),
  };
});

// ── Suggested meals ───────────────────────────────────────────────────────────

final suggestedMealsProvider = Provider<List<SuggestedMeal>>((ref) {
  final gaps = ref.watch(todaysGapsProvider);
  final profile = ref.watch(userProfileProvider).whenOrNull(data: (p) => p);
  return suggestMeals(gaps, profile?.dailyBudgetNPR);
});

// ── Switch active plan ────────────────────────────────────────────────────────

/// Persists a new goal to Firestore + SharedPreferences, recalculates targets,
/// and invalidates the profile + targets providers so every screen updates.
Future<void> switchActivePlan(String newGoalKey, WidgetRef ref) async {
  final profile = await ref.read(userProfileProvider.future);
  if (profile == null) return;

  final updated = profile.copyWith(goal: newGoalKey);
  final targets = updated.calculateTargets();

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('details')
        .set(updated.toMap())
        .timeout(const Duration(seconds: 5));
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('target_kcal', targets['kcal']!.round());
  await prefs.setInt('target_protein', targets['proteinG']!.round());
  await prefs.setInt('target_carbs', targets['carbsG']!.round());
  await prefs.setInt('target_fat', targets['fatG']!.round());

  ref.invalidate(userProfileProvider);
  ref.invalidate(userTargetsProvider);
}
