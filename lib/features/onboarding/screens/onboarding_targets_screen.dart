import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/themes/aahar_theme.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/progress_dots.dart';

class OnboardingTargetsScreen extends ConsumerStatefulWidget {
  const OnboardingTargetsScreen({super.key});

  @override
  ConsumerState<OnboardingTargetsScreen> createState() =>
      _OnboardingTargetsScreenState();
}

class _OnboardingTargetsScreenState
    extends ConsumerState<OnboardingTargetsScreen> {
  bool _isLoading = false;

  Future<void> _startTracking() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final profile = ref.read(onboardingProvider);
      final targets = profile.calculateTargets();

      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool('onboarding_complete', true),
        prefs.setString('user_name', profile.name),
        prefs.setInt('target_kcal', targets['kcal']?.round() ?? 2000),
        prefs.setInt('target_protein', targets['proteinG']?.round() ?? 50),
        prefs.setInt('target_carbs', targets['carbsG']?.round() ?? 250),
        prefs.setInt('target_fat', targets['fatG']?.round() ?? 65),
      ]);

      // Firestore save is non-blocking — 5 s timeout so bad connectivity
      // doesn't prevent the user from getting to the dashboard.
      await ref
          .read(onboardingProvider.notifier)
          .saveToFirebase()
          .timeout(const Duration(seconds: 5))
          .catchError((_) {});
    } catch (_) {
      // SharedPreferences write should never fail, but be safe.
    }

    if (mounted) context.go('/home/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(onboardingProvider);
    final targets = profile.calculateTargets();

    final kcal = targets['kcal']?.round() ?? 0;
    final protein = targets['proteinG']?.round() ?? 0;
    final carbs = targets['carbsG']?.round() ?? 0;
    final fat = targets['fatG']?.round() ?? 0;
    // Iron RDA: 18mg women, 8mg men (approximate)
    final iron = profile.gender == 'female' ? 18 : 8;

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
                child: Center(child: OnboardingProgressDots(currentStep: 5)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Your daily targets',
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
                  'Calculated from your body details and goal',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF152A1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatCalories(kcal),
                        style: const TextStyle(
                          color: AaharTheme.brandLime,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'calories per day',
                        style:
                            TextStyle(color: Color(0xFF888888), fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Based on the Harris-Benedict formula',
                        style:
                            TextStyle(color: Color(0xFF4A9EE0), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _MacroTile(
                      value: '${protein}g',
                      label: 'Protein',
                      color: AaharTheme.nutrientProtein,
                    ),
                    _MacroTile(
                      value: '${carbs}g',
                      label: 'Carbs',
                      color: AaharTheme.nutrientCarbs,
                    ),
                    _MacroTile(
                      value: '${fat}g',
                      label: 'Fat',
                      color: AaharTheme.nutrientFat,
                    ),
                    _MacroTile(
                      value: '${iron}mg',
                      label: 'Iron',
                      color: AaharTheme.nutrientIron,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _startTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AaharTheme.brandLime,
                          disabledBackgroundColor:
                              AaharTheme.brandLime.withAlpha(150),
                          foregroundColor: AaharTheme.darkBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AaharTheme.darkBg,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Start tracking',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AaharTheme.darkSurface,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Adjust manually',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCalories(int kcal) {
    if (kcal >= 1000) {
      return '${(kcal ~/ 1000)},${(kcal % 1000).toString().padLeft(3, '0')}';
    }
    return '$kcal';
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AaharTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
