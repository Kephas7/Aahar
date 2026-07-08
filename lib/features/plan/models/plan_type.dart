import 'package:flutter/material.dart';

class PlanTypeInfo {
  const PlanTypeInfo({
    required this.id,
    required this.label,
    required this.description,
    required this.goalKey,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  final String id;
  final String label;
  final String description; // short copy shown under label in selector
  final String goalKey;     // matches UserProfile.goal values from onboarding
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
}

// goalKey values must match OnboardingGoalScreen's options:
//   'nutrition' | 'weight' | 'muscle' | 'health'
const kPlanTypes = [
  PlanTypeInfo(
    id: 'weight_loss',
    label: 'Fat loss',
    description: 'high protein, lower carb',
    goalKey: 'weight',
    icon: Icons.local_fire_department_outlined,
    iconColor: Color(0xFFE07B00),
    iconBgColor: Color(0xFF2D1400),
  ),
  PlanTypeInfo(
    id: 'muscle_gain',
    label: 'Muscle gain',
    description: 'high protein, calorie surplus',
    goalKey: 'muscle',
    icon: Icons.fitness_center_outlined,
    iconColor: Color(0xFF378ADD),
    iconBgColor: Color(0xFF0D1A2E),
  ),
  PlanTypeInfo(
    id: 'maintain',
    label: 'Maintenance',
    description: 'balanced macros, steady energy',
    goalKey: 'health',
    icon: Icons.balance_outlined,
    iconColor: Color(0xFF1D9E75),
    iconBgColor: Color(0xFF152A1E),
  ),
  PlanTypeInfo(
    id: 'nutrition',
    label: 'Better nutrition',
    description: 'whole foods, micronutrient focus',
    goalKey: 'nutrition',
    icon: Icons.eco_outlined,
    iconColor: Color(0xFFCAFF3D),
    iconBgColor: Color(0xFF1A2800),
  ),
];
