class UserProfile {
  const UserProfile({
    required this.name,
    required this.gender,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.goal,
    required this.activityLevel,
    required this.healthConditions,
    required this.foodPreference,
    required this.dailyBudgetNPR,
    this.bio,
  });

  final String name;
  final String gender;
  final int age;
  final double weightKg;
  final double heightCm;
  final String goal;
  final String activityLevel;
  final List<String> healthConditions;
  final String foodPreference;
  final int dailyBudgetNPR;
  final String? bio;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'gender': gender,
      'age': age,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'goal': goal,
      'activityLevel': activityLevel,
      'healthConditions': healthConditions,
      'foodPreference': foodPreference,
      'dailyBudgetNPR': dailyBudgetNPR,
      if (bio != null) 'bio': bio,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? '',
      gender: map['gender'] as String? ?? 'other',
      age: (map['age'] as num?)?.toInt() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 0,
      goal: map['goal'] as String? ?? 'health',
      activityLevel: map['activityLevel'] as String? ?? 'sedentary',
      healthConditions:
          (map['healthConditions'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          <String>[],
      foodPreference: map['foodPreference'] as String? ?? 'none',
      dailyBudgetNPR: (map['dailyBudgetNPR'] as num?)?.toInt() ?? 0,
      bio: map['bio'] as String?,
    );
  }

  UserProfile copyWith({
    String? name,
    String? gender,
    int? age,
    double? weightKg,
    double? heightCm,
    String? goal,
    String? activityLevel,
    List<String>? healthConditions,
    String? foodPreference,
    int? dailyBudgetNPR,
    String? bio,
  }) {
    return UserProfile(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      healthConditions: healthConditions ?? this.healthConditions,
      foodPreference: foodPreference ?? this.foodPreference,
      dailyBudgetNPR: dailyBudgetNPR ?? this.dailyBudgetNPR,
      bio: bio ?? this.bio,
    );
  }

  Map<String, double> calculateTargets() {
    final bmr = switch (gender.toLowerCase()) {
      'male' =>
        88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age),
      'female' =>
        447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age),
      _ =>
        ((88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age)) +
                (447.593 +
                    (9.247 * weightKg) +
                    (3.098 * heightCm) -
                    (4.330 * age))) /
            2,
    };

    final activityMultiplier = switch (activityLevel.toLowerCase()) {
      'light' => 1.375,
      'active' => 1.55,
      _ => 1.2,
    };

    final goalAdjustment = switch (goal.toLowerCase()) {
      'weight' => -300.0,
      'muscle' => 200.0,
      _ => 0.0,
    };

    final kcal = (bmr * activityMultiplier) + goalAdjustment;
    final adjustedKcal = kcal < 1200 ? 1200.0 : kcal;

    final proteinPerKg = switch (goal.toLowerCase()) {
      'muscle' => 1.6,
      'weight' => 1.2,
      'nutrition' || 'health' => 1.0,
      _ => 1.0,
    };

    final proteinG = weightKg * proteinPerKg;
    final carbCalories = adjustedKcal * 0.45;
    final fatCalories = adjustedKcal * 0.30;

    final carbsG = carbCalories / 4;
    final fatG = fatCalories / 9;

    return <String, double>{
      'kcal': adjustedKcal,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
    };
  }
}
