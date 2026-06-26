import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class OnboardingNotifier extends StateNotifier<UserProfile> {
  OnboardingNotifier()
    : super(
        const UserProfile(
          name: '',
          gender: 'other',
          age: 0,
          weightKg: 0,
          heightCm: 0,
          goal: 'health',
          activityLevel: 'sedentary',
          healthConditions: <String>[],
          foodPreference: 'none',
          dailyBudgetNPR: 0,
        ),
      );

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void updateBodyDetails(int age, double weight, double height) {
    state = state.copyWith(age: age, weightKg: weight, heightCm: height);
  }

  void updateGoal(String goal) {
    state = state.copyWith(goal: goal);
  }

  void updateLifestyle(String activityLevel, List<dynamic> conditions) {
    state = state.copyWith(
      activityLevel: activityLevel,
      healthConditions: conditions
          .map((condition) => condition.toString())
          .toList(),
    );
  }

  void updateFoodPreference(String foodPreference) {
    state = state.copyWith(foodPreference: foodPreference);
  }

  Future<void> saveToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No authenticated user found.');
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('details')
        .set(state.toMap());

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('onboarding_complete', true);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, UserProfile>(
      (ref) => OnboardingNotifier(),
    );
