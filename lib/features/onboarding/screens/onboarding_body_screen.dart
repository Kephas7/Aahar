import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/dark_text_field.dart';
import '../widgets/progress_dots.dart';

class OnboardingBodyScreen extends ConsumerStatefulWidget {
  const OnboardingBodyScreen({super.key});

  @override
  ConsumerState<OnboardingBodyScreen> createState() => _OnboardingBodyScreenState();
}

class _OnboardingBodyScreenState extends ConsumerState<OnboardingBodyScreen> {
  final _ageController = TextEditingController(text: '22');
  final _weightController = TextEditingController(text: '65');
  final _heightController = TextEditingController(text: '170');

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _continue() {
    final age = int.tryParse(_ageController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    ref.read(onboardingProvider.notifier).updateBodyDetails(age, weight, height);
    context.go('/onboarding/goal');
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
                child: Center(child: OnboardingProgressDots(currentStep: 2)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Your body details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Used to calculate your personal targets',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AaharTheme.darkSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Column(
                    children: [
                      _BodyField(
                        label: 'AGE',
                        controller: _ageController,
                        unit: 'years',
                      ),
                      const Divider(color: Color(0xFF2A2A2A), height: 24),
                      _BodyField(
                        label: 'WEIGHT',
                        controller: _weightController,
                        unit: 'kg',
                      ),
                      const Divider(color: Color(0xFF2A2A2A), height: 24),
                      _BodyField(
                        label: 'HEIGHT',
                        controller: _heightController,
                        unit: 'cm',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2340),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, color: Color(0xFF4A9EE0), size: 16),
                      SizedBox(width: 10),
                      Text(
                        'Used only to calculate targets — never shared',
                        style: TextStyle(color: Color(0xFF4A9EE0), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _continue,
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

class _BodyField extends StatelessWidget {
  const _BodyField({
    required this.label,
    required this.controller,
    required this.unit,
  });

  final String label;
  final TextEditingController controller;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 8),
        DarkTextField(
          controller: controller,
          hintText: '0',
          suffixText: unit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        ),
      ],
    );
  }
}
