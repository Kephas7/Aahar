import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/themes/aahar_theme.dart';
import '../../onboarding/models/user_profile.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AaharTheme.darkBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 22,
                        color: AaharTheme.brandLime,
                      ),
                      onPressed: () => context.push('/home/profile/edit'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: profileAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AaharTheme.brandLime),
                  ),
                  error: (_, _) => const Center(
                    child: Text(
                      'Could not load profile',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  data: (profile) {
                    if (profile == null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'No profile found',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 15),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  context.push('/home/profile/edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AaharTheme.brandLime,
                                foregroundColor: AaharTheme.darkBg,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Set up profile'),
                            ),
                          ],
                        ),
                      );
                    }
                    return _ProfileContent(profile: profile);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  const _ProfileContent({required this.profile});
  final UserProfile profile;

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AaharTheme.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        content: const Text(
          'You will be signed out and returned to the welcome screen.',
          style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out',
                style: TextStyle(
                    color: Color(0xFFFF5555), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove('onboarding_complete'),
      prefs.remove('user_name'),
      prefs.remove('target_kcal'),
      prefs.remove('target_protein'),
      prefs.remove('target_carbs'),
      prefs.remove('target_fat'),
    ]);

    if (!mounted) return;
    context.go('/splash');
  }

  String _foodPrefLabel(String pref) => switch (pref.toLowerCase()) {
        'vegetarian' => 'Vegetarian',
        'vegan' => 'Vegan',
        'jain' => 'Jain',
        _ => pref,
      };

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + name + goal ──────────────────────────────────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AaharTheme.brandLime,
                  child: Text(
                    profile.name.isNotEmpty
                        ? profile.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AaharTheme.darkBg,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _GoalChip(goal: profile.goal),
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    profile.bio!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Body stats ────────────────────────────────────────────────────
          const _SectionLabel('BODY STATS'),
          const SizedBox(height: 10),
          _StatsGrid(profile: profile),
          const SizedBox(height: 24),

          // ── Health & diet chips ───────────────────────────────────────────
          if (profile.healthConditions.isNotEmpty ||
              profile.foodPreference != 'none') ...[
            const _SectionLabel('HEALTH & DIET'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in profile.healthConditions) _InfoChip(c),
                if (profile.foodPreference != 'none')
                  _InfoChip(
                    _foodPrefLabel(profile.foodPreference),
                    accent: true,
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // ── Notification preferences ──────────────────────────────────────
          const _SectionLabel('NOTIFICATIONS'),
          const SizedBox(height: 8),
          _PrefTile(
            label: 'Smart reminders',
            subtitle: 'Get nudged to log meals',
            value: prefs.smartReminders,
            onChanged: notifier.setSmartReminders,
          ),
          _PrefTile(
            label: 'Health alerts',
            subtitle: 'Alerts for your conditions',
            value: prefs.healthConditionAlerts,
            onChanged: notifier.setHealthConditionAlerts,
          ),
          _PrefTile(
            label: 'Weekly summary',
            subtitle: 'Sunday digest of your week',
            value: prefs.weeklySummary,
            onChanged: notifier.setWeeklySummary,
          ),
          const SizedBox(height: 28),

          // ── Edit button ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.push('/home/profile/edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AaharTheme.brandLime,
                foregroundColor: AaharTheme.darkBg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Edit profile',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Log out button ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(
                'Log out',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF5555),
                side: const BorderSide(color: Color(0xFF3A1A1A), width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.goal});
  final String goal;

  @override
  Widget build(BuildContext context) {
    final label = switch (goal.toLowerCase()) {
      'weight' => 'Lose weight',
      'muscle' => 'Build muscle',
      'nutrition' => 'Improve nutrition',
      _ => 'Manage health',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: AaharTheme.brandLime.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AaharTheme.brandLime.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AaharTheme.brandLime,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label, {this.accent = false});
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: accent
            ? AaharTheme.brandLime.withValues(alpha: 0.10)
            : const Color(0xFF222222),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent
              ? AaharTheme.brandLime.withValues(alpha: 0.25)
              : const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent ? AaharTheme.brandLime : const Color(0xFFCCCCCC),
          fontSize: 12,
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
        color: Color(0xFF666666),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Age', profile.age > 0 ? '${profile.age} yrs' : '—'),
      ('Weight', profile.weightKg > 0 ? '${_fmt(profile.weightKg)} kg' : '—'),
      ('Height', profile.heightCm > 0 ? '${_fmt(profile.heightCm)} cm' : '—'),
      ('Activity', _activityLabel(profile.activityLevel)),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.3,
      children: [
        for (final item in items)
          _StatCell(label: item.$1, value: item.$2),
      ],
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  String _activityLabel(String level) => switch (level.toLowerCase()) {
        'light' => 'Lightly active',
        'active' => 'Very active',
        _ => 'Sedentary',
      };
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AaharTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  const _PrefTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: Color(0xFF666666), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AaharTheme.brandLime,
            activeTrackColor:
                AaharTheme.brandLime.withValues(alpha: 0.25),
            inactiveThumbColor: const Color(0xFF444444),
            inactiveTrackColor: const Color(0xFF2A2A2A),
          ),
        ],
      ),
    );
  }
}
