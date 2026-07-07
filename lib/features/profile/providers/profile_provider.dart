import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../onboarding/models/user_profile.dart';

// ── User profile ───────────────────────────────────────────────────────────────

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('details')
          .get()
          .timeout(const Duration(seconds: 5));
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
    } catch (_) {}
  }
  // SharedPreferences fallback — partial reconstruction from onboarding data
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('user_name');
  if (name == null) return null;
  return UserProfile(
    name: name,
    gender: 'other',
    age: 0,
    weightKg: 0,
    heightCm: 0,
    goal: 'health',
    activityLevel: 'sedentary',
    healthConditions: const [],
    foodPreference: 'none',
    dailyBudgetNPR: 0,
  );
});

// ── Notification preferences ───────────────────────────────────────────────────

class PreferencesState {
  const PreferencesState({
    required this.smartReminders,
    required this.healthConditionAlerts,
    required this.weeklySummary,
  });

  final bool smartReminders;
  final bool healthConditionAlerts;
  final bool weeklySummary;

  PreferencesState copyWith({
    bool? smartReminders,
    bool? healthConditionAlerts,
    bool? weeklySummary,
  }) =>
      PreferencesState(
        smartReminders: smartReminders ?? this.smartReminders,
        healthConditionAlerts:
            healthConditionAlerts ?? this.healthConditionAlerts,
        weeklySummary: weeklySummary ?? this.weeklySummary,
      );
}

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier()
      : super(const PreferencesState(
          smartReminders: true,
          healthConditionAlerts: true,
          weeklySummary: false,
        )) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = PreferencesState(
      smartReminders: prefs.getBool('pref_smart_reminders') ?? true,
      healthConditionAlerts: prefs.getBool('pref_health_alerts') ?? true,
      weeklySummary: prefs.getBool('pref_weekly_summary') ?? false,
    );
  }

  Future<void> setSmartReminders(bool v) async {
    state = state.copyWith(smartReminders: v);
    (await SharedPreferences.getInstance()).setBool('pref_smart_reminders', v);
  }

  Future<void> setHealthConditionAlerts(bool v) async {
    state = state.copyWith(healthConditionAlerts: v);
    (await SharedPreferences.getInstance()).setBool('pref_health_alerts', v);
  }

  Future<void> setWeeklySummary(bool v) async {
    state = state.copyWith(weeklySummary: v);
    (await SharedPreferences.getInstance()).setBool('pref_weekly_summary', v);
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>(
  (ref) => PreferencesNotifier(),
);
