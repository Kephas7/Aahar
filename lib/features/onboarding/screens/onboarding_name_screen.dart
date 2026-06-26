import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/aahar_theme.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/dark_text_field.dart';
import '../widgets/progress_dots.dart';

class OnboardingNameScreen extends ConsumerStatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  ConsumerState<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends ConsumerState<OnboardingNameScreen> {
  final _nameController = TextEditingController();
  String _gender = 'male';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(onboardingProvider.notifier)
      ..updateName(name)
      ..updateGender(_gender);
    context.go('/onboarding/body');
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
                child: Center(child: OnboardingProgressDots(currentStep: 1)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "What's your name?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('FULL NAME'),
                    const SizedBox(height: 8),
                    DarkTextField(
                      controller: _nameController,
                      hintText: 'e.g. Rabin Gahatraj',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 24),
                    const FieldLabel('GENDER'),
                    const SizedBox(height: 10),
                    _GenderSelector(
                      selected: _gender,
                      onChanged: (g) => setState(() => _gender = g),
                    ),
                  ],
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

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [('Male', 'male'), ('Female', 'female'), ('Other', 'other')];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AaharTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((o) {
          final isSelected = selected == o.$2;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(o.$2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? AaharTheme.brandLime : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    o.$1,
                    style: TextStyle(
                      color: isSelected ? AaharTheme.darkBg : const Color(0xFF888888),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
