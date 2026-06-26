import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/progress_dots.dart';
import '../widgets/selection_tile.dart';

class OnboardingLifestyleScreen extends ConsumerStatefulWidget {
  const OnboardingLifestyleScreen({super.key});

  @override
  ConsumerState<OnboardingLifestyleScreen> createState() =>
      _OnboardingLifestyleScreenState();
}

class _OnboardingLifestyleScreenState
    extends ConsumerState<OnboardingLifestyleScreen> {
  String _activityLevel = 'sedentary';
  final Set<String> _conditions = {'none'};

  static const _activityOptions = [
    (value: 'sedentary', label: 'Mostly sitting', icon: Icons.laptop_mac_outlined),
    (value: 'light', label: 'Light activity', icon: Icons.directions_walk_outlined),
    (value: 'active', label: 'Very active', icon: Icons.directions_run_outlined),
  ];

  static const _conditionOptions = ['None', 'Diabetes', 'Hypertension', 'Anaemia'];

  void _toggleCondition(String label) {
    final key = label.toLowerCase();
    setState(() {
      if (key == 'none') {
        _conditions
          ..clear()
          ..add('none');
      } else {
        _conditions.remove('none');
        if (_conditions.contains(key)) {
          _conditions.remove(key);
          if (_conditions.isEmpty) _conditions.add('none');
        } else {
          _conditions.add(key);
        }
      }
    });
  }

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
                child: Center(child: OnboardingProgressDots(currentStep: 4)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Lifestyle & health',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('ACTIVITY LEVEL'),
                      const SizedBox(height: 10),
                      ..._activityOptions.map(
                        (o) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SelectionTile(
                            label: o.label,
                            icon: o.icon,
                            selected: _activityLevel == o.value,
                            onTap: () =>
                                setState(() => _activityLevel = o.value),
                          ),
                        ),
                      ),
                      const Divider(color: Color(0xFF2A2A2A), height: 28),
                      const _SectionLabel('HEALTH CONDITIONS'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _conditionOptions.map((label) {
                          final key = label.toLowerCase();
                          final selected = _conditions.contains(key);
                          return GestureDetector(
                            onTap: () => _toggleCondition(label),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AaharTheme.brandLime
                                    : AaharTheme.darkSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AaharTheme.brandLime
                                      : const Color(0xFF333333),
                                ),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: selected
                                      ? AaharTheme.darkBg
                                      : const Color(0xFFCCCCCC),
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(onboardingProvider.notifier).updateLifestyle(
                            _activityLevel,
                            _conditions.where((c) => c != 'none').toList(),
                          );
                      context.go('/onboarding/targets');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AaharTheme.brandLime,
                      foregroundColor: AaharTheme.darkBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Calculate my targets',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF888888),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}
