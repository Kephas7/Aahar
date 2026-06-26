import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/progress_dots.dart';
import '../widgets/selection_tile.dart';

class OnboardingGoalScreen extends ConsumerStatefulWidget {
  const OnboardingGoalScreen({super.key});

  @override
  ConsumerState<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends ConsumerState<OnboardingGoalScreen> {
  String _goal = 'nutrition';

  static const _goals = [
    (value: 'nutrition', label: 'Improve nutrition', icon: Icons.eco_outlined),
    (value: 'weight', label: 'Lose weight', icon: Icons.monitor_weight_outlined),
    (value: 'muscle', label: 'Build muscle', icon: Icons.fitness_center_outlined),
    (value: 'health', label: 'Manage health condition', icon: Icons.favorite_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AaharTheme.darkBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Center(child: OnboardingProgressDots(currentStep: 3)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "What's your main goal?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ListView.separated(
                    itemCount: _goals.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => SelectionTile(
                      label: _goals[i].label,
                      icon: _goals[i].icon,
                      selected: _goal == _goals[i].value,
                      onTap: () => setState(() => _goal = _goals[i].value),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(onboardingProvider.notifier).updateGoal(_goal);
                      context.go('/onboarding/lifestyle');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AaharTheme.brandLime,
                      foregroundColor: AaharTheme.darkBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
