import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/themes/aahar_theme.dart';
import '../../onboarding/models/user_profile.dart';
import '../../onboarding/widgets/dark_text_field.dart';
import '../../onboarding/widgets/selection_tile.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;

  String _goal = 'health';
  bool _isLoading = false;

  // Preserved fields (not shown in the form) — populated from the loaded profile
  String _gender = 'other';
  String _activityLevel = 'sedentary';
  List<String> _healthConditions = const [];
  String _foodPreference = 'none';
  int _dailyBudgetNPR = 0;

  static const _goals = [
    (value: 'nutrition', label: 'Improve nutrition', icon: Icons.eco_outlined),
    (value: 'weight', label: 'Lose weight', icon: Icons.monitor_weight_outlined),
    (value: 'muscle', label: 'Build muscle', icon: Icons.fitness_center_outlined),
    (value: 'health', label: 'Manage health condition', icon: Icons.favorite_outline),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _heightCtrl = TextEditingController();

    // Populate synchronously if the provider is already cached (no flicker)
    ref.read(userProfileProvider).whenData(_applyProfile);

    // Also handle the async path (provider still loading, or error state retry)
    ref
        .read(userProfileProvider.future)
        .then((p) { if (p != null && mounted) setState(() => _applyProfile(p)); })
        .catchError((_) {});
  }

  void _applyProfile(UserProfile? p) {
    if (p == null) return;
    _nameCtrl.text = p.name;
    _bioCtrl.text = p.bio ?? '';
    _ageCtrl.text = p.age > 0 ? '${p.age}' : '';
    _weightCtrl.text = p.weightKg > 0 ? _fmtN(p.weightKg) : '';
    _heightCtrl.text = p.heightCm > 0 ? _fmtN(p.heightCm) : '';
    _goal = p.goal;
    _gender = p.gender;
    _activityLevel = p.activityLevel;
    _healthConditions = p.healthConditions;
    _foodPreference = p.foodPreference;
    _dailyBudgetNPR = p.dailyBudgetNPR;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  String _fmtN(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  Future<void> _save() async {
    if (_isLoading) return;

    final name = _nameCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text.trim());
    final weight = double.tryParse(_weightCtrl.text.trim());
    final height = double.tryParse(_heightCtrl.text.trim());

    if (name.isEmpty) {
      _showError('Name cannot be empty');
      return;
    }
    if (age == null || age <= 0 || age > 120) {
      _showError('Enter a valid age');
      return;
    }
    if (weight == null || weight <= 0) {
      _showError('Enter a valid weight');
      return;
    }
    if (height == null || height <= 0) {
      _showError('Enter a valid height');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bio = _bioCtrl.text.trim();
      final updated = UserProfile(
        name: name,
        gender: _gender,
        age: age,
        weightKg: weight,
        heightCm: height,
        goal: _goal,
        activityLevel: _activityLevel,
        healthConditions: _healthConditions,
        foodPreference: _foodPreference,
        dailyBudgetNPR: _dailyBudgetNPR,
        bio: bio.isEmpty ? null : bio,
      );

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
      await prefs.setString('user_name', name);

      ref.invalidate(userProfileProvider);

      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AaharTheme.darkBg,
        appBar: AppBar(
          backgroundColor: AaharTheme.darkBg,
          elevation: 0,
          leading: BackButton(
            color: Colors.white,
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Edit profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar ──────────────────────────────────────────────────
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ListenableBuilder(
                        listenable: _nameCtrl,
                        builder: (_, _) => CircleAvatar(
                          radius: 44,
                          backgroundColor: AaharTheme.brandLime,
                          child: Text(
                            _nameCtrl.text.isNotEmpty
                                ? _nameCtrl.text[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AaharTheme.darkBg,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: -4,
                        child: GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content:
                                      Text('Photo upload coming soon'))),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AaharTheme.darkBg, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Name ────────────────────────────────────────────────────
                const FieldLabel('NAME'),
                const SizedBox(height: 6),
                DarkTextField(
                  controller: _nameCtrl,
                  hintText: 'Your name',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 14),

                // ── Bio ─────────────────────────────────────────────────────
                const FieldLabel('BIO (OPTIONAL)'),
                const SizedBox(height: 6),
                DarkTextField(
                  controller: _bioCtrl,
                  hintText: 'e.g. Music teacher · Kathmandu',
                  prefixIcon: Icons.info_outline,
                ),
                const SizedBox(height: 14),

                // ── Age + Weight ────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('AGE'),
                          const SizedBox(height: 6),
                          DarkTextField(
                            controller: _ageCtrl,
                            hintText: '25',
                            suffixText: 'yrs',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel('WEIGHT'),
                          const SizedBox(height: 6),
                          DarkTextField(
                            controller: _weightCtrl,
                            hintText: '65',
                            suffixText: 'kg',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Height ──────────────────────────────────────────────────
                const FieldLabel('HEIGHT'),
                const SizedBox(height: 6),
                DarkTextField(
                  controller: _heightCtrl,
                  hintText: '165',
                  suffixText: 'cm',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 24),

                // ── Goal ────────────────────────────────────────────────────
                const FieldLabel('GOAL'),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _goals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => SelectionTile(
                    label: _goals[i].label,
                    icon: _goals[i].icon,
                    selected: _goal == _goals[i].value,
                    onTap: () => setState(() => _goal = _goals[i].value),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Save button ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AaharTheme.brandLime,
                      foregroundColor: AaharTheme.darkBg,
                      disabledBackgroundColor:
                          AaharTheme.brandLime.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
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
                        : const Text(
                            'Save changes',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
